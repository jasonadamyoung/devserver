require 'devserver/version'

module Devserver
  autoload :CommandManager,          'devserver/command_manager'
  
  class DevserverError < StandardError
  end
  
end
