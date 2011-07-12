module BeEF
module Ui
module Console
module CommandDispatcher

class Target
  include BeEF::Ui::Console::CommandDispatcher
  
  def initialize(driver)
    super
  end
  
  def name
    "Target"
  end
  
  def commands
    {
      "commands" => "List available commands against this particular target",
      "info" => "Info about the target",
      "module" => "Prepare the command module for execution against this target",
    }
  end
  
  def cmd_commands
    cmds = driver.remotebeef.command.getcommands(driver.remotebeef.targetsession)
    cmds.each{ |x|
      #print_line(x['text'].sub(/\W\(\d.*/,""))
      x['children'].each{ |y|
        print_line(x['text'].sub(/\W\(\d.*/,"")+"/"+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")+" ("+y['id'].to_s+")")
      }
    }
  end
  
  def cmd_info
    info = driver.remotebeef.zombiepoll.getinfo(driver.remotebeef.targetsession)
    info['results'].each{|x|
      x['data'].each{|k,v|
        print_line(k+" - "+v)
      }
    }
  end
  
  def cmd_module(*args)
    if driver.remotebeef.session.connected.nil?
      print_status("You don't appear to be connected, try \"connect\" first")
      return
    end
    
    if (args[0] == nil)
      print_status("  Usage: module <id>")
      return
    end
    
    driver.remotebeef.command.setmodule(args[0])
    
    driver.enstack_dispatcher(Module)
    
    driver.update_prompt("(%bld%red"+driver.remotebeef.targetip+"%clr) ["+driver.remotebeef.target.to_s+"] / "+driver.remotebeef.command.cmd['Name']+" ")
    
  end
  
end

end end end end