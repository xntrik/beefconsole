module BeEF
module Ui
module Console
module CommandDispatcher

class Core
	include BeEF::Ui::Console::CommandDispatcher
	
	@@jobs_opts = Rex::Parser::Arguments.new(
	  "-h" => [ false, "Help."              ],
	  "-l" => [ false, "List jobs."         ],
	  "-k" => [ true, "Terminate the job."  ])

	def commands
		{
			"?"		=> "Help menu",
			"back"    => "Move back from the current context",
			"exit"		=> "Exit the console",
			"help"		=> "Help menu",
			"jobs"    => "Print jobs",	
			"quit"		=> "Exit the console",
			"show"    => "Displays 'zombies' or 'browsers' or 'commands'. (For those who prefer the MSF way)",
			"version"	=> "Show the version",
		}
	end

	def initialize(driver)
		super

		@dscache = {}
		@cache_payloads = nil
	end

	def name
		"Core"
	end

	def cmd_exit(*args)
		#forced = false
		#forced = true if (args[0] and args[0] =~ /-y/i)

		#if(framework.sessions.length > 0 and not forced)
		#	print_status("You have active sessions open, to exit anyway type \"exit -y\"")
		#	return
		#end

		driver.stop
	end
	
	def cmd_exit_help
	  print_status("Quit the BeEF Console")
  end

  alias cmd_quit_help cmd_exit_help
	alias cmd_quit cmd_exit

	def cmd_version(*args)
		ver = "Version #{$BeefVer}"

		print_line(ver)
		return true
	end
	
	def cmd_back
	  if (driver.current_dispatcher.name == 'Module')
	    driver.remove_dispatcher('Module')
	    driver.remotebeef.command.clearmodule
	    driver.update_prompt("(%bld%red"+driver.remotebeef.targetip+"%clr) ["+driver.remotebeef.target.to_s+"] ")
	  elsif (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core' and
	      driver.current_dispatcher.name != 'Remote Control')
	      
	      driver.destack_dispatcher
	      
	      driver.update_prompt('')
    end
  end
  
  def cmd_back_help
    print_status("Move back one step")
  end
  
  def cmd_jobs(*args)
    if (args[0] == nil)
      cmd_jobs_list
      print_line "Try: jobs -h"
      return
    end
    
    @@jobs_opts.parse(args) {|opt, idx, val|
      case opt
        when "-k"
          if (not driver.remotebeef.jobs.has_key?(val))
            print_error("no such job")
          else
            print_line("Stopping job: #{val}...")
            driver.remotebeef.jobs.stop_job(val)
          end
        when "-l"
          cmd_jobs_list
        when "-h"
          cmd_jobs_help
          return false
        end
      }
  end
  
  def cmd_jobs_help
    print_line "Usage: jobs [options]"
    print_line
    print @@jobs_opts.usage()
  end
  
  def cmd_jobs_list
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'Job Name'
        ])
    driver.remotebeef.jobs.keys.each{|k|
      tbl << [driver.remotebeef.jobs[k].jid.to_s, driver.remotebeef.jobs[k].name]
    }
    puts "\n"
    puts tbl.to_s + "\n"
  end
  
  def cmd_show(*args)
    args << "-h" if (args.length == 0)
    
    args.each { |type|
      case type
      when '-h'
        cmd_show_help
      when 'zombies'
        driver.run_single("online")
      when 'browsers'
        driver.run_single("online")
      when 'online'
        driver.run_single("online")
      when 'offline'
        driver.run_single("offline")
      when 'commands'
        if driver.dispatched_enstacked(Target)
          driver.run_single("commands")
        else
          print_error("You aren't targeting a zombie yet")
        end
      when 'info'
        if driver.dispatched_enstacked(Target)
          driver.run_single("info")
        else
          print_error("You aren't targeting a zombie yet")
        end
      when 'modinfo'
        if driver.dispatched_enstacked(Module)
          driver.run_single("modinfo")
        else
          print_error("You haven't selected a command module yet")
        end
      else
        print_error("Invalid parameter, try show -h for more information.")
      end
    }
  end
  
  def cmd_show_tabs(str, words)
    return [] if words.length > 1
    
    res = %w{zombies browsers online offline}    
    
    if driver.dispatched_enstacked(Target)
      res.concat(%w{commands info})
    end
    
    if driver.dispatched_enstacked(Module)
      res.concat(%w{modinfo})
    end
    
    return res
  end
  
  def cmd_show_help
    global_opts = %w{zombies browsers}
    print_status("Valid parameters for the \"show\" command are: #{global_opts.join(", ")}")
    
    target_opts = %w{commands}
    print_status("If you're targeting a module, you can also specify: #{target_opts.join(", ")}")
  end
end

end end end end
