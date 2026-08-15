// helpers.mjs — shared layout builders: statusbar, topbar, tabbar, bottom bar
import { ic } from './lib.mjs';

export const W = 390, H = 844;

// Design tokens — single theme (Trip.com inspired)
export const T = {
  primary: '#2962FF',
  primaryDark: '#0039CB',
  teal: '#14B8A6',
  text: '#1A1A2E',
  textSub: '#757575',
  textDisabled: '#BDBDBD',
  bg: '#FFFFFF',
  bgSurface: '#F5F5F5',
  bgSurface2: '#F0F4FF',
  star: '#FFA726',
  priceOri: '#E53935',
  priceDiscount: '#2962FF',
  scoreBg: '#2962FF',
  discountBg: '#FCE4EC',
  discountText: '#E91E63',
  border: '#E0E0E0',
  borderLight: '#EEEEEE',
  white: '#FFFFFF',
  tagGreen: '#E0F7FA',
  tagGreenText: '#00897B',
  radius: { card: 12, btn: 8, field: 8, chip: 20, sm: 6 },
  shadow: '0 2px 12px rgba(0,0,0,.10)',
  font: 'Inter',
};

export function fontLink() {
  return `<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">`;
}

export function baseCSS() {
  return `
  *{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased}
  html,body{width:${W}px;height:${H}px}
  body{font-family:'Inter',system-ui,sans-serif;background:#fff;color:${T.text};overflow:hidden}
  .screen{width:${W}px;height:${H}px;overflow:hidden;position:relative;display:flex;flex-direction:column;background:#fff}
  .statusbar{height:28px;display:flex;align-items:center;justify-content:space-between;padding:0 18px;font-size:13px;font-weight:700;flex:0 0 auto;z-index:30;color:${T.text}}
  .body{flex:1 1 auto;overflow:hidden;position:relative;display:flex;flex-direction:column}
  .scroll{flex:1;overflow:hidden}
  .btn{height:48px;border-radius:${T.radius.btn}px;display:flex;align-items:center;justify-content:center;gap:8px;font-weight:700;font-size:15px;border:none;width:100%;cursor:pointer}
  .btn-primary{background:${T.primary};color:#fff}
  .btn-outline{background:transparent;border:1.5px solid ${T.primary};color:${T.primary}}
  .divider{height:1px;background:${T.borderLight};margin:0}
  .muted{color:${T.textSub}}
  .chip{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:${T.radius.chip}px;font-size:11px;font-weight:600;border:1px solid ${T.border}}
  `;
}

export function statusbar(dark = false) {
  const col = dark ? '#fff' : T.text;
  return `<div class="statusbar" style="color:${col}">
    <span>10:51</span>
    <div style="display:flex;gap:6px;align-items:center">
      <svg width="16" height="12" viewBox="0 0 17 12" fill="${col}"><rect x="0" y="7" width="3" height="5" rx="1"/><rect x="4.5" y="4.5" width="3" height="7.5" rx="1"/><rect x="9" y="2" width="3" height="10" rx="1"/><rect x="13.5" y="0" width="3" height="12" rx="1"/></svg>
      <span style="font-weight:800;font-size:12px">4G</span>
      <svg width="25" height="12" viewBox="0 0 25 12" fill="none" stroke="${col}" stroke-width="1.3"><rect x="1" y="1" width="20" height="10" rx="2.6"/><rect x="3" y="3" width="13" height="6" rx="1" fill="${col}"/><path d="M23 4v4" stroke-width="1.8"/></svg>
    </div>
  </div>`;
}

export function topbar({ title = '', back = true, right = '', subtitle = '', bg = T.bg, color = T.text } = {}) {
  return `<div style="display:flex;align-items:center;gap:12px;padding:10px 16px;background:${bg};color:${color};border-bottom:1px solid ${T.borderLight};flex:0 0 auto;z-index:10">
    ${back ? `<div style="width:36px;height:36px;border-radius:50%;background:${bg === T.bg ? T.bgSurface : 'rgba(255,255,255,.2)'};display:flex;align-items:center;justify-content:center;flex:0 0 auto">${ic('arrowL', { size: 20, w: 2.5 })}</div>` : ''}
    <div style="flex:1;min-width:0">
      <div style="font-size:17px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${title}</div>
      ${subtitle ? `<div style="font-size:12px;color:${T.primary};font-weight:600;margin-top:1px">${subtitle}</div>` : ''}
    </div>
    ${right}
  </div>`;
}

export function tabBar(tabs, activeIdx = 0) {
  return `<div style="display:flex;overflow:hidden;border-bottom:1px solid ${T.borderLight};flex:0 0 auto;background:#fff">
    ${tabs.map((tab, i) => {
      const on = i === activeIdx;
      return `<div style="padding:12px 14px;font-size:14px;font-weight:${on ? 700 : 500};color:${on ? T.primary : T.textSub};white-space:nowrap;position:relative;flex:0 0 auto">
        ${tab}
        ${on ? `<div style="position:absolute;bottom:0;left:0;right:0;height:2.5px;background:${T.primary};border-radius:2px"></div>` : ''}
      </div>`;
    }).join('')}
  </div>`;
}

export function bottomBarPesan({ price = 'Rp446.637', priceOri = 'Rp541.790', btnText = 'Pilih kamar', wide = false } = {}) {
  return `<div style="display:flex;align-items:center;gap:12px;padding:10px 16px;background:#fff;border-top:1px solid ${T.borderLight};flex:0 0 auto">
    <div style="flex:1;min-width:0">
      <div style="font-size:20px;font-weight:800;color:${T.primary}">${price}</div>
      ${priceOri ? `<div style="font-size:12px;color:${T.priceOri};text-decoration:line-through">${priceOri}</div>` : ''}
    </div>
    <div style="width:${wide ? '100%' : '170px'};flex:0 0 auto">
      <div class="btn btn-primary" style="border-radius:${T.radius.btn}px">${btnText}</div>
    </div>
  </div>`;
}

export function starRow(count) {
  return Array.from({ length: 5 }, (_, i) =>
    `${ic('star', { size: 14, w: 0, fill: i < count ? T.star : T.border })}`
  ).join('');
}

export function scoreBadge(score, label = '', reviews = '') {
  return `<div style="display:flex;align-items:center;gap:8px">
    <div style="background:${T.scoreBg};color:#fff;padding:4px 10px;border-radius:${T.radius.sm}px;font-size:14px;font-weight:700">${score}/10</div>
    ${label ? `<span style="font-weight:700;font-size:14px">${label}</span>` : ''}
    ${reviews ? `<span style="font-size:13px;color:${T.primary};text-decoration:underline">${reviews} ulasan</span>` : ''}
  </div>`;
}

export function gradPhoto({ h = 140, grad = `linear-gradient(135deg,${T.primary},#6ea6ff)`, label = '', radius = T.radius.card, opacity = 0.18 } = {}) {
  return `<div style="height:${h}px;border-radius:${radius}px;background:${grad};position:relative;overflow:hidden;display:flex;align-items:flex-end;color:#fff;flex:0 0 auto">
    <div style="position:absolute;inset:0;opacity:${opacity};background:radial-gradient(circle at 80% 20%,#fff 0,transparent 45%),radial-gradient(circle at 10% 90%,#fff 0,transparent 40%)"></div>
    ${label ? `<div style="position:relative;padding:10px 12px;font-weight:700;font-size:13px;text-shadow:0 1px 4px rgba(0,0,0,.4)">${label}</div>` : ''}
  </div>`;
}

export { ic };
