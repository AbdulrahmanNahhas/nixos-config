// Trusted local Markdown → one offline HTML handbook. No runtime dependencies.
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = path.dirname(fileURLToPath(import.meta.url));
const repo = path.dirname(root);
const escape = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const load = async name => JSON.parse(await fs.readFile(path.join(root, name), 'utf8'));
const [history, plan, tools, lessons] = await Promise.all(['timeline.json','roadmap.json','tools.json','lessons.json'].map(load));
const cards = items => items.map(item => `<details data-search><summary>${escape(item.title || item.name)}</summary>${item.body}</details>`).join('\n');
const label = value => `<small>${escape(value)}</small>`;
const evidence = commits => `<p class="meta">Commit evidence: ${(commits || []).map(escape).join(' · ')}</p>`;
const sections = [];
const add = (id, title, body) => sections.push({id, title, body});

add('map','System map', `<div class="diagram"><div>flake.nix + flake.lock<br><small>inputs → pinned revisions</small></div><span>↓</span><div>shadow/default.nix<br><small>hardware facts + module selection</small></div><span>↙　↘</span><div class="branches"><div>modules/nixos/<br><small>boot · drivers · network · security · storage</small></div><div>shadow/home.nix → modules/home/<br><small>programs · shell · editor · desktop</small></div></div></div><div class="diagram"><div class="branches"><div>RAM → tmpfs /<br><small>undeclared state disappears at reboot</small></div><div>NVMe → LUKS2 → Btrfs<br><small>/nix · /saved · /swap persist</small></div></div><span>↓</span><div>Preservation exposes selected persistent paths</div><span>↓</span><div>Off-device encrypted backup<br><small>PROPOSED — independent keys + tested restore</small></div></div><p class="flow">Edit → check → build → temporary test → switch → reboot & verify</p><p>Source, built generations and running services are different things. Persistence, snapshots and generation rollback are not independent backups.</p>`);
add('next','What to implement next', `<p>Prioritized proposals, not enabled features. Hardware, backup destinations and firmware changes need explicit decisions.</p>` + cards(plan.items.map(item => ({title:item.priority+' · '+item.title,body:`${label(item.category+' · '+item.status)}<p>${escape(item.why)}</p><p><b>Next:</b> ${escape(item.next)}</p><p><b>Done when:</b> ${escape(item.acceptance)}</p><p><b>Owner:</b> ${escape(item.owner)}</p><p><b>Risk:</b> ${escape(item.risk)}</p><p class="meta">Prerequisites: ${escape(item.depends.join(', ') || 'None')} · Review: ${escape(item.review)}</p>`}))));
add('tools','Tools, purposes & alternatives', `<p>Configured means declared in source—not live-tested. Optional and proposed technologies are labeled separately.</p>` + cards(tools.items.map(item => ({title:item.name,body:`${label(item.category+' · '+item.status)}<p>${escape(item.purpose)}</p><p><b>Owner:</b> <code>${escape(item.owner)}</code></p><p><b>Alternative:</b> ${escape(item.alternative)}</p><p><b>Decision:</b> ${escape(item.decision)}</p>`}))));
add('timeline','Timeline & tool-selection periods', `<p>${escape(history.basis)}</p><h3>From → to</h3><div class="periods">${history.periods.map(item => `<article data-search><small>${escape(item.from || 'Start unknown')} → ${escape(item.to || 'Open at review')}</small><h4>${escape(item.title)}</h4><p>${escape(item.detail)}</p>${evidence(item.commits)}</article>`).join('')}</div><h3>Recorded changes</h3><div class="timeline">${[...history.events].reverse().map(item => `<article data-search><time>${escape(item.date)}</time><div><h4>${escape(item.title)}</h4><p>${escape(item.detail)}</p>${evidence(item.commits)}</div></article>`).join('')}</div>`);

