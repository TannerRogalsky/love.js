Love.js
============

This is [LÖVE](https://love2d.org/) ported to the web using [Emscripten](https://kripken.github.io/emscripten-site/).

It differs from [Motor](https://github.com/rnlf/motor) or [Punchdrunk](https://github.com/TannerRogalsky/punchdrunk) in that it is not a reimplementation but a direct port of the existing LÖVE code with very few code modifications. As such, it should be at feature parity, as long as the browser it's running in supports a given feature.

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

## Contributing
Please consider submitting a test. Any functionality that isn't covered in `spec/tests` would be very useful.
