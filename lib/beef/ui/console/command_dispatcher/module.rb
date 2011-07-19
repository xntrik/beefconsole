module BeEF
module Ui
module Console
module CommandDispatcher

class Module
  include BeEF::Ui::Console::CommandDispatcher
  
  def initialize(driver)
    super
  end
  
  def name
    "Module"
  end
  
  def commands
    {
      "param" => "Get and Set parameters for this module",
      "modinfo" => "Info about the module",
      "response" => "Get previous responses",
      "go" => "Go.. go execute go!",
    }
  end
  
  def cmd_modinfo
    print_line("Module name: " + driver.remotebeef.command.cmd['Name'])
    print_line("Module category: " + driver.remotebeef.command.cmd['Category'])
    print_line("Module description: " + driver.remotebeef.command.cmd['Description'])
    print_line("Module parameters:")
    
    driver.remotebeef.command.cmd['Data'].each{|data|
      print_line(data['name'] + " => " + data['value'] + " # this is the " + data['ui_label'] + " parameter")
    } if not driver.remotebeef.command.cmd['Data'].nil?
  end
  
  def cmd_param(*args)
    if (args[0] == nil || args[1] == nil)
      print_status("  Usage: param <paramname> <paramvalue>")
      return
    else
      driver.remotebeef.command.setparam(args[0],args[1])
    end
  end
  
  def cmd_response(*args)
    if args[0] == nil
      driver.remotebeef.command.getcmdresponses(driver.remotebeef.targetsession)['commands'].each do |resp|
        print_line(resp['creationdate'] + " - " + resp['object_id'].to_s)
      end
    else
      output = driver.remotebeef.command.getindividualresponse(args[0])
      puts output.class
    end
  end
  
  def cmd_go
    driver.remotebeef.command.runmodule(driver.remotebeef.targetsession).nil? ? print_status("Command not sent") : print_status("Command sent")
  end
    
end

end end end end