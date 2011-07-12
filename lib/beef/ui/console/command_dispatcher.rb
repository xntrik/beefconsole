module BeEF
module Ui
module Console

module CommandDispatcher
	include Rex::Ui::Text::DispatcherShell::CommandDispatcher

	def initialize(driver)
		super

		self.driver = driver
		#self.driver.on_command_proc = Proc.new { |command| framework.events.on_ui_command(command) }

	end

	def framework
		return driver.framework
	end

	def active_module
		driver.active_module
	end

	def active_module=(mod)
		driver.active_module = mod
	end

	def active_session
		driver.active_session
	end

	def active_session=(mod)
		driver.active_session = mod
	end

	def defanged?
		driver.defanged?
	end

	def log_error(err)
		print_error(err)
		wlog(err)
		dlog("Call stack:\n#{$@.join("\n")}", 'core', LEV_1)
	end

	attr_accessor :driver

end

end end end

require 'beef/ui/console/command_dispatcher/core'
require 'beef/ui/console/command_dispatcher/remote'
require 'beef/ui/console/command_dispatcher/target'
require 'beef/ui/console/command_dispatcher/module'
