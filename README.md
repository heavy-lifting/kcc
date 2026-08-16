I can't remember anything so I made a readme
Now I have to remember how everything works so I can document it

... okay I founds some notes on my computer hehe

editor dev notes

Create basic code editor Control > codeedit - changed layout cause it was weirdly super zoomed in by default

Added BootTidal.hs to project (copied existing one on my machine)

okay wait i didn't keep notes but It's all in gemini and is basically fine. Even the export essentially works

Ideas:
- settings/config - e.g. location of BootTidal.hs
- turn on/off various default features (text animation etc)
- ~~ability to print to console direct from text editor~~
- maybe some kind of "caw mode" a la ravioli where I can switch to a non-coding mode that does different stuff - like maybe controlling the sprites?
- animated text
- code-able editor (e.g. colours, fonts, scroll, etc)
- some nice image box to put a nice image in
- some way to set a background image/colour
- ~~autoscroll in post window~~
- Ctrl+Enter highlight line
- FIX TIDAL OSC DOCS THEY ARE SO BAD
- some kind of UI for settings (colour palette)
- make osc implementation more friendly - give things nicer names etc (see also what Nik did with routing s and n via osc to tixl)
- multi-line eval
- bubbles
- someone can control a character with a controller



ABSOLUTELY PAINFUL TIME trying to get OSC working but got there in the end (sort of... I can send it out from tidal but I'm not yet picking it up in godot)


res://BootTidal.hs

`d1 $ oscS "red blue" # oscName "text"` - to control editor params

`say your message here` - prints messages

## palettes
Want to work on putting in some nice palettes so it all looks coherent (also allow swapping on the fly which could be fun)

So my pixel bunny palette (based on pnk and green) is like this:
	# FF008CFF
	# 1FFF0FFF
	# FF89CAFF
	# 82FF80FF
	# FFDFF1FF
	# E3FFE6FF
	# 814365FF
	# 428243FF
	# 462A39FF
	# 294527FF
	# 282326FF
	# 212921FF

- you canblend between colours with lerp red.lerp(aqua, 0.2) # Returns Color(0.8, 0.2, 0.16)

- maybe the colours want "roles" (like light/dark/complementary/contrast etc)
