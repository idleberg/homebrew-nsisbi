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

const createManifest = async (version, build, file = null) => {
  let data = {};
  let blob;

  data.version = version;
  data.build = build;
  data.versionMajor = version[0];
  data.versionNoDot = version.replace(/\./g, '');
  data.className = (file === null) ? `NsisbiAT${data.versionNoDot}` : 'Nsisbi';

  const codeUrl = `https://downloads.sourceforge.net/project/nsisbi/nsisbi${version}/nsis-code-${build}-NSIS-trunk.zip`;
  const binarUrl = `https://downloads.sourceforge.net/project/nsisbi/nsisbi${version}/nsis-binary-${build}.zip`;

  try {
    blob = await download(codeUrl);
    data.hashCode = getHash(blob);

    blob = await download(binarUrl);
    data.hashBinary = getHash(blob);

    file = (file === null) ? `Formula/nsisbi@${data.version}.rb` : `Formula/${file}`;

    template(file, data);
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
const allVersions = Object.keys(versions.stable);

allVersions.forEach( key => {
  let value = versions.stable[key];
  createManifest(key, value);
});

// Latest version
const latestVersion = allVersions[allVersions.length -1];
createManifest(latestVersion, versions.stable[latestVersion], 'nsisbi.rb');
