#!/usr/bin/env ruby

require 'digest'

class Keybinder
	attr_reader :filelist
	attr_reader :bindings
	attr_reader :path
	@path
	@filelist
	@bindings
	@configpath

	def initialize(path)
		@path = path + '/'
		@filelist = Dir.glob("#{File.expand_path path}/*").map { |x| File.basename x }
		@configpath = get_config_path path
		@bindings = {}

		# Get keybindings from config
		begin
			File.open(@configpath, 'r') do |configfile|
				# Load binding variables
				for line in configfile.lines
					shortcut, file = *line.split[' '][0..1]
					@bindings[file] = shortcut
				end
			end
		rescue
		end
		
		# If a file doesn't have a binding, give it one
		for i in (0...@filelist.length)
			file = @filelist[i]
			if !@bindings[file]
				new_key = get_unassigned_key
				new_binding(new_key,i) unless !new_key
			end
		end
	
	end

	# Returns absolute path of config file
	def get_config_path(directory_path)
		xdg_home = ENV['XDG_CONFIG_HOME']
		if xdg_home
			configpath = File.expand_path('~/.config/soundbrett/')
		else
			configpath = File.expand_path("#{xdg_home}/soundbrett/")
		end
		# Hash the directory_path, so we get a separate config file for each path.
		configfilename = Digest::SHA256.hexdigest(directory_path)
		return configpath + '/' + configfilename
	end

	def write_config_file()
		File.open(@configpath, 'w') do |file|
			@bindings.each_pair do |key, value|
				file.puts("#{value}, #{key}")
			end
		end
	end

	# Return a key that is unused yet
	def get_unassigned_key
		for letter in [*'a'..'z', *'1'..'9', '0', *'A'..'Z']
			if !@bindings.has_value? letter
				return letter
			end
		end
	end

	def new_binding(shortcut, file_number)
		@bindings[@filelist[file_number]] = shortcut
	end

end
