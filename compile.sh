python emscripten/tools/file_packager.py release-compatibility/game.data --preload ./debug/[path-to-game]@/ --js-output=release-compatibility/game.js
cd release-compatibility
rm add.zip
zip -r add.zip . -x "release-compatibility/index.html"
sleep 2s
python -m SimpleHTTPServer 8000
