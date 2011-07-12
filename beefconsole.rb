#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'optparse'
require 'rubygems'

class OptsConsole
	def self.parse(args)
		options = {}

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: beefconsole [options]"

			opts.separator ""
			opts.separator "Specific Options:"

			opts.on("-v", "--version", "Show version") do |v|
				options['Version'] = true
			end
			
			opts.on("-c", "-c http://host:port", "Connect to the specified host") do |c|
			  options['Host'] = c
		  end
		  
		  opts.on("-u", "-u username", "Connect using the specified username") do |u|
		    options['Username'] = u
	    end
	    
	    opts.on("-p", "-p password", "Connect using the specified password") do |p|
	      options['Password'] = p
      end

			opts.on_tail("-h", "--help", "Show this message") do
				puts opts
				exit
			end
		end

		begin
			opts.parse!(args)
		rescue OptionParser::InvalidOption
			puts "Invalid option, try -h for usage"
			exit
		end

		options
	end
end

options = OptsConsole.parse(ARGV)

require 'rex'
require 'beef/ui'

if (options['Version'])
	$stderr.puts 'Version blah'
	exit
end

begin
	FileUtils.mkdir_p(File.expand_path("~/.beef/"))
	BeEF::Ui::Console::Driver.new(
		BeEF::Ui::Console::Driver::DefaultPrompt,
		BeEF::Ui::Console::Driver::DefaultPromptChar,
		options
	).run
rescue Interrupt
end
