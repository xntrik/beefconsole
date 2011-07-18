require 'beef/ui/console/command_dispatcher'

module BeEF
module Ui
module Console

class Driver < BeEF::Ui::Driver

	DefaultPrompt     = "%undBeEF%clr"
	DefaultPromptChar = "%clr>"

	include Rex::Ui::Text::DispatcherShell

	def initialize(prompt = DefaultPrompt, prompt_char = DefaultPromptChar, opts = {})

		rl = false
		rl_err = nil
		begin
			if(opts['RealReadline'])
				require 'readline'
				rl = true
			end
		rescue ::LoadError
			rl_err = $!
		end

		require 'readline_compatible' if(not rl)

		super(prompt, prompt_char, File.expand_path("~/.beef/history"))

		input = Rex::Ui::Text::Input::Stdio.new
		output = Rex::Ui::Text::Output::Stdio.new

		init_ui(input,output)
		#init_tab_complete	#xntrik lets not worry about this yet
		
		self.remotebeef = BeEF::Remote::Base.new
		
		enstack_dispatcher(CommandDispatcher::Core) #doing this now?
		enstack_dispatcher(CommandDispatcher::Remote)


		@defanged = false
		#self.command_passthru = true
		
		if opts['Host'] and opts['Username'] and opts['Password']
		  
		  if (self.remotebeef.session.authenticate(opts['Host'],opts['Username'],opts['Password']).nil?)
		    #For some reason, the first connection often doesn't work, lets sleep for a couple of seconds and try again
		    select(nil,nil,nil,2)
		    if (self.remotebeef.session.authenticate(opts['Host'],opts['Username'],opts['Password']).nil?)
          print_status("Connection failed..")
        else
          print_status("Connected to "+opts['Host'])
        end
      else
        print_status("Connected to "+opts['Host'])
      end
	  end
	end

	attr_accessor :remotebeef

	#attr_reader :command_passthru

	#attr_accessor :active_module

	#attr_accessor :active_session

	def stop
		#framework.events.on_ui_stop()
		super
	end
	
	#New method to determine if a particular command dispatcher it already .. enstacked .. gooood
	def dispatched_enstacked(dispatcher)
	  inst = dispatcher.new(self)
	  self.dispatcher_stack.each { |disp|
	    if (disp.name == inst.name)
	      return true
      end
    }
    return false
  end

protected

	#attr_writer :remotebeef
	#attr_writer :command_passthru
end

end end end
