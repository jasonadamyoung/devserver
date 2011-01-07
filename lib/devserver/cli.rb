require 'thor'
require 'yaml'

module Devserver
  class CLI < Thor
    include Thor::Actions
    
    # defaults
    @@default_settings = {}
    @@default_settings_source = {}
    @@is_rails_dir = true

    # sets defaults for the class
    def self.set_defaults
      if(!(@@app_root = self.determine_app_root))
        @@is_rails_dir = false
        @@default_settings[:app_root] = '.'
      end
      @@default_settings[:port] = 3000
      @@default_settings[:environment] = 'development'
      @@default_settings[:log_file] = "#{@@default_settings[:app_root]}/log/devserver.log"
      @@default_settings[:pid_file] = "#{@@default_settings[:app_root]}/tmp/pids/devserver.pid"
      @@default_settings[:mode] = 'start'
      @@default_settings[:server] = 'thin'
      self.load_defaults_from_yaml
    end

    # Pretend that we are checking for rails by checking for config/boot.rb
    # we'll even do something smart for ourselves by chdir .. if ../config/boot.rb
    # exists.  "smart for ourselves" is the operative phrase
    #
    # @return [String] the current app root path if we think this is a rails dir, else nil
    def self.determine_app_root
      if(File.exist?('config/boot.rb'))
        return Dir.pwd
      elsif(File.exist?('../config/boot.rb'))
        Dir.chdir('..')
        return Dir.pwd
      else
        return nil
      end
    end

    # Load defaults from a devserver.yaml file located in config/
    def self.load_defaults_from_yaml
      configfile ="#{@@default_settings[:app_root]}/config/devserver.yml"
      if File.exists?(configfile) then
        @@default_settings[:configfile] = configfile
        temp = YAML.load_file(configfile)
        if temp.class == Hash
          temp.each do |key,value|
            @@default_settings[key.to_sym] = value
            @@default_settings_source[key.to_sym] = configfile
          end
        end
      end   
    end
    
    # set defaults on class load
    self.set_defaults 

    # these are not the tasks that you seek
    no_tasks do
      # prints out a warning message if current dir does not appear to be a rails dir
      def rails_warning
        if(!@@is_rails_dir)
          puts "WARNING: #{Dir.pwd} does not appear to be a rails application directory"
        end
      end
      
      # exits with error if current dir does not appear to be a rails dir
      def rails_error
        if(!@@is_rails_dir)
          puts "ERROR: #{Dir.pwd} does not appear to be a rails application directory"
          exit(1)
        end
      end
      
      def print_defaults
        puts "default_settings:\n"
        config_keys = @@default_settings.keys.map{|k|k.to_s}
        config_keys.sort.each do |key|
          puts "  #{key} => #{@@default_settings[key.to_sym]} (#{@@default_settings_source[key.to_sym] || 'code'})\n"
        end
      end
    end


    desc "about", "about devserver"  
    def about
      rails_warning
      puts "Devserver Version #{VERSION}: Provides a wrapper around passenger, thin or mongrel for local ruby on rails development."
    end

    desc "defaults", "devserver configuration defaults"  
    def defaults
      rails_warning
      print_defaults
    end
        
    desc "start", "start devserver"
    method_option :environment,:default => @@default_settings[:environment], :aliases => "-e", :desc => "Rails environment to start"
    method_option :pid_file,:default => @@default_settings[:pid_file], :aliases => "-P", :desc => "Web server pid file"
    method_option :log_file,:default => @@default_settings[:log_file], :aliases => "-l", :desc => "Web server log file"
    method_option :port,:default => @@default_settings[:port], :aliases => "-p", :desc => "Run the web server on this port"
    method_option :server,:default => @@default_settings[:server], :aliases => "-s", :desc => "Web server to use (e.g. passenger, thin, mongrel)"
    def start
      rails_error
      the_server = Devserver::CommandManager.new(options)
      if(the_server.is_port_open?)
        puts "Another process is running on Port: #{the_server.port}"
        puts "Running stop command: #{the_server.command(stop)}"
        the_server.stop_devserver
      end
      the_server.start_devserver
    end
    
    desc "debug", "start devserver in debug mode"
    method_option :environment,:default => @@default_settings[:environment], :aliases => "-e", :desc => "Rails environment to start"
    method_option :pid_file,:default => @@default_settings[:pid_file], :aliases => "-P", :desc => "Web server pid file"
    method_option :log_file,:default => @@default_settings[:log_file], :aliases => "-l", :desc => "Web server log file"
    method_option :port,:default => @@default_settings[:port], :aliases => "-p", :desc => "Run the web server on this port"
    method_option :server,:default => @@default_settings[:server], :aliases => "-s", :desc => "Web server to use (e.g. passenger, thin, mongrel)"
    def debug
      rails_error
      the_server = Devserver::CommandManager.new(options)
      if(the_server.is_port_open?)
        puts "Another process is running on Port: #{the_server.port}"
        puts "Running stop command: #{the_server.command(stop)}"
        the_server.stop_devserver
      end
      the_server.start_devserver('debug')
    end
    
    desc "stop", "stop devserver"
    method_option :pid_file,:default => @@default_settings[:pid_file], :aliases => "-P", :desc => "Web server pid file"
    def stop
      rails_error
      the_server = Devserver::CommandManager.new(options)
      the_server.stop_devserver      
    end
    
    desc "command", "show devserver command"
    method_option :environment,:default => @@default_settings[:environment], :aliases => "-e", :desc => "Rails environment to start"
    method_option :pid_file,:default => @@default_settings[:pid_file], :aliases => "-P", :desc => "Web server pid file"
    method_option :log_file,:default => @@default_settings[:log_file], :aliases => "-l", :desc => "Web server log file"
    method_option :port,:default => @@default_settings[:port], :aliases => "-p", :desc => "Run the web server on this port"
    method_option :server,:default => @@default_settings[:server], :aliases => "-s", :desc => "Web server to use (e.g. passenger, thin, mongrel)"
    method_option :start,:default => true, :desc => "Show command used for server start"
    method_option :stop,:default => true, :desc => "Show command used for server stop"
    method_option :debug,:default => true, :desc => "Show command used for server start with debugging"
    def command
      rails_warning
      the_server = Devserver::CommandManager.new(options)
      if(options[:start])
        puts "start command: #{the_server.command('start')}"
      end
      if(options[:stop])
        puts "stop command: #{the_server.command('stop')}"
      end
      if(options[:debug])
        puts "debug command: #{the_server.command('debug')}"
      end
    end
     
  end
end