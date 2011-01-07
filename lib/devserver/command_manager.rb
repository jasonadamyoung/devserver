require 'socket'
require 'timeout'

module Devserver
  class CommandManager
    attr_accessor :port, :environment, :log_file, :pid_file, :mode, :server
  
    # raises DevserverError if it doesn't appear we are in or one level down of a rails directory
    #
    def initialize(options = {})
      options.keys.each do |key|
        self.instance_variable_set("@#{key.to_s}",options[key])
      end
    end
      
    # Pretend that we are checking for rails by checking for config/boot.rb
    # we'll even do something smart for ourselves by chdir .. if ../config/boot.rb
    # exists.  "smart for ourselves" is the operative phrase
    #
    # @return [String] the current app root path if we think this is a rails dir, else nil
    def determine_app_root
      if(File.exist?('config/boot.rb'))
        return Dir.pwd
      elsif(File.exist?('../config/boot.rb'))
        Dir.chdir('..')
        return Dir.pwd
      else
        return nil
      end
    end

    # builds the command options with regard to the specified server
    #
    # @param [Boolean] mode mode to start in, either debug or start
    # @return [String] command options
    def start_options(mode = self.mode)
      common_options = "--port #{self.port} --environment #{self.environment}"
      if(mode == 'debug')
        common_options += " --debug"
      end
      case self.server
      when 'passenger'
        "#{common_options} --log-file #{self.log_file} --pid-file #{self.pid_file}"
      when 'thin'
        "#{common_options} --log #{self.log_file} --pid #{self.pid_file}"
      when 'mongrel'
        "#{common_options} --log #{self.log_file} --pid #{self.pid_file}"
      else
        nil
      end
    end
  
    # builds the start command for @server
    #
    # @param [Boolean] mode mode to start in, either debug or start
    # @return [String] start command
    def start_command(mode = self.mode)
      case self.server
      when 'passenger'
        "passenger start #{self.start_options(mode)}"
      when 'thin'
        "thin #{self.start_options(mode)} start"
      when 'mongrel'
        "mongrel_rails start #{self.start_options(mode)}"
      else
        raise DevserverError, "Unrecognized web server: #{self.server}"
      end
    end
  
    # builds the stop command for @server
    #
    # @return [String] stop command
    def stop_command
      case self.server
      when 'passenger'
        "passenger stop --pid-file #{self.pid_file}"
      when 'thin'
        "thin --pid #{self.pid_file} stop"
      when 'mongrel'
        "mongrel_rails stop --pid #{self.pid_file}"
      else
        raise DevserverError, "Unrecognized web server: #{self.server}"
      end
    end
  
    # returns command for @server and @mode (start, stop, debug)
    #
    # @return [String] command for @server and @mode
    def command(mode = self.mode)
      case mode
      when 'start'
        self.start_command(mode)
      when 'debug'
        self.start_command(mode)
      when 'stop'
        self.stop_command
      else
        raise DevserverError, "Unrecognized mode: #{mode}"
      end
    end

    # check to see if anything is still running on @port
    #
    # @return [Boolean] whether port responds or not
    def is_port_open?
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new('127.0.0.1', self.port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
      end
      return false
    end
  
    def start_devserver(mode = self.mode)
      system("#{self.start_command(mode)}")
    end
    
    def stop_devserver
      system("#{self.stop_command}")
    end
  
  end
end