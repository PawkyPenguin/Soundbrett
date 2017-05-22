#!/usr/bin/env ruby

class Keyhandler
	@cursor_pos
	@keybinder
	@drawer
	@rebind_mode

	def initialize(keybinder, drawer)
		@cursor_pos = 0
		@keybinder = keybinder
		@drawer = drawer
	end

	def user_input(shortcut)
		case shortcut
		when KEY_UP
			cursor_up
		when KEY_DOWN
			cursor_down
		when KEY_DC
			@rebind_mode = !@rebind_mode
			@drawer.update_rebind_mode(@rebind_mode, @cursor_pos)
		when KEY_RIGHT
			play_file @keybinder.bindings[@keybinder.filelist[@cursor_pos]]
		when KEY_LEFT
			exit 0
		when /[[:ascii:]]/
			if @rebind_mode
				if (new_binding(shortcut))
					@rebind_mode = false
					@drawer.update_rebind_mode(@rebind_mode, @cursor_pos)
				end
			else
				play_file shortcut
			end
		end

	end

	def cursor_up
		old_cursor = @cursor_pos
		@cursor_pos = (@cursor_pos - 1) % @keybinder.filelist.length
		@drawer.cursor_up(old_cursor, @cursor_pos)
	end

	def cursor_down
		old_cursor = @cursor_pos
		@cursor_pos = (@cursor_pos + 1) % @keybinder.filelist.length
		@drawer.cursor_down(old_cursor, @cursor_pos)
	end

	def new_binding(shortcut)
		if @keybinder.bindings.has_value? shortcut
			return false
		end
		@keybinder.new_binding(shortcut, @cursor_pos)
		@drawer.new_binding(shortcut, @cursor_pos)
		return true
	end

	def play_file(shortcut)
		if !@keybinder.bindings.has_value? shortcut
			return
		end
		filepath = @keybinder.path + @keybinder.bindings.key(shortcut)
		if has_mpv
			system("mpv --really-quiet #{filepath}")
		elsif has_mplayer
			system("mplayer #{filepath} > /dev/null 2&>1")
		end
	end

	def has_mplayer
		system("mplayer -v > /dev/null")
		return "#{$?}".end_with? ' 0'
	end

	def has_mpv
		system("mpv -v > /dev/null")
		return "#{$?}".end_with? ' 0'
	end


		
end
