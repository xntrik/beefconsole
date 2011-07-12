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
			"help"		=> "Help menu",
			"version"	=> "Show the version",
			"quit"		=> "Exit the console",
			"exit"		=> "Exit the console",
			"back"    => "Move back from the current context",
			"jobs"    => "Print jobs",
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

	alias cmd_quit cmd_exit

	def cmd_version(*args)
		ver = "blah"

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
    driver.remotebeef.jobs.keys.each{|k|
      print_line(driver.remotebeef.jobs[k].jid.to_s + " - " + driver.remotebeef.jobs[k].name)
    }
    print_line
  end
end

end end end end
