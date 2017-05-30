Love.js
============
[![Travis](https://img.shields.io/travis/TannerRogalsky/love.js.svg)]() [![npm](https://img.shields.io/npm/v/love.js.svg)]()

This is [LÖVE](https://love2d.org/) ported to the web using [Emscripten](https://kripken.github.io/emscripten-site/). Or, more accurately, it is a tool to help you package your LÖVE game for the web as easily as possible.

Love.js differs from [Motor](https://github.com/rnlf/motor) or [Punchdrunk](https://github.com/TannerRogalsky/punchdrunk) in that it is not a reimplementation but a direct port of the existing LÖVE code with very few code modifications. As such, it should be at feature parity, as long as the browser it's running in supports a given feature.

## Usage
`love.js [options] <input> <output>`

`<input>` can either be a folder or a `.love` file.
`<output>` is a folder that will hold debug and release web pages.

## Options:
```
-h, --help            output usage information
-V, --version         output the version number
-t, --title <string>  specify game name
-m, --memory [bytes]  how much memory your game will require [16777216]
```

### Test it
1. Run a web server.
  - `python -m SimpleHTTPServer 8000` will work.
2. Open `localhost:8000` in the browser of your choice.

## Notes
- I strongly recommend that you package your game for release using another tool before using this tool to build it for the web. Using something like [love-release](https://github.com/MisterDA/love-release) to remove unused files and metadata and compress the game into a .love file will make running the game much faster.
- Because of the way that Emscripten works, you must specify the maximum amount of memory that your game will require. Make sure you test your game thoroughly to ensure that you've allocated enough memory because your game will crash if you have not.

## Contributing
Please consider submitting a test. Any functionality that isn't covered in `spec/tests` would be very useful.
