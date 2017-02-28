# Spotify to  Music Converter
------
Import your Spotify Playlists to Apple Music!

## Cool! How do I use this though?
Okay, now to be honest I built this for myself, so it's not very user-friendly. For those willing to take the effort, here's a tutorial on how to use this:

1. Get a Mac, this won't run on Windows
2. Download [Xcode](https://itunes.apple.com/de/app/xcode/id497799835?mt=12) and open it once to install all it's ~~shit~~ stuff
3. Shoot up a Terminal (⌘+Space → *Terminal*)
4. Clone this repo to your Desktop (or somewhere you like) by typing `cd ~/Desktop; git clone https://github.com/finngaida/spotify2applemusic.git; cd spotify2applemusic` and hitting enter
5. Now we need to get your Spotify List converted. Go to [Exportify](https://rawgit.com/watsonbox/exportify/master/exportify.html), log in, select your playlist and copy **ALL** the text on screen
6. Now create a new file called `spotify.csv` and paste in the stuff you just copied. You can do this anyway you like, I prefer the terminal: `touch spotify.csv; nano spotify.csv` → _* paste *_ → _* ctrl+x *_ → _* y *_
7. Okay now it gets tricky, we need [python 3](https://www.python.org/downloads/mac-osx/) for the next step, so go ahead and install that if you haven't got it on your machine
8. Done? Cool, back in the terminal type `python3 retrieve-identifiers.py` and wait until it returns you to the `$`, you should now have a file called `itunes.csv` in your directory. This script is from [simonschellaert](https://github.com/simonschellaert/spotify2am).
9. Now you can open up the Xcode project, connect your phone, select your **developer account** for signing and hit Run.
10. This will install the app onto your phone, press the humongous ***"GO"*** button to add the songs to your playlist
11. ???
12. Profit

## But why?
Some people like me wanted to switch from Spotify to Apple Music, but didn't want to lose all their playlists, so here ya go

## Can I use that?
I don't know if you can, but you may, this project is licensed [MIT](LICENSE), so you can even redistribute it, as long as you mention me somehow.