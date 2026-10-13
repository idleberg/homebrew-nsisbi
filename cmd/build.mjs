import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

import { Eta } from 'eta';
import logSymbols from 'log-symbols';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const FORMULA_DIR = path.join(ROOT, 'Formula');
const TEMPLATE_DIR = path.join(__dirname, 'data');

const eta = new Eta({
  views: TEMPLATE_DIR,
  useWith: true,
  autoEscape: false,
  cache: true,
});

const { positionals } = parseArgs({ allowPositionals: true });
const versionFilter = new Set(positionals);

async function sha256(url) {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`fetch ${url}: ${res.status} ${res.statusText}`);
  }
  return createHash('sha256').update(Buffer.from(await res.arrayBuffer())).digest('hex');
}

// 3.01–3.03 need util.h patched with 64-bit aliases
function templateName(version) {
  const [major, minor] = version.split('.').map(Number);
  return major === 3 && minor < 4 ? 'nsisbi-patch' : 'nsisbi';
}

async function writeIfChanged(filePath, content) {
  let existing = null;
  try {
    existing = await readFile(filePath, 'utf-8');
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
  }
  if (existing === content) return 'unchanged';
  await writeFile(filePath, content);
  return existing === null ? 'created' : 'updated';
}

async function emit(fileName, data, stats) {
  const filePath = path.join(FORMULA_DIR, fileName);
  const result = await writeIfChanged(filePath, eta.render(templateName(data.version), data));
  stats[result] += 1;
  if (result !== 'unchanged') {
    console.log(logSymbols.success, `${result}: ${path.relative(ROOT, filePath)}`);
  }
}

async function main() {
  const { stable } = JSON.parse(await readFile(path.join(TEMPLATE_DIR, 'versions.json'), 'utf-8'));
  const versions = Object.keys(stable);
  const latest = versions.at(-1);
  const stats = { created: 0, updated: 0, unchanged: 0 };

  for (const version of versions) {
    if (versionFilter.size > 0 && !versionFilter.has(version)) continue;

    const build = stable[version];
    const base = `https://downloads.sourceforge.net/project/nsisbi/nsisbi${version}`;
    const data = {
      version,
      build,
      versionNoDot: version.replace(/\./g, ''),
      hashCode: await sha256(`${base}/nsis-code-${build}-NSIS-trunk.zip`),
      hashBinary: await sha256(`${base}/nsis-binary-${build}.zip`),
    };

    await emit(`nsisbi@${version}.rb`, { ...data, className: `NsisbiAT${data.versionNoDot}` }, stats);
    if (version === latest) {
      await emit('nsisbi.rb', { ...data, className: 'Nsisbi' }, stats);
    }
  }

  console.log(
    logSymbols.info,
    `${stats.created} created, ${stats.updated} updated, ${stats.unchanged} unchanged`,
  );
}

main().catch((err) => {
  console.error(logSymbols.error, err);
  process.exit(1);
});
