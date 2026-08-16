// render.mjs — renders every HTML screen into PNG image using local Chrome
import puppeteer from 'puppeteer-core';
import { readFileSync, existsSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT_ROOT = resolve(__dirname, '..', '_build_image');
const HTML_ROOT = join(__dirname, 'html');
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';

if (!existsSync(join(__dirname, 'manifest.json'))) {
  console.error('manifest.json not found! Run "node build.mjs" first.');
  process.exit(1);
}

const manifest = JSON.parse(readFileSync(join(__dirname, 'manifest.json'), 'utf8'));

if (!existsSync(OUT_ROOT)) mkdirSync(OUT_ROOT, { recursive: true });

const args = process.argv.slice(2);
const targetOutputs = [];
let ai = 0;
while (ai < args.length) {
  if (args[ai] === '--for' || args[ai] === 'for') {
    ai++;
    while (ai < args.length && !args[ai].startsWith('-')) {
      targetOutputs.push(args[ai]);
      ai++;
    }
  } else {
    ai++;
  }
}

const browser = await puppeteer.launch({
  executablePath: CHROME,
  headless: 'shell',
  args: ['--force-color-profile=srgb', '--hide-scrollbars', '--disable-web-security'],
});

let done = 0, failed = 0;
for (const item of manifest) {
  if (targetOutputs.length > 0 && !targetOutputs.some(f => item.outName === f || f.endsWith(item.outName))) {
    continue;
  }
  const htmlPath = join(HTML_ROOT, item.file);
  if (!existsSync(htmlPath)) {
    console.warn('MISSING html:', htmlPath);
    failed++;
    continue;
  }
  const outPath = join(OUT_ROOT, item.outName);

  const page = await browser.newPage();
  await page.setViewport({ width: item.w || 390, height: item.h || 844, deviceScaleFactor: 2 });
  await page.goto('file://' + htmlPath.replace(/\\/g, '/'), { waitUntil: 'networkidle0', timeout: 60000 });
  await page.evaluate(async () => {
    if (document.fonts && document.fonts.ready) await document.fonts.ready;
  });
  await page.screenshot({ path: outPath, type: 'png', fullPage: false });
  await page.close();
  done++;
  process.stdout.write(`\r  Rendered ${done}/${manifest.length} -> ${item.outName} `);
}

process.stdout.write('\n');
await browser.close();
console.log(`✨ Render complete: ${done} screens rendered, ${failed} failed. Output directory: ${OUT_ROOT}`);
