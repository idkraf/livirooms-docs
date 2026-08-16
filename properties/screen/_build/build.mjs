// build.mjs — writes HTML for every screen and emits manifest.json
import { writeFileSync, mkdirSync, existsSync, rmSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { renderPage, SCREEN_LIST, OUT_NAME_MAP, W, H } from './screens.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const HTML_ROOT = join(__dirname, 'html');

if (!existsSync(HTML_ROOT)) mkdirSync(HTML_ROOT, { recursive: true });

const args = process.argv.slice(2);
const targetOutputs = [];
let i = 0;
while (i < args.length) {
  if (args[i] === '--for' || args[i] === 'for') {
    i++;
    while (i < args.length && !args[i].startsWith('-')) {
      targetOutputs.push(args[i]);
      i++;
    }
  } else {
    i++;
  }
}

const screensToBuild = targetOutputs.length > 0
  ? SCREEN_LIST.filter(screen => {
      const outName = OUT_NAME_MAP[screen] || `${screen}.png`;
      return targetOutputs.some(f => f.endsWith(outName) || f === outName);
    })
  : SCREEN_LIST;

if (targetOutputs.length === 0 && existsSync(HTML_ROOT)) {
  rmSync(HTML_ROOT, { recursive: true, force: true });
  mkdirSync(HTML_ROOT, { recursive: true });
}

const manifest = [];
let count = 0;

for (const screen of screensToBuild) {
  const html = renderPage(screen);
  const file = `${screen}.html`;
  writeFileSync(join(HTML_ROOT, file), html, 'utf8');
  manifest.push({
    screen,
    file,
    outName: OUT_NAME_MAP[screen] || `${screen}.png`,
    w: W,
    h: H,
  });
  count++;
}

writeFileSync(join(__dirname, 'manifest.json'), JSON.stringify(manifest, null, 2));
console.log(`✅ Built ${count} HTML pages into ${HTML_ROOT}. Manifest generated: ${manifest.length} entries.`);
