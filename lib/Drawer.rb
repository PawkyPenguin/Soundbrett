#!/usr/bin/env ruby
require 'curses'
include Curses

class Drawer

	Margin_top = 2
	Margin_bot = 2
	Margin_left = 3
	Margin_right = 3
	Margin_key = 3
	Margin_cursor_top = 3
	Margin_cursor_bot = 3
	@window
	@filelist
	@width
	@height
	@virtual_cursor
	@keybinder

	def initialize(keybinder)
		@virtual_cursor = 0
		@keybinder = keybinder
		@width = 50
		for file in @keybinder.filelist
			if file.length > @width
				@width = file.length
			end
		end
		@height = 50
		@display_range = (0...filelist_height)


		setpos((lines - @width) / 2, (cols - @height) / 2)	

		@window = Window.new(@height, @width, (lines - @height) / 2, (cols - @width) / 2)
		@window.keypad = true
		draw_files
		draw_bindings

		highlight_file(@keybinder.filelist[0])
		@window.box('|', '-')
		@window.refresh
	end

	def setpos_topleft_files
		@window.setpos(Margin_top, Margin_left + Margin_key)
	end

	def setpos_topleft_keys
		@window.setpos(Margin_top, cursor_pos_keybindings)
	end


	def getch
		return @window.getch
	end

	def new_binding(shortcut, filenum)
		@window.setpos(Margin_top + filenum, cursor_pos_keybindings)
		@window.addstr(shortcut[0])
	end

	def cursor_up(cur_old, cur_new)
		# remove highlight of previously highlighted file
		if cur_new > cur_old
			# We wrapped around. virtual cursor is the last entry
			@virtual_cursor = [filelist_height, @keybinder.filelist.length].min - 1
			@display_range = (@keybinder.filelist.length - filelist_height...@keybinder.filelist.length)
		else
			@virtual_cursor -= 1
		end

		adjusted = reset_virtual_cursor?
		if adjusted
			# If the cursor has been reset, we need to move the range
			@display_range += -1
		end

		draw_files
		draw_bindings
		# highlight new file
		highlight_file(@keybinder.filelist[cur_new])
	end
	
	def cursor_down(cur_old, cur_new)
		# remove highlight of previously highlighted file
		if cur_new < cur_old
			# We wrapped around. virtual cursor is the first entry
			@virtual_cursor = 0
			@display_range = (0...filelist_height)
		else
			@virtual_cursor += 1
		end

		adjusted = reset_virtual_cursor?
		if adjusted
			# If the cursor has been reset, we need to move the range
			@display_range += 1
		end

		draw_files
		draw_bindings
		# highlight new file
		highlight_file(@keybinder.filelist[cur_new])
	end

	def highlight_file(filename)
		@window.setpos(Margin_top + @virtual_cursor, cursor_pos_files)
		@window.attrset(A_REVERSE)
		@window.addstr(filename)
		@window.attrset(A_NORMAL)
	end

	def unhighlight_file(filename)
		# remove highlight of previously highlighted file
		@window.setpos(Margin_top + @virtual_cursor, cursor_pos_files)
		@window.addstr(filename)
	end

	def reset_virtual_cursor?
		if @virtual_cursor < Margin_cursor_top && @display_range.first > 0
			# If the virtual cursor is too close to the top, move it down to the margin
			@virtual_cursor = Margin_cursor_top
			return true
		elsif @virtual_cursor > @display_range.size - Margin_cursor_bot - 1 && @display_range.last < @keybinder.filelist.length 
			# If the virtual cursor is too close to the bottom, move it up until the margin is not violated anymore
			@virtual_cursor = @display_range.size - Margin_cursor_bot - 1
			return true
		else
			# Margin_cursor_top didn't have to be adjusted
			return false
		end
	end
	
	def cursor_pos_files
		return Margin_left + Margin_key
	end

	def cursor_pos_keybindings
		return Margin_left + 1
	end

	def draw_files
		setpos_topleft_files
		for i in @display_range
			filename = @keybinder.filelist[i]
			if !filename
				next
			end
			if filename.length > filelist_width
				filename = filename[0...filelist_width]
			end
			@window.addstr(filename + " " * (filelist_width - filename.length))
			@window.setpos(@window.cury() + 1, cursor_pos_files)
		end
	end

	def draw_bindings
		setpos_topleft_keys
		for i in @display_range
			file = @keybinder.filelist[i]
			if @keybinder.bindings[file]
				@window.addstr(@keybinder.bindings[file])
			end
			@window.setpos(@window.cury() + 1, cursor_pos_keybindings)
		end
	end

	def filelist_height
		return @height - Margin_top - Margin_bot
	end

	def filelist_width
		return @width - Margin_left - Margin_key - Margin_right
	end
end

module RangeAdder
  def +(value)
    new_begin = self.begin + value
    new_end = self.end + value
    Range.new(new_begin, new_end, self.exclude_end?)
  end
end

class Range
  include RangeAdder
end
