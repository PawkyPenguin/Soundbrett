#!/usr/bin/env ruby
require './lib/Drawer.rb'
require './lib/Keyhandler.rb'
require './lib/Keybinder.rb'
require 'curses'

# initiliaze keybinder
path = File.absolute_path ARGV[0]
keybinder = Keybinder.new path

begin
	Curses.init_screen
	Curses.noecho
	Curses.raw
	Curses.curs_set(0)
	drawer = Drawer.new(keybinder)
	# initiliaze drawer and keyhandler
	keyhandler = Keyhandler.new(keybinder,drawer)
	while true
		inputkey = drawer.getch
		keyhandler.user_input inputkey
	end
ensure
	Curses.close_screen
end

