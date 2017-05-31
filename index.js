#!/usr/bin/env node
const packageJson = require('./package.json');
const commander = require('commander');
const mustache = require('mustache');
const fs = require('fs-extra');
const klawSync = require('klaw-sync');
const { sep, resolve } = require('path');
const uuid = require('uuid');

commander
  .version(packageJson.version)
  .option('-t, --title <string>', 'specify game name')
  .option('-m, --memory [bytes]', 'how much memory your game will require [16777216]', 16777216)
  .arguments('<input> <output>')
  .action((input, output) => {
    commander.input = input;
    commander.output = output;
  });
commander._name = 'love.js'; // eslint-disable-line no-underscore-dangle
commander.parse(process.argv);

const isDirectory = function isDirectory(path) {
  return fs.statSync(path).isDirectory();
};

// prompt for args left out of the cli invocation
const getAdditionalInfo = async function getAdditionalInfo(parsedArgs) {
  const prompt = function prompt(msg) {
    return new Promise((done) => {
      process.stdout.write(msg);
      process.stdin.setEncoding('utf8');
      process.stdin.once('data', (val) => {
        process.stdin.unref();
        done(val.trim());
      });
    });
  };

  const args = {
    memory: parsedArgs.memory,
    input: parsedArgs.input,
    output: parsedArgs.output,
  };
  args.input = parsedArgs.input || await prompt('Love file or directory: ');
  args.output = parsedArgs.output || await prompt('Output directory: ');
  args.title = parsedArgs.title || await prompt('Game name: ');

  if (isDirectory(args.input)) {
    args.arguments = JSON.stringify(['./']);
  } else {
    args.arguments = JSON.stringify(['./game.love']);
  }

  return args;
};

const getFiles = function getFiles(input) {
  const stats = fs.statSync(input);
  if (stats.isDirectory()) {
    return klawSync(input, { nodir: true });
  }
  // It should be a .love file
  return [{
    path: resolve(input),
    stats,
  }];
};

getAdditionalInfo(commander).then((args) => {
  const outputDir = resolve(args.output);
  const srcDir = resolve(__dirname, 'src');

  const files = getFiles(args.input);
  const dirs = isDirectory(args.input) ? klawSync(args.input, { nofile: true }) : [];
  const dirRelativePaths = dirs.map(f => f.path.replace(new RegExp(`^.*${args.input}`), ''));

  const createFilePaths = dirRelativePaths.map((path) => {
    const splits = path.split(sep);
    const length = splits.length - 1;
    const directoryPath = splits.slice(0, length).join('/') || '/';
    return `Module['FS_createPath']('${directoryPath}', '${splits[length]}', true, true);`;
  });

  const AUDIO_SUFFIXES = ['.ogg', '.wav', '.mp3'];
  const fileMetadata = [];
  const fileBuffers = [];
  let currentByte = 0;
  for (let i = 0; i < files.length; i += 1) {
    const file = files[i];
    const relativePath = isDirectory(args.input) ?
                            file.path.replace(new RegExp(`^.*${args.input}`), '') :
                            '/game.love';
    const buffer = fs.readFileSync(file.path);
    fileMetadata.push({
      filename: relativePath,
      crunched: 0,
      start: currentByte,
      end: currentByte + buffer.length,
      audio: AUDIO_SUFFIXES.reduce((isAudio, suffix) => isAudio || file.path.endsWith(suffix), false),
    });

    currentByte += buffer.length;
    fileBuffers.push(buffer);
  }
  const totalBuffer = Buffer.concat(fileBuffers);

  const jsArgs = {
    create_file_paths: createFilePaths.join('\n      '),
    metadata: JSON.stringify({
      package_uuid: uuid(),
      remote_package_size: totalBuffer.length,
      files: fileMetadata,
    }),
  };
  const gameTemplate = fs.readFileSync(`${srcDir}/game.js`, 'utf8');
  const renderedGameTemplate = mustache.render(gameTemplate, jsArgs);

  fs.mkdirsSync(`${outputDir}`);

  {
    const template = fs.readFileSync(`${srcDir}/release/index.html`, 'utf8');
    const renderedTemplate = mustache.render(template, args);

    fs.mkdirsSync(`${outputDir}/release`);
    fs.writeFileSync(`${outputDir}/release/index.html`, renderedTemplate);
    fs.writeFileSync(`${outputDir}/release/game.js`, renderedGameTemplate);
    fs.writeFileSync(`${outputDir}/release/game.data`, totalBuffer);
    fs.copySync(`${srcDir}/release/love.js`, `${outputDir}/release/love.js`);
    fs.copySync(`${srcDir}/release/love.js.mem`, `${outputDir}/release/love.js.mem`);
    fs.copySync(`${srcDir}/release/pthread-main.js`, `${outputDir}/release/pthread-main.js`);
    fs.copySync(`${srcDir}/release/theme`, `${outputDir}/release/theme`);
  }

  {
    const template = fs.readFileSync(`${srcDir}/debug/index.html`, 'utf8');
    const renderedTemplate = mustache.render(template, args);

    fs.mkdirsSync(`${outputDir}/debug`);
    fs.writeFileSync(`${outputDir}/debug/index.html`, renderedTemplate);
    fs.writeFileSync(`${outputDir}/debug/game.js`, renderedGameTemplate);
    fs.writeFileSync(`${outputDir}/debug/game.data`, totalBuffer);
    fs.copySync(`${srcDir}/debug/love.js`, `${outputDir}/debug/love.js`);
    fs.copySync(`${srcDir}/debug/pthread-main.js`, `${outputDir}/debug/pthread-main.js`);
  }
});
