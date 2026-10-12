"use strict";
const globalSearch = document.querySelector('#global-search');
const searchPanel = document.querySelector('#global-search-panel');
const searchResults = document.querySelector('#global-search-results');
const searchStatus = document.querySelector('#global-search-status');
const normalize = text => text.normalize('NFKC').toLocaleLowerCase();
const searchIndex = JSON.parse(document.querySelector('#handbook-search-index').textContent).map(item => ({
  ...item, text: item.text.replace(/\s+/g, ' ').trim(),
  titleKey: normalize(item.title), haystack: normalize(item.title + ' ' + item.section + ' ' + item.text)
}));
function closeSearch() { searchPanel.hidden = true; }
function highlighted(text, tokens) {
  const fragment = document.createDocumentFragment();
  const key = normalize(text);
  let cursor = 0;
  while (cursor < text.length) {
    let start = text.length, token = '';
    for (const term of tokens) {
      const position = key.indexOf(term, cursor);
      if (position !== -1 && position < start) { start = position; token = term; }
    }
    fragment.append(document.createTextNode(text.slice(cursor, start)));
    if (!token) break;
    const mark = document.createElement('mark');
    mark.textContent = text.slice(start, start + token.length);
    fragment.append(mark);
    cursor = start + token.length;
  }
  return fragment;
}
function renderSearch() {
  const query = normalize(globalSearch.value.trim());
  if (!query) { closeSearch(); searchResults.replaceChildren(); searchStatus.textContent = ''; return; }
  const tokens = [...new Set(query.split(/\s+/))];
  const matches = searchIndex.filter(item => tokens.every(token => item.haystack.includes(token)))
    .map(item => ({...item, score: (item.titleKey === query ? 120 : item.titleKey.includes(query) ? 80 : 0) + tokens.filter(token => item.titleKey.includes(token)).length * 15}))
    .sort((a,b) => b.score - a.score || a.title.localeCompare(b.title));
  searchPanel.hidden = false;
  searchStatus.textContent = matches.length ? matches.length + ' results across the handbook' + (matches.length > 40 ? ' · showing the first 40; refine your search' : '') : 'No results. Try a component name, file path or Nix option.';
  searchResults.replaceChildren();
  for (const item of matches.slice(0,40)) {
    const row = document.createElement('li');
    const link = document.createElement('a'); link.href = item.href;
    const section = document.createElement('span'); section.className = 'search-result-section'; section.textContent = item.section;
    const title = document.createElement('strong'); title.append(highlighted(item.title, tokens));
    const key = normalize(item.text);
    const position = Math.min(...tokens.map(token => key.indexOf(token)).filter(position => position >= 0));
    const start = Number.isFinite(position) ? Math.max(0, position - 45) : 0;
    const excerpt = (start ? '…' : '') + item.text.slice(start,start+170) + (item.text.length > start+170 ? '…' : '');
    const snippet = document.createElement('span'); snippet.className = 'search-result-excerpt'; snippet.append(highlighted(excerpt,tokens));
    link.append(section, title, snippet);
    link.addEventListener('click', () => {
      closeSearch();
      const url = new URL(link.href);
      if (url.pathname === location.pathname && url.hash === location.hash) requestAnimationFrame(openTarget);
    });
    row.append(link); searchResults.append(row);
  }
}
globalSearch.addEventListener('input', renderSearch);
globalSearch.addEventListener('focus', () => { if (globalSearch.value.trim()) renderSearch(); });
document.querySelector('#global-search-close').addEventListener('click', () => { closeSearch(); globalSearch.focus(); closeSearch(); });
document.addEventListener('pointerdown', event => { if (!event.target.closest('.global-search')) closeSearch(); });
document.addEventListener('keydown', event => {
  const editing = document.activeElement.matches('input,textarea,select,[contenteditable="true"]');
  if ((event.key === '/' && !editing) || ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k')) {
    event.preventDefault(); globalSearch.focus(); globalSearch.select();
  }
  if (event.key === 'Escape' && !searchPanel.hidden) { event.preventDefault(); closeSearch(); globalSearch.focus(); closeSearch(); }
  if (!searchPanel.hidden && ['ArrowDown','ArrowUp','Enter'].includes(event.key)) {
    const links = [...searchResults.querySelectorAll('a')];
    const index = links.indexOf(document.activeElement);
    if (document.activeElement === globalSearch && event.key === 'Enter' && links.length) { event.preventDefault(); links[0].click(); }
    else if ((document.activeElement === globalSearch || index !== -1) && event.key !== 'Enter') {
      event.preventDefault();
      if (event.key === 'ArrowUp' && index <= 0) globalSearch.focus();
      else links[Math.min(links.length - 1, Math.max(0,index + (event.key === 'ArrowDown' ? 1 : -1)))]?.focus();
    }
  }
});

const configBrowser = document.querySelector('.configuration-browser');
const filePanels = [...document.querySelectorAll('[data-config-path]')];
const fileLinks = [...document.querySelectorAll('[data-file-path]')];
const fileFilter = document.querySelector('#file-filter');
const folders = [...document.querySelectorAll('.config-folder')];
let savedFolders = null;
function filterFiles() {
  const query = normalize(fileFilter.value.trim());
  if (query && !savedFolders) savedFolders = new Map(folders.map(folder => [folder,folder.open]));
  let count = 0;
  for (const link of fileLinks) {
    link.hidden = Boolean(query) && !normalize(link.dataset.filePath).includes(query);
    if (!link.hidden) count++;
  }
  for (const folder of [...folders].reverse()) {
    folder.hidden = Boolean(query) && [...folder.querySelectorAll('[data-file-path]')].every(link => link.hidden);
    if (query) folder.open = !folder.hidden;
    else if (savedFolders) folder.open = savedFolders.get(folder);
  }
  if (!query) savedFolders = null;
  document.querySelector('#file-filter-status').textContent = query ? count + ' matching files' : '';
}
function selectFile(id) {
  const selected = filePanels.find(panel => panel.id === id);
  if (!selected) return false;
  if (fileFilter.value) { fileFilter.value = ''; filterFiles(); }
  for (const panel of filePanels) { panel.hidden = panel !== selected; panel.open = panel === selected; }
  for (const link of fileLinks) {
    const active = link.dataset.filePath === selected.dataset.configPath;
    if (active) {
      link.setAttribute('aria-current','true');
      let parent = link.parentElement;
      while (parent && parent !== configBrowser) { if (parent.matches('details')) parent.open = true; parent = parent.parentElement; }
    } else link.removeAttribute('aria-current');
  }
  return true;
}
if (configBrowser) {
  configBrowser.classList.add('is-ready');
  fileFilter.addEventListener('input', filterFiles);
  for (const panel of filePanels) panel.querySelector('summary').addEventListener('click', event => event.preventDefault());
  for (const link of configBrowser.querySelectorAll('a[href^="#file-"]')) link.addEventListener('click', () => {
    if (location.hash === link.hash) openTarget();
  });
  selectFile(location.hash.slice(1)) || selectFile(filePanels.find(panel => panel.dataset.configPath === 'flake.nix')?.id);
}
function openTarget() {
  let id; try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
  const element = document.getElementById(id); if (!element) return;
  selectFile(id);
  element.hidden = false;
  let parent = element;
  while (parent) { if (parent.matches('details')) { parent.hidden = false; parent.open = true; } parent = parent.parentElement; }
  (element.matches('.config-source') ? element.querySelector('summary') : element).scrollIntoView({block:'nearest'});
  if (element.matches('.history-bar')) element.click();
  if (element.matches('.config-source')) { element.querySelector('summary').tabIndex = -1; element.querySelector('summary').focus({preventScroll:true}); }
}
window.addEventListener('hashchange', openTarget);
if (location.hash) requestAnimationFrame(openTarget);

for(const el of document.querySelectorAll('.document')){const label=document.createElement('label');label.className='review-control';const box=document.createElement('input');box.type='checkbox';const key='shadow-guide.review.'+el.id;try{box.checked=localStorage.getItem(key)==='true';}catch{}box.addEventListener('change',()=>{try{localStorage.setItem(key,String(box.checked));}catch{}});label.append(box,document.createTextNode('Reviewed by me · stored only in this browser'));el.querySelector('article').append(label);}
if(navigator.clipboard&&window.isSecureContext)for(const pre of document.querySelectorAll('pre')){const button=document.createElement('button');button.type='button';button.className='copy-button';button.textContent='Copy';const content=pre.textContent;button.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(content);button.textContent='Copied';setTimeout(()=>button.textContent='Copy',1500);}catch{button.textContent='Select text';}});pre.prepend(button);}

const timeline=document.querySelector('.history-scroll');
for(const button of document.querySelectorAll('[data-history-scale]')){
  button.addEventListener('click',()=>{
    timeline.dataset.scale=button.dataset.historyScale;
    for(const control of document.querySelectorAll('[data-history-scale]'))control.setAttribute('aria-pressed',String(control===button));
  });
}
const periodDialog=document.querySelector('#history-dialog');
if(periodDialog){
  for(const bar of document.querySelectorAll('.history-bar'))bar.addEventListener('click',()=>{
    document.querySelector('#history-dialog-content').replaceChildren(bar.querySelector('template').content.cloneNode(true));
    document.querySelector('#history-dialog-content h3').id='history-dialog-title';
    periodDialog.showModal();
  });
  document.querySelector('[data-history-close]').addEventListener('click',()=>periodDialog.close());
  periodDialog.addEventListener('click',event=>{if(event.target===periodDialog){const bounds=periodDialog.getBoundingClientRect();if(event.clientX<bounds.left||event.clientX>bounds.right||event.clientY<bounds.top||event.clientY>bounds.bottom)periodDialog.close();}});
}
