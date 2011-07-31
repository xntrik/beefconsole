require 'beef/remote'

module BeEF
module Ui
module Console
module CommandDispatcher

class Remote
  include BeEF::Ui::Console::CommandDispatcher
  
  def initialize(driver)
    super
  end
  
  def name
    "Remote Control"
  end
  
  def commands
    {
      "connect"     => "Connect to a remote BeEF instance",
      "status"      => "Check the status of the connection",
      "disconnect"  => "Disconnect from the remote BeEF instance",
      "offline"     => "List previously hooked browsers",
      "online"      => "List online hooked browsers",
      "review"      => "Target a particular previously hooked (offline) hooked browser",
      "target"      => "Target a particular online hooked browser",
      "onlinepoll"        => "Start a background job to poll for online hooked browsers",
    }
  end
  
  def beef_logo_to_os(logo)
	  case logo
    when "mac.png"
      hbos = "Mac OS X"
    when "linux.png"
      hbos = "Linux"
    when "win.png"
      hbos = "Microsoft Windows"
    when "unknown.png"
      hbos = "Unknown"
    end
  end
  
  def cmd_connect(*args)
    if (args[0] == nil or args[0] == "-h" or args[0] == "--help")
      cmd_connect_help
      return
    end
    if args.length != 3
      cmd_connect_help
      return
    end
    if (driver.remotebeef.session.authenticate(args[0], args[1],args[2]).nil?)
      #For some reason, the first attempt always fails, lets sleep for a couple of secs and try again
      select(nil,nil,nil,2)
      if (driver.remotebeef.session.authenticate(args[0], args[1], args[2]).nil?)
        print_status("Connection failed..")
      else
        print_status("Connected to "+args[0])
      end
    else
      print_status("Connected to "+args[0])
    end
  end
  
  def cmd_connect_help
    print_status("  Usage: connect <beef url> <username> <password>")
    print_status("Examples:")
    print_status("  connect http://127.0.0.1:3000 beef beef")
  end
  
  def cmd_status(*args)
    begin
      if driver.remotebeef.session.connected
        print_status("You are connected to "+driver.remotebeef.session.baseuri)
      else
        print_status("You are not connected")
      end
    rescue
      print_status("You are not connected")
    end
  end
  
  def cmd_status_help
    print_status("Show your online status")
  end
  
  def cmd_disconnect(*args)
    begin
      driver.remotebeef.session.disconnect
      print_status("You are now disconnected")
      if (driver.dispatcher_stack.size > 1 and
  	      driver.current_dispatcher.name != 'Core' and
  	      driver.current_dispatcher.name != 'Remote Control')

  	      driver.destack_dispatcher

  	      driver.update_prompt('')
      end
    rescue
      print_status("You weren't even connected in the first place d'uh")
    end
  end
  
  def cmd_disconnect_help
    print_status("Disconnect from the remote BeEF instance")
  end
  
  def cmd_online(*args)
    if driver.remotebeef.session.connected.nil?
      print_status("You don't appear to be connected, try \"connect\" first")
      return
    end
    
    hb = driver.remotebeef.zombiepoll.hooked
    tbl = Rex::Ui::Text::Table.new(
      'Columns' => 
        [
          'Id',
          'IP',
          'OS'
        ])
    hb['hooked-browsers']['online'].each{ |x|
      tbl << [x[0].to_s , x[1]['ip'].to_s, beef_logo_to_os(x[1]['os_icon'].to_s)]
    }
    puts "\n"
    puts "Currently hooked browsers within BeEF"
    puts "\n"
    puts tbl.to_s + "\n"
  end
  
  def cmd_online_help
    print_status("Show currently hooked browsers within BeEF")
  end
  
  def cmd_offline(*args)
    if driver.remotebeef.session.connected.nil?
      print_status("You don't appear to be connected, try \"connect\" first")
      return
    end
    
    hb = driver.remotebeef.zombiepoll.hooked
    tbl = Rex::Ui::Text::Table.new(
      'Columns' => 
        [
          'Id',
          'IP',
          'OS'
        ])
    hb['hooked-browsers']['offline'].each{ |x|
      tbl << [x[0].to_s , x[1]['ip'].to_s, beef_logo_to_os(x[1]['os_icon'].to_s)]
    }
    puts "\n"
    puts "Previously hooked browsers within BeEF"
    puts "\n"
    puts tbl.to_s + "\n"
  end
  
  def cmd_offline_help
    print_status("Show previously hooked browsers")
  end
  
  def cmd_target(*args)
    if driver.remotebeef.session.connected.nil?
      print_status("You don't appear to be connected, try \"connect\" first")
      return
    end
    
    if (args[0] == nil or args[0] == "-h")
      cmd_target_help
      return
    end
    
    driver.remotebeef.settarget(args[0])
    
    if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core' and
	      driver.current_dispatcher.name != 'Remote Control')

	      driver.destack_dispatcher

	      driver.update_prompt('')
    end
    
    driver.enstack_dispatcher(Target)
    
    driver.update_prompt("(%bld%red"+driver.remotebeef.targetip+"%clr) ["+driver.remotebeef.target.to_s+"] ")
    
  end
  
  def cmd_target_help
    print_status("Target a selected online hooked browser")
    print_status("  Usage: target <id>")
  end
  
  def cmd_review(*args)
    if driver.remotebeef.session.connected.nil?
      print_status("You don't appear to be connected, try \"connect\" first")
      return
    end
    
    if (args[0] == nil or args[0] == "-h")
      cmd_review_help
      return
    end
    
    driver.remotebeef.setofflinetarget(args[0])
    
    if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core' and
	      driver.current_dispatcher.name != 'Remote Control')

	      driver.destack_dispatcher

	      driver.update_prompt('')
    end
    
    driver.enstack_dispatcher(Target)
    
    driver.update_prompt("(%bld%red"+driver.remotebeef.targetip+"%clr) ["+driver.remotebeef.target.to_s+"] ")    
  end
  
  def cmd_review_help
    print_status("Review a previously hooked browser (an offline browser)")
    print_status("  Usage: review <id>")
  end
  
  def cmd_onlinepoll
    driver.remotebeef.jobs.start_bg_job(
      "OnlinePoller",
      driver.output,
      Proc.new { |ctx_| driver.remotebeef.zombiepoll.hookedpoll(ctx_) }
    )
  end
  
  def cmd_onlinepoll_help
    print_status("Kick off a background job to notify if you browsers hook or unhook")
  end
  
end


end end end end