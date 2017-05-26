# Soundbrett

Soundbrett is a small soundboard for the commandline written in Ruby. Soundbrett automatically assigns hotkeys to the soundfiles you give to it. The hotkeys can be rebound.
To install, simply clone the git repository. Soundbrett has a dependency on mpv *or* mplayer!

## Dependencies

- ruby
- [ruby-curses](https://github.com/ruby/curses)
- mpv or mplayer

## Controls

To close Soundbrett, press the right arrow key. To play a soundfile, either press the right arrow key, which plays the selected file, or press the associated hotkey.
To rebind the hotkey of a soundfile, press Delete, and afterwards press the new hotkey. If the hotkey is already assigned, nothing will happen.
To stop playing a soundfile, press `q`.

## Usage

Simply execute soundbrett.rb and pass as an argument the directory your soundfiles reside in.

`./soundbrett.rb files/`

## Missing features

These are features I plan to implement in the future (TM).

* Support for persistent hotkeys with the help of configfiles (already somewhat began with it)
* Adjustment of width and height for smaller terminals
* Display "now playing" text
