import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

export const __dirname = dirname(fileURLToPath(import.meta.url));
export const W = 390;
export const H = 844;

export function screenImage(relPath) {
  return join(__dirname, '..', '..', 'screen', relPath);
}

export function asset(path) {
  return join(__dirname, '..', '..', 'screen', path);
}

export function renderPage(screenName, imgPath, title = '') {
  const safeTitle = title.replace(/'/g, "\\'");
  return `<!doctype html><html lang="id"><head><meta charset="utf-8">
<meta name="viewport" content="width=${W},height=${H}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased}
html,body{width:${W}px;height:${H}px}
body{font-family:'Inter',system-ui,sans-serif;background:#1a1a1a;color:#1A1A2E;overflow:hidden}
.screen{width:${W}px;height:${H}px;overflow:hidden;position:relative;display:flex;flex-direction:column;background:#fff}
.statusbar{height:28px;display:flex;align-items:center;justify-content:space-between;padding:0 18px;font-size:13px;font-weight:700;flex:0 0 auto;color:#1A1A2E;background:#fff}
.body{flex:1 1 auto;overflow:hidden;position:relative;display:flex;flex-direction:column}
.img-frame{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:#f5f5f5;padding:0}
.img-frame img{max-width:100%;max-height:100%;object-fit:contain;display:block}
.label{position:absolute;bottom:12px;left:12px;background:rgba(0,0,0,.7);color:#fff;padding:6px 12px;border-radius:8px;font-size:12px;font-weight:600}
</style></head>
<body><div class="screen">
<div class="statusbar"><span>10:51</span><div style="display:flex;gap:6px;align-items:center"><span style="font-weight:800;font-size:12px">4G</span><svg width="25" height="12" viewBox="0 0 25 12" fill="none" stroke="currentColor" stroke-width="1.3"><rect x="1" y="1" width="20" height="10" rx="2.6"/><rect x="3" y="3" width="13" height="6" rx="1" fill="currentColor"/><path d="M23 4v4" stroke-width="1.8"/></svg></div></div>
<div class="body">
<div class="img-frame">
<img src="file://${imgPath.replace(/\\/g, '/')}" alt="${safeTitle}" />
</div>
</div>
</div></body></html>`;
}
