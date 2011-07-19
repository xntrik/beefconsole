module BeEF
module Ui
module Console
module CommandDispatcher

class Target
  include BeEF::Ui::Console::CommandDispatcher
  
  @@modules = [] #This is to help with tab completion
  
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
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'Command'
        ])
    cmds.each{ |x|
      #print_line(x['text'].sub(/\W\(\d.*/,""))
      x['children'].each{ |y|
        tbl << [y['id'].to_s, x['text'].sub(/\W\(\d.*/,"")+"/"+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")]
        @@modules << x['text'].sub(/\W\(\d.*/,"")+"/"+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
      }
    }
    puts "\n"
    puts "List of command modules for this target\n"
    puts tbl.to_s + "\n"
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
      print_status("  Usage: module <id> OR <modulename>")
      return
    end
    
    #xntrik - this stuff isn't working yet
    if args[0].to_s.match(/\d+/) != nil
      cmds = driver.remotebeef.command.getcommands(driver.remotebeef.targetsession)
      cmds.each{ |x|
        x['children'].each{ |y|
          if args[0] == x['text'].sub(/\W\(\d.*/,"")+"/"+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
            driver.remotebeef.command.setmodule(y['id'])
          end
        }
      }
    else
       driver.remotebeef.command.setmodule(args[0])
    end
    
    driver.enstack_dispatcher(Module)
    
    driver.update_prompt("(%bld%red"+driver.remotebeef.targetip+"%clr) ["+driver.remotebeef.target.to_s+"] / "+driver.remotebeef.command.cmd['Name']+" ")
    
  end
  
  def cmd_module_tabs(str,words)
    return if words.length > 1
    
    if @@modules == ""
      #prepopulate available modules for tab completion
    else
      return @@modules
    end
  end
  
end

end end end end