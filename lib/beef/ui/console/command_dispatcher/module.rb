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
      print_line(data['name'] + " => \"" + data['value'] + "\" # this is the " + data['ui_label'] + " parameter")
    } if not driver.remotebeef.command.cmd['Data'].nil?
  end
  
  def cmd_param(*args)
    if (args[0] == nil || args[1] == nil)
      print_status("  Usage: param <paramname> <paramvalue>")
      return
    else
      p = ""
      (1..args.length-1).each do |x|
        p << args[x] << " "
      end
      p.chop!
      driver.remotebeef.command.setparam(args[0],p)
    end
  end
  
  def cmd_response(*args)
    if args[0] == "-h"
      cmd_response_help
      return
    end
    
    if args[0] == nil
      tbl = Rex::Ui::Text::Table.new(
        'Columns' =>
          [
            'Id',
            'Executed Time',
            'Response Time'
          ])
      driver.remotebeef.command.getcmdresponses(driver.remotebeef.targetsession)['commands'].each do |resp|
        indiresp = driver.remotebeef.command.getindividualresponse(resp['object_id'])
        respout = ""
        if indiresp['results'].length == 0 or indiresp == nil
          respout = "No response yet"
        else
          respout = Time.at(indiresp['results'][0]['date'].to_i).to_s
        end
        tbl << [resp['object_id'].to_s,resp['creationdate'],respout]
      end
      puts "\n"
      puts "List of responses for this command module\n"
      puts tbl.to_s + "\n"
    else
      output = driver.remotebeef.command.getindividualresponse(args[0])
      if output == nil
        print_line("Invalid response ID")
      elsif output['results'].length == 0
        print_line("No response yet from the hooked browser")
      else
        print_line("Results retrieved: " + Time.at(output['results'][0]['date'].to_i).to_s)
        print_line("")
        print_line("Response:")
        print_line(output['results'][0]['data']['data'].to_s)
      end
    end
  end
  
  def cmd_response_help
    print_line("Usage: response (id)")
    print_line("If you omit id you'll see a list of all responses for the currently active command module")
  end
  
  def cmd_go
    driver.remotebeef.command.runmodule(driver.remotebeef.targetsession).nil? ? print_status("Command not sent") : print_status("Command sent")
  end
    
end

end end end end