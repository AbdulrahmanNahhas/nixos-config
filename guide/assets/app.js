"use strict";
const search=document.querySelector('#search');
const entries=[...document.querySelectorAll('[data-search]')];
const groups=[...document.querySelectorAll('.technology-group')];
const originalOpen=new Map(groups.map(g=>[g,g.open]));
search?.addEventListener('input',()=>{const q=search.value.trim().toLowerCase();let count=0;for(const el of entries){el.hidden=!!q&&!(el.textContent+' '+(el.dataset.searchText||'')).toLowerCase().includes(q);if(!el.hidden)count++;}for(const group of groups){const rows=[...group.querySelectorAll('[data-search]')];group.hidden=!!q&&rows.every(r=>r.hidden);group.open=q&&!group.hidden?true:originalOpen.get(group);}
document.querySelector('#search-status').textContent=q?count+' matching entries':'';});
document.addEventListener('keydown',e=>{if(e.key==='/'&&!/INPUT|TEXTAREA|SELECT/.test(document.activeElement.tagName)){if(search){e.preventDefault();search.focus();}}if(e.key==='Escape'&&search&&document.activeElement===search){search.value='';search.dispatchEvent(new Event('input'));search.blur();}});
function openTarget(){let id;try{id=decodeURIComponent(location.hash.slice(1));}catch{return;}const el=document.getElementById(id);if(!el)return;el.hidden=false;if(el.matches('details')){el.hidden=false;el.open=true;}const parent=el.closest('details');if(parent){parent.hidden=false;parent.open=true;}el.scrollIntoView();}
window.addEventListener('hashchange',openTarget);if(location.hash)openTarget();
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
