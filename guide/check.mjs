// Check the generated handbook for offline and GitHub Pages use. No npm packages.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const source = path.dirname(fileURLToPath(import.meta.url));
const output = path.resolve(process.argv[2] || source);
const expected = ['index.html', ...fs.readdirSync(path.join(source, 'pages'))
  .filter(name => name.endsWith('.md') && name !== '_index.md')
  .map(name => JSON.parse(fs.readFileSync(path.join(source, 'pages', name), 'utf8')).url.slice(1))];
const pages = new Map(expected.map(name => [name, fs.readFileSync(path.join(output, name), 'utf8')]));
const ids = new Map();
const errors = [];
for (const [name, html] of pages) {
  const all = [...html.matchAll(/\bid="([^"]+)"/g)].map(match => match[1]);
  ids.set(name, new Set(all));
  if (all.length !== ids.get(name).size) errors.push(name + ': duplicate IDs');
  if (html.includes('\0')) errors.push(name + ': binary content');
  const nav = html.match(/<nav aria-label="Handbook">([\s\S]*?)<\/nav>/)?.[1] || '';
  if ((nav.match(/href=/g) || []).length !== expected.length) errors.push(name + ': incomplete sidebar');
  if ((nav.match(/aria-current="page"/g) || []).length !== 1) errors.push(name + ': wrong current-page marker');
}
for (const [name, html] of pages) {
  for (const match of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    const url = match[1];
    if (/^[a-z][a-z0-9+.-]*:/i.test(url)) continue;
    if (url.startsWith('/') || url.startsWith('//')) {
      errors.push(name + ': nonportable URL ' + url);
      continue;
    }
    const [file, fragment] = url.split('#');
    const target = path.normalize(path.join(path.dirname(name), file || name));
    if (!fs.existsSync(path.join(output, target))) errors.push(name + ': missing file ' + url);
    else if (fragment && ids.has(target) && !ids.get(target).has(decodeURIComponent(fragment))) errors.push(name + ': missing anchor ' + url);
  }
}
const generated = fs.readdirSync(output).filter(name => output !== source || name.endsWith('.html'));
for (const name of generated) {
  if (!expected.includes(name) && name !== '.nojekyll') errors.push('Unexpected publication file: ' + name);
}
// Only explicit replacement, update and removal edges end a component period.
const history = JSON.parse(fs.readFileSync(path.join(source, 'timeline.json'), 'utf8'));
const stages = history.lanes.flatMap(lane => lane.stages);
const records = new Map(stages.map(stage => [stage.id, stage]));
if (records.size !== stages.length) errors.push('History: duplicate record IDs');
const endings = new Map();
for (const stage of stages) {
  if (!['baseline','added','replaced','updated','configured','removed'].includes(stage.change)) errors.push('History: unknown change type ' + stage.id);
  for (const type of ['replaces', 'updates', 'removes']) if (stage[type]) {
    const previous = records.get(stage[type]);
    if (!previous || !stage.date || (previous.date && stage.date <= previous.date)) errors.push('History: invalid ' + type + ' edge ' + stage.id);
    if (endings.has(stage[type])) errors.push('History: multiple ending events for ' + stage[type]);
    endings.set(stage[type], stage);
  }
  for (const id of [...(stage.buildsOn || []), ...(stage.complements || [])]) if (!records.has(id)) errors.push('History: missing foundation ' + id);
  if ((stage.commits || []).some(commit => !/^[a-f0-9]{7,40}$/.test(commit))) errors.push('History: invalid commit evidence ' + stage.id);
}
const dates = stages.map(stage => stage.date).filter(Boolean).sort();
const first = Date.parse(dates[0].slice(0,7) + '-01T00:00:00Z');
const last = new Date(dates.at(-1));
const end = Date.UTC(last.getUTCFullYear(), last.getUTCMonth()+1, 1);
const column = date => date ? 3 + (Date.parse(date + 'T00:00:00Z') - first)/86400000 : 2;
const expectedBars = stages.map(stage => [column(stage.date), stage.change === 'removed' ? column(stage.date)+1 : endings.has(stage.id) ? column(endings.get(stage.id).date) : 3+(end-first)/86400000]);
const actualBars = [...pages.get('history.html').matchAll(/data-start="(\d+)" data-end="(\d+)"/g)].map(match => [Number(match[1]),Number(match[2])]);
if (JSON.stringify(expectedBars) !== JSON.stringify(actualBars) || actualBars.some(([start,finish])=>finish<=start)) errors.push('History: invalid relationship-based periods');
const technologyCards = [...pages.get('technologies.html').matchAll(/<details[^>]+>/g)].map(match => match[0]);
if (!technologyCards[0]?.includes('release-watch') || !technologyCards[0]?.includes(' open')) errors.push('Technologies: release watchlist must be first and open');
if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}
console.log('Checked ' + pages.size + ' pages: navigation, links, period boundaries, watchlist and publication contents.');
