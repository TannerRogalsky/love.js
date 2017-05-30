#!/usr/bin/env node
const packageJson = require('./package.json');
const commander = require('commander');
const mustache = require('mustache');
const fs = require('fs-extra');
const klawSync = require('klaw-sync');
const path = require('path');
const uuid = require('uuid');

commander
  .version(packageJson.version)
  .option('-t, --title <string>', 'specify game name')
  .option('-m, --memory [bytes]', 'how much memory your game will require [16777216]', parseInt, 16777216)
  .arguments('<input> <output>')
  .action(function (input, output) {
    commander.input = input;
    commander.output = output;
  });
commander._name = 'love.js';
commander.parse(process.argv);

// prompt for args left out of the cli invocation
const getAdditionalInfo = async function getAdditionalInfo(parsedArgs) {
  const prompt = function prompt(msg) {
    return new Promise((resolve) => {
      process.stdout.write(msg);
      process.stdin.setEncoding('utf8');
      process.stdin.once('data', (val) => {
        process.stdin.unref();
        resolve(val.trim());
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
  return args;
};

const getFiles = function getFiles(input) {
  const stats = fs.statSync(input);
  if (stats.isDirectory()) {
    return klawSync(input, { nodir: true });
  } else {
    // It should be a .love file
    return [{
      path: path.resolve(input),
      stats: stats,
    }];
  }
};

const isDirectory = function isDirectory(path) {
  return fs.statSync(path).isDirectory();
}

getAdditionalInfo(commander).then((args) => {
  const outputDir = path.resolve(args.output);
  const srcDir = path.resolve(__dirname, 'src');

  const sep = path.sep;
  const files = getFiles(args.input);
  const dirs = isDirectory(args.input) ? klawSync(args.input, { nofile: true }) : [];
  const dirRelativePaths = dirs.map(f => f.path.replace(new RegExp(`^.*${args.input}`), ''));

  const create_file_paths = []
  for (const path of dirRelativePaths) {
    const splits = path.split(sep);
    const length = splits.length - 1;
    const directoryPath = splits.slice(0, length).join('/') || '/';
    create_file_paths.push(`Module['FS_createPath']('${directoryPath}', '${splits[length]}', true, true);`);
  }

  const AUDIO_SUFFIXES = ['.ogg', '.wav', '.mp3'];
  const file_metadata = [];
  const file_buffers = [];
  let current_byte = 0;
  for (const file of files) {
    const relative_path = isDirectory(args.input) ?
                            file.path.replace(new RegExp(`^.*${args.input}`), '') :
                            '/game.love';
    const buffer = fs.readFileSync(file.path);
    file_metadata.push({
      filename: relative_path,
      crunched: 0,
      start: current_byte,
      end: current_byte + buffer.length,
      audio: AUDIO_SUFFIXES.reduce((isAudio, suffix) => {
        return isAudio || file.path.endsWith(suffix);
      }, false),
    });

    current_byte += buffer.length;
    file_buffers.push(buffer);
  }
  const total_buffer = Buffer.concat(file_buffers);

  const jsArgs = {
    create_file_paths: create_file_paths.join('\n      '),
    metadata: JSON.stringify({
      package_uuid: uuid(),
      remote_package_size: total_buffer.length,
      files: file_metadata,
    })
  };
  const gameTemplate = fs.readFileSync(`${srcDir}/game.js`, 'utf8');
  const renderedGameTemplate = mustache.render(gameTemplate, jsArgs);

  fs.mkdirsSync(`${outputDir}`);

  if (isDirectory(args.input)) {
    args.arguments = JSON.stringify(['./']);
  } else {
    args.arguments = JSON.stringify(['./game.love']);
  }

  {
    const template = fs.readFileSync(`${srcDir}/release/index.html`, 'utf8');
    const renderedTemplate = mustache.render(template, args);

    fs.mkdirsSync(`${outputDir}/release`);
    fs.writeFileSync(`${outputDir}/release/index.html`, renderedTemplate);
    fs.writeFileSync(`${outputDir}/release/game.js`, renderedGameTemplate);
    fs.writeFileSync(`${outputDir}/release/game.data`, total_buffer);
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
    fs.writeFileSync(`${outputDir}/debug/game.data`, total_buffer);
    fs.copySync(`${srcDir}/debug/love.js`, `${outputDir}/debug/love.js`);
    fs.copySync(`${srcDir}/debug/pthread-main.js`, `${outputDir}/debug/pthread-main.js`);
  }
});
