require 'thor'
require 'yaml'
require 'syslog'
require 'socket'
require 'timeout'
require 'devserver/version'

module Devserver
  
  class Devserver
    attr_accessor :app_root, :port, :environment, :dry_run, :log_file, :pid_file, :mode, :server
    
    # raises DevserverError if it doesn't appear we are in or one level down of a rails directory
    #
    def initialize(options = {})
      if(self.app_root = self.determine_app_root)
        # hardcoded
        self.set_defaults
        # configfile
        self.load_defaults_from_yaml
        # finally init options
        options.keys.each do |key|
          self.instance_variable_set("@#{key.to_s}",options[:key])
        end
      else
        raise DevserverError, "does not appear to be a rails application directory"
      end  
    end
    
    def load_defaults_from_yaml
      configfile ="#{self.app_root}/config/devserver.yml"
      if File.exists?(configfile) then
        temp = YAML.load_file(configfile)
        if temp.class == Hash
          temp.each do |key,value|
            self.instance_variable_set("@#{key}",value)
          end
        end
      end   
    end
    
    # sets defaults for the class
    def set_defaults
      self.port = 3000
      self.environment = 'development'
      self.dry_run = false
      self.log_file = "#{self.app_root}/log/devserver.log"
      self.pid_file = "#{self.app_root}/tmp/pids/devserver.pid"
      self.mode = 'start'
      self.server = 'thin'
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
    # @return [String] command options
    def start_options
      common_options = "--port #{self.port} --environment #{self.environment}"
      if(self.mode == 'debug')
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
    # @return [String] start command
    def start_command
      case self.server
      when 'passenger'
        "passenger start #{self.start_options}"
      when 'thin'
        "thin #{self.start_options} start"
      when 'mongrel'
        "mongrel_rails start #{self.start_options}"
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
        "passenger stop --port #{self.port} --pid-file #{self.pid_file}"
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
    def command
      case self.mode
      when 'start'
        self.start_command
      when 'debug'
        self.start_command
      when 'stop'
        self.stop_command
      else
        raise DevserverError, "Unrecognized web server: #{self.server}"
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
    
  end
  
  class DevserverError < StandardError
  end
  
  
  class CLI < Thor  

    desc "about", "about devserver"  
    def about  
      puts "Devserver Version #{VERSION}: Provides a wrapper around thin, similar to passenger standalone, for local ruby on rails development."
    end
    
    desc "start", "start devserver"
    def start
    end
    
    desc "debug", "start devserver in debug mode"
    def debug
    end
    
    desc "stop", "stop devserver"
    def stop
    end
    
    desc "command", "show devserver command"
    def command
    end
     
  end
  
end
