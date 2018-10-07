// Dependencies
const download = require('download');
const ejs = require('ejs');
const hasha = require('hasha');
const symbol = require('log-symbols');
const { join } = require('path');
const versions = require('./data/versions.json');
const { writeFile } = require('fs');

let getHash = (blob) => {
  const hash = hasha(blob, {algorithm: 'sha256'});

  return hash;
};

let template = (outFile, data) => {
  ejs.renderFile(join(__dirname, '/data/nsisbi.ejs'), data, function(err, contents) {
    if (err) {
      console.error(symbol.error, err);
      return;
    }

    writeFile(outFile, contents, (err) => {
      if (err) throw err;
      console.log(symbol.success, `Saved: ${outFile}`);
    });
  });
};

const createManifest = async (version, build) => {
  let data = {};
  let blob;

  data.version = version;
  data.build = build;
  data.versionMajor = version[0];
  data.versionNoDot = version.replace(/\./g, '');
  // data.directory = (/\d(a|b|rc)\d*$/.test(data.version) === true) ? `NSIS%20${data.versionMajor}%20Pre-release` : `NSIS%20${data.versionMajor}`;

  const codeUrl = `https://downloads.sourceforge.net/project/nsisbi/nsisbi${version}/nsis-code-${build}-NSIS-trunk.zip`;
  const binarUrl = `https://downloads.sourceforge.net/project/nsisbi/nsisbi${version}/nsis-binary-${build}.zip`;

  try {
    blob = await download(codeUrl);
    data.hashCode = getHash(blob);

    blob = await download(binarUrl);
    data.hashBinary = getHash(blob);

    template(`Formula/nsisbi@${data.version}.rb`, data);
  } catch(error) {
    if (error.statusMessage) {
      if (error.statusMessage === 'Too Many Requests') {
        return console.warn(symbol.warning, `${error.statusMessage}: nsis-${version}.zip`);
      }
      return console.error(symbol.error, `${error.statusMessage}: nsis-${version}.zip`);
    } else if (error.code === 'ENOENT') {
      return console.log('Skipping Test: Manifest Not Found');
    }
    console.error(symbol.error, error);
  }
};

// All versions
Object.keys(versions.stable).forEach( key => {
  let value = versions.stable[key];
  createManifest(key, value);
});
