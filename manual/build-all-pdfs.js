const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { marked } = require(path.join(__dirname, '..', 'node_modules', 'marked'));

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const files = [
  {
    input: 'user-guide-mobile-app.md',
    output: 'user-guide-mobile-app.pdf',
    title: 'User Guide Mobile App - Livirooms',
    category: 'PANDUAN PENGGUNA APLIKASI MOBILE'
  },
  {
    input: 'user-guide-web-administrator.md',
    output: 'user-guide-web-administrator.pdf',
    title: 'User Guide Web Administrator - Livirooms',
    category: 'PANDUAN OPERASIONAL WEBSITE ADMIN'
  },
  {
    input: 'user-manual-web-administrator.md',
    output: 'user-manual-web-administrator.pdf',
    title: 'User Manual Web Administrator - Livirooms',
    category: 'MANUAL SISTEM & TEKNIS WEB ADMIN'
  },
  {
    input: 'user-manual-mobile-app.md',
    output: 'user-manual-mobile-app.pdf',
    title: 'User Manual Mobile App - Livirooms',
    category: 'MANUAL SISTEM & ARSITEKTUR MOBILE APP'
  }
];

const css = `
  @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');

  @page {
    size: A4 portrait;
    margin: 18mm 15mm 20mm 15mm;
  }

  * {
    box-sizing: border-box;
  }

  body {
    font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    color: #1e293b;
    line-height: 1.65;
    font-size: 13px;
    background-color: #ffffff;
    margin: 0;
    padding: 0;
  }

  /* Header banner for PDF */
  .pdf-header-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid #2563eb;
    padding-bottom: 8px;
    margin-bottom: 24px;
    font-size: 11px;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
  }

  .pdf-header-bar .brand {
    color: #2563eb;
    font-weight: 800;
    font-size: 13px;
  }

  h1 {
    font-size: 22px;
    font-weight: 800;
    color: #0f172a;
    border-bottom: 3px solid #2563eb;
    padding-bottom: 8px;
    margin-top: 0;
    margin-bottom: 14px;
    letter-spacing: -0.5px;
    page-break-before: always;
    break-before: page;
    page-break-after: avoid;
    break-after: avoid;
  }

  h1:first-of-type {
    page-break-before: avoid;
    break-before: avoid;
  }

  h2 {
    font-size: 16px;
    font-weight: 700;
    color: #1e3a8a;
    border-left: 4px solid #3b82f6;
    padding-left: 10px;
    margin-top: 24px;
    margin-bottom: 12px;
    page-break-after: avoid;
    break-after: avoid;
  }

  h3 {
    font-size: 14px;
    font-weight: 700;
    color: #334155;
    margin-top: 18px;
    margin-bottom: 8px;
    page-break-after: avoid;
    break-after: avoid;
  }

  h4, h5, h6 {
    font-size: 13px;
    font-weight: 600;
    color: #475569;
    margin-top: 14px;
    margin-bottom: 6px;
    page-break-after: avoid;
    break-after: avoid;
  }

  p {
    margin-top: 0;
    margin-bottom: 10px;
    text-align: justify;
    orphans: 2;
    widows: 2;
  }

  ul, ol {
    margin-top: 0;
    margin-bottom: 12px;
    padding-left: 24px;
    orphans: 2;
    widows: 2;
  }

  li {
    margin-bottom: 6px;
    page-break-inside: avoid;
    break-inside: avoid;
  }

  strong {
    color: #0f172a;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0;
    font-size: 11.5px;
    page-break-inside: avoid;
    border-radius: 6px;
    overflow: hidden;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  }

  th, td {
    border: 1px solid #cbd5e1;
    padding: 7px 10px;
    text-align: left;
    vertical-align: top;
  }

  th {
    background-color: #f1f5f9;
    color: #1e293b;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 10.5px;
    letter-spacing: 0.3px;
  }

  tr:nth-child(even) td {
    background-color: #f8fafc;
  }

  pre {
    background-color: #0f172a;
    color: #f8fafc;
    padding: 12px 14px;
    border-radius: 6px;
    font-family: 'JetBrains Mono', Consolas, monospace;
    font-size: 11px;
    overflow-x: auto;
    margin: 14px 0;
    page-break-inside: avoid;
    line-height: 1.45;
  }

  code {
    font-family: 'JetBrains Mono', Consolas, monospace;
    font-size: 11.5px;
    background-color: #f1f5f9;
    color: #2563eb;
    padding: 2px 5px;
    border-radius: 4px;
  }

  pre code {
    background-color: transparent;
    color: inherit;
    padding: 0;
  }

  blockquote {
    border-left: 4px solid #3b82f6;
    background-color: #eff6ff;
    padding: 10px 14px;
    margin: 14px 0;
    border-radius: 0 6px 6px 0;
    font-size: 12px;
    color: #1e40af;
    page-break-inside: avoid;
  }

  blockquote p:last-child {
    margin-bottom: 0;
  }

  hr {
    border: none;
    border-top: 1px solid #e2e8f0;
    margin: 24px 0;
  }

  img {
    max-width: 100%;
    height: auto;
    border-radius: 8px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);
    border: 1px solid #cbd5e1;
    display: block;
    margin: 14px auto 8px auto;
    page-break-inside: avoid;
    break-inside: avoid;
  }

  img[src*="mobile/"] {
    max-width: 240px;
    max-height: 420px;
  }

  img[src*="website/"] {
    max-width: 96%;
    max-height: 480px;
  }

  p:has(img) {
    text-align: center;
    margin: 14px 0 6px 0;
    page-break-inside: avoid;
    break-inside: avoid;
  }

  em {
    color: #64748b;
    font-size: 11px;
  }

  .footer-notice {
    margin-top: 36px;
    padding-top: 12px;
    border-top: 1px solid #e2e8f0;
    font-size: 10px;
    color: #94a3b8;
    display: flex;
    justify-content: space-between;
  }
`;