const files = [];
async function walk(relative) {
  for (const entry of (await fs.readdir(path.join(repo,relative),{withFileTypes:true})).sort((a,b)=>a.name.localeCompare(b.name))) {
    const name = path.posix.join(relative,entry.name);
    if (entry.isDirectory()) await walk(name);
    else if (entry.isFile()) files.push(name); // Never follow links outside the repository.
  }
}
await Promise.all(['modules','shadow','encrypted-secrets'].map(walk));
files.push('flake.nix','flake.lock','README.md','AGENTS.md');
const fileCards = [];
for (const name of files.sort()) {
  const preview = name === 'flake.nix' || /^(modules|shadow)\/.*\.(nix|kdl|toml)$/.test(name);
  const body = preview ? `<pre><code>${escape(await fs.readFile(path.join(repo,name),'utf8'))}</code></pre>` : `<p>Open this file in your editor. ${name.startsWith('encrypted-secrets/') ? 'Ciphertext contents are deliberately not read or published.' : 'Metadata only; not included in this preview.'}</p>`;
  fileCards.push({title:name,body});
}
add('files','Configuration files', `<p>${files.length} files mapped. These previews are public configuration snapshots, not editable live settings. Edit the actual paths in your editor; rebuild this guide after changes. Encrypted secrets have no preview.</p>` + cards(fileCards));
const lock = await load('../flake.lock');
add('pins','Locked input revisions', `<p>Upstream timestamps are not installation, release or activation dates. Stale entries may remain after removing a declaration until the lock is reconciled.</p><div class="table"><table><tr><th>Input</th><th>Ref</th><th>Revision</th><th>Upstream date</th></tr>${Object.entries(lock.nodes[lock.root].inputs).map(([name,node]) => {const input=lock.nodes[typeof node === 'string' ? node : node[0]];return `<tr><td>${escape(name)}</td><td>${escape(input?.original?.ref || 'Unlabelled')}</td><td><code>${escape(input?.locked?.rev || 'Content hash')}</code></td><td>${input?.locked?.lastModified ? new Date(input.locked.lastModified*1000).toISOString().slice(0,10) : 'Unknown'}</td></tr>`;}).join('')}</table></div>`);

const metadata = new Map(lessons.map(item => [path.basename(item.file,'.md'),item]));
const documentCards = [];
for (const name of (await fs.readdir(path.join(root,'docs'))).filter(name=>name.endsWith('.md')).sort()) {
  const markdown = await fs.readFile(path.join(root,'docs',name),'utf8');
  const id = path.basename(name,'.md');
  const title = metadata.get(id)?.title || markdown.match(/^# (.+)/m)?.[1] || id;
  // All prose is reviewed local source. Raw HTML is supported, not sanitized.
  const body = marked.parse(markdown).replace(/href="(?:docs\/)?([a-z0-9-]+)\.md(?:#[^"]*)?"/g, 'href="#guide-$1"');
  const sources = metadata.get(id)?.sources || [];
  documentCards.push(`<details id="guide-${id}" data-search><summary>${escape(title)}</summary><article class="prose">${body}${sources.length ? '<h3>Sources</h3>'+sources.map(([label,url])=>`<p><a href="${escape(url)}">${escape(label)}</a></p>`).join('') : ''}</article></details>`);
}
add('guides','Explanations, research & workflows', `<p>Brief concepts and detailed recipes. Source: <code>guide/docs/*.md</code>. Search to find a topic; click a title to expand it.</p>`+documentCards.join('\n'));
add('editing','Edit this guide', `<p>Keep this small: Markdown explanations, three JSON lists, one generated page. No framework or server.</p><ul><li><code>docs/*.md</code>: explanations and research; any new Markdown file is picked up automatically.</li><li><code>tools.json</code>: purpose, status, owner and alternatives.</li><li><code>roadmap.json</code>: priority, next step, acceptance and risk.</li><li><code>timeline.json</code>: commit-backed dates and selection periods.</li><li><code>build.mjs</code>: the simple page generator; <code>style.css</code> and <code>app.js</code>: presentation and optional search.</li></ul><pre><code>cd /saved/nixos-config/guide\nnpm ci --ignore-scripts\nnpm run build\nxdg-open index.html</code></pre><p>Node is only a build tool, already available in this environment. The result works from disk without Node or any server. For GitHub Pages, publish only <code>index.html</code>, <code>style.css</code> and <code>app.js</code> at the same relative path. Review public source previews before publishing; never include credentials or the encrypted-secrets directory.</p><p>Newer software is not automatically better. Start with measured battery behavior, independent recovery and small reviewed configuration changes.</p>`);

const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Shadow · System handbook</title><link rel="stylesheet" href="style.css"><script src="app.js" defer></script></head><body>
<header><p class="eyebrow">SHADOW / NIXOS CONFIGURATION</p><h1>Your system, explained.</h1><p>Architecture, files, tools, history, research and what to improve next.<br>One static handbook. No server. No command execution.</p><p class="meta">Source review: 11 October 2026 · declarations ≠ runtime verification</p></header>
<nav aria-label="Sections">${sections.map(s=>`<a href="#${s.id}">${escape(s.title)}</a>`).join('')}</nav>
<main><label class="search">Search the handbook <input id="search" type="search" placeholder="power, backup, NVIDIA, a file path…"></label><p id="search-status" class="meta" aria-live="polite"></p><p class="notice">Modern where useful, minimal everywhere else. Proposals are not installed; timeline dates are source commits. Backup recovery and battery performance still need host testing.</p>
${sections.map(s=>`<section id="${s.id}"><h2>${escape(s.title)}</h2>${s.body}</section>`).join('\n')}
</main><footer>Shadow · static handbook · edit the Markdown and JSON, then rebuild.</footer></body></html>`;
await fs.writeFile(path.join(root,'index.html'),html);
console.log('Built one static handbook: '+files.length+' files, '+tools.items.length+' tools, '+documentCards.length+' documents.');
