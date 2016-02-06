Love.js
============

This is [LÖVE](https://love2d.org/) ported to the web using [Emscripten](https://kripken.github.io/emscripten-site/).

It differs from [Motor](https://github.com/rnlf/motor) or [Punchdrunk](https://github.com/TannerRogalsky/punchdrunk) in that it is not a reimplementation but a direct port of the existing LÖVE v0.10.0 code with very few code modifications. As such, it should be at feature parity, as long as the browser it's running in supports a given feature.

##Examples
Here are two live games:

- [Friendshape](http://tannerrogalsky.com/friendshape)
- [Mr. Rescue](http://tannerrogalsky.com/mrrescue/)

##Dependencies
- Python

Python will allow you to package your game into a format that Emscripten can read. It will also let you run a simple web server for testing.

##Usage
1. Navigate into the `debug` folder.
2. Package your game.
  - `python ../file_packager.py game.data --preload [path-to-game]@/ --js-output=game.js`
  - This should output two files: `game.data` and `game.js` into the `debug` folder.
  - Make you include the '@/' after the path to your game source. This will tell the file packager to place your game at the root of Emscripten's file system.
3. Run a web server.
  - `python -m SimpleHTTPServer 8000` will work.
4. Open `localhost:8000` in the browser of your choice.

##Issues
Some things, like threads, don't have browser support yet. Please check the project issues for known problems.

##Contributing
The build process for this project is still a very manual process and is not ready to be shared. Feel free to keep an eye on the `emscripten` branch of [my LÖVE fork](https://bitbucket.org/TannerRogalsky/love) if you're really curious.