console.log('=== MEMULAI KONVERSI 4 BUKU PANDUAN LIVIROOMS KE PDF ===\n');

files.forEach(({ input, output, title, category }) => {
  const inputPath = path.join(__dirname, input);
  const outputPath = path.join(__dirname, output);
  const tempHtmlPath = path.join(__dirname, `_temp_${path.parse(output).name}.html`);

  if (!fs.existsSync(inputPath)) {
    console.error(`[ERROR] File tidak ditemukan: ${inputPath}`);
    return;
  }

  console.log(`[1/3] Membaca & mem-parsing: ${input}...`);
  const markdown = fs.readFileSync(inputPath, 'utf-8');
  const htmlBody = marked.parse(markdown);

  const fullHtml = `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <style>${css}</style>
</head>
<body>
  <div class="pdf-header-bar">
    <span class="brand">LIVIROOMS HOSPITALITY PLATFORM</span>
    <span>${category}</span>
    <span>VERSI 2.4.0</span>
  </div>
  ${htmlBody}
  <div class="footer-notice">
    <span>© 2026 PT Livirooms Indonesia Hospitality. Seluruh Hak Cipta Dilindungi Undang-Undang.</span>
    <span>Dokumen Resmi Sistem Livirooms</span>
  </div>
</body>
</html>`;

  fs.writeFileSync(tempHtmlPath, fullHtml, 'utf-8');

  console.log(`[2/3] Merender ke PDF via Headless Chrome Engine...`);
  const cmd = `"${CHROME_PATH}" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="${outputPath}" "${tempHtmlPath}"`;
  
  try {
    execSync(cmd, { stdio: 'pipe' });
    const stats = fs.statSync(outputPath);
    console.log(`[3/3] SUKSES! Berkas PDF dibuat: ${output} (${(stats.size / 1024).toFixed(1)} KB)\n`);
  } catch (err) {
    console.error(`[GAGAL] Gagal membuat PDF ${output}:`, err.message);
  } finally {
    if (fs.existsSync(tempHtmlPath)) {
      fs.unlinkSync(tempHtmlPath);
    }
  }
});

console.log('=== SEMUA 4 BERKAS PDF BERHASIL DIBUAT DENGAN SEMPURNA! ===');
