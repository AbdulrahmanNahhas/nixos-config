"use strict";
(() => {
  const $ = id => document.getElementById(id);
  const esc = value => String(value).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
  const lessons = window.shadowLessons;
  let completed = new Set(), active = 0, toastTimer;
  try {
    const saved = JSON.parse(localStorage.getItem("shadow-lessons") || "[]");
    if (Array.isArray(saved)) completed = new Set(saved.filter(id => lessons.some(l => l.id === id)));
    if (localStorage.getItem("shadow-theme") === "light") document.documentElement.classList.add("light");
  } catch (_) { /* file URLs/private browsing may disable local storage */ }
  function notify(message) { $("toast").textContent = message; $("toast").classList.add("visible"); clearTimeout(toastTimer); toastTimer = setTimeout(() => $("toast").classList.remove("visible"), 1800); }
  function save() { try { localStorage.setItem("shadow-lessons", JSON.stringify([...completed])); } catch (_) {} }
  function nav() {
    const query = $("search").value.toLowerCase().trim();
    let group = "", html = "";
    lessons.forEach((l, i) => {
      if (query && !(l.title + " " + l.subtitle + " " + l.body.replace(/<[^>]+>/g, " ")).toLowerCase().includes(query)) return;
      if (l.group !== group) { group = l.group; html += `<div class="group">${esc(group)}</div>`; }
      html += `<a href="#${l.id}" class="${i === active ? "active" : ""}" ${i === active ? 'aria-current="page"' : ""}><span class="num ${completed.has(l.id) ? "done" : ""}">${completed.has(l.id) ? "✓" : String(i + 1).padStart(2,"0")}</span><span>${esc(l.title)}</span></a>`;
    });
    $("nav").innerHTML = html || '<p class="small">No matching lessons. Try a broader term.</p>';
    $("progress").value = completed.size / lessons.length * 100;
    $("progressText").textContent = `${completed.size} / ${lessons.length} understood`;
  }
  function render() {
    const id = location.hash.slice(1) || "orientation";
    active = Math.max(0, lessons.findIndex(l => l.id === id));
    const l = lessons[active];
    $("lesson").innerHTML = `<p class="eyebrow">${esc(l.group)} / ${String(active+1).padStart(2,"0")}</p><h1>${esc(l.title)}</h1><p class="lead">${esc(l.subtitle)}</p><div class="meta"><span>Inside Shadow</span><span>Concepts + your configuration</span><span>Offline lesson</span></div>${l.body}<div class="sources"><h3>Primary sources & deeper reading</h3>${l.sources.map(([name,url])=>`<a href="${esc(url)}" target="_blank" rel="noopener noreferrer">${esc(name)} ↗</a>`).join("")}</div>`;
    $("lesson").querySelectorAll("pre").forEach(pre => {
      const button = document.createElement("button"); button.className="copy"; button.type="button"; button.textContent="Copy example";
      button.addEventListener("click", async () => { const value = pre.querySelector("code").textContent; try { await navigator.clipboard.writeText(value); notify("Copied. Review before running."); } catch (_) { const range=document.createRange(); range.selectNodeContents(pre.querySelector("code")); const selection=window.getSelection(); selection.removeAllRanges(); selection.addRange(range); notify("Example selected; copy with your keyboard."); } }); pre.prepend(button);
    });
    $("previous").disabled = active === 0; $("next").disabled = active === lessons.length-1;
    $("understood").textContent = completed.has(l.id) ? "✓ Understood · undo" : "Mark understood";
    renderLab(l.lab); renderQuiz(l.quiz); nav();
    document.body.classList.remove("menu-open"); $("menu").setAttribute("aria-expanded","false");
  }
  function renderQuiz(quiz) {
    const area=$("knowledge"); area.hidden=!quiz; if (!quiz) { area.innerHTML=""; return; }
    const [question, answers, correct, explanation] = quiz;
    area.innerHTML=`<span class="lab-tag">CHECK YOUR UNDERSTANDING</span><p class="question">${esc(question)}</p>${answers.map((a,i)=>`<button class="answer" type="button" data-answer="${i}">${esc(a)}</button>`).join("")}<p class="feedback" role="status"></p>`;
    area.querySelectorAll("[data-answer]").forEach(button=>button.addEventListener("click",()=>{ const ok=Number(button.dataset.answer)===correct; area.querySelector(".feedback").textContent=(ok?"Correct. ":"Try again. ")+explanation; }));
  }
  function renderLab(kind) {
    const area=$("lab"); area.hidden=!kind; area.innerHTML=""; if(!kind) return;
    const base=(title,inner)=>{area.innerHTML=`<span class="lab-tag">INTERACTIVE LAB · SIMULATION</span><h2>${title}</h2>${inner}`;};
    const choice=(items,handler)=>{area.querySelectorAll("[data-choice]").forEach(button=>button.addEventListener("click",()=>{area.querySelectorAll("[data-choice]").forEach(b=>b.classList.remove("selected")); button.classList.add("selected"); handler(button.dataset.choice);})); handler(items[0]);};
    const buttons=items=>`<div class="controls">${items.map((x,i)=>`<button type="button" data-choice="${esc(x[0])}" class="${i===0?"selected":""}">${esc(x[1])}</button>`).join("")}</div>`;
    if(kind==="map") {
      const mapping={source:["flake.nix + flake.lock","Inputs, resolved revisions, and named outputs. Updating this source does not activate it."],host:["shadow/default.nix","Machine facts and NixOS imports. Also wires Home Manager and passes shared arguments."],system:["modules/nixos/","Services, hardware, networking, security, storage, login, and desktop integration."],home:["shadow/home.nix → modules/home/","Aqua’s programs, settings, shell, launchers, MIME associations, and session preferences."],state:["/saved + Preservation","Mutable data and credentials that survive reboot. Separate backups are required."],runtime:["/run + running services","Generated secrets and live processes. These must be tested after activation."]};
      base("Explore the ownership map",buttons([["source","Source"],["host","Host"],["system","System"],["home","User"],["state","Saved data"],["runtime","Runtime"]])+ '<div class="result" id="map-result" aria-live="polite"></div>');
      choice(["source"],id=>{$("map-result").innerHTML=`<h3>${esc(mapping[id][0])}</h3><p>${esc(mapping[id][1])}</p>`;});
    }
    if(kind==="lifecycle") {
      const stages={edit:["Only repository files change.","Current system: old generation.","Data: unchanged by the edit."],update:["Input pins change in flake.lock.","Current system: old generation.","New versions still need review and build."],check:["Options are evaluated and checks run.","Current system: old generation.","A passing check does not prove runtime correctness."],build:["A new system closure is realized in /nix/store.","Current system: old generation.","No activation. Both closures may exist."],test:["New settings are activated temporarily.","Current system: new configuration; default next boot remains previous selection.","Services can restart and mutable data can change."],switch:["New generation is activated and selected for boot.","Current system: new configuration.","Kernel/boot behavior still needs reboot testing."],rollback:["Select a known previous configuration generation.","Packages/settings return to those references.","Mutable data and provider-side token changes do not rewind."]};
      base("Predict what each action changes",buttons(Object.keys(stages).map(x=>[x,x[0].toUpperCase()+x.slice(1)]))+'<div class="result" id="life-result" aria-live="polite"></div>');
      choice(["edit"],id=>{$("life-result").innerHTML=stages[id].map(s=>`<p>${esc(s)}</p>`).join("");});
    }
    if(kind==="owner") {
      const owners={flatpak:["Flatpak catalog","modules/nixos/services/flatpak-apps.nix","Add one app entry; review origin and permissions. Its data directory is derived."],native:["Home Manager program module","modules/home/programs/","Install and configure it in its own module; import it and add desired persistence."],cli:["Shared package list","modules/home/packages/cli.nix","Use home.packages for ordinary shared command-line tools."],service:["NixOS service module","modules/nixos/services/","Configure the service, runtime credentials, exposure, and state."],project:["Project environment","Your project’s devenv.nix","Pin the project’s tools without changing unrelated projects."],hardware:["Host facts","shadow/","Keep PCI addresses, disk layout, and machine-specific facts here."]};
      base("Choose what you are adding",'<label for="owner-type">Type of change</label><select id="owner-type">'+Object.keys(owners).map(x=>`<option value="${x}">${esc(owners[x][0])}</option>`).join("")+'</select><div class="result" id="owner-result" aria-live="polite"></div>');
      const show=()=>{const entry=owners[$("owner-type").value]; $("owner-result").innerHTML=`<code>${esc(entry[1])}</code><p>${esc(entry[2])}</p>`;}; $("owner-type").addEventListener("change",show); show();
    }
    if(kind==="app") {
      base("Design a catalog entry",'<p class="small">Generates an example only. It does not check Flathub availability or install anything.</p><label for="app-id">Application ID</label><input id="app-id" value="org.example.App" spellcheck="false"><label for="app-origin">Origin</label><select id="app-origin"><option>flathub-verified</option><option>flathub</option><option>flathub-beta</option></select><label class="check-row"><input id="app-download" type="checkbox">Needs read-only Downloads access</label><label class="check-row"><input id="app-persist" type="checkbox" checked>Retain app data after reboot</label><pre><code id="app-code"></code></pre><div class="result" id="app-result" aria-live="polite"></div>');
      const show=()=>{const id=$("app-id").value.trim(),valid=/^[A-Za-z][A-Za-z0-9_-]*(\.[A-Za-z][A-Za-z0-9_-]*){2,}$/.test(id); if(!valid){$("app-code").textContent="Enter a reverse-DNS style ID such as org.example.App."; $("app-result").textContent="No entry generated.";return;} const lines=[`"${id}" = {`]; if($("app-origin").value!=="flathub-verified") lines.push(`  origin = "${$("app-origin").value}";`); if(!$("app-persist").checked) lines.push("  persist = false;"); if($("app-download").checked) lines.push('  overrides.Context.filesystems = [ "xdg-download:ro" ];');lines.push("};");$("app-code").textContent=lines.join("\n");$("app-result").innerHTML=`<p>Install from <strong>${esc($("app-origin").value)}</strong>.</p><p>${$("app-persist").checked?`Preserve <code>~/.var/app/${esc(id)}</code>.`:"Do not add app-data preservation."}</p><p>Review manifest permissions and user overrides before assuming this is the complete sandbox policy.</p>`;}; area.querySelectorAll("input,select").forEach(el=>el.addEventListener("input",show)); show();
    }
    if(kind==="sandbox") {
      base("Compare inherited filesystem access",'<p class="small">Hypothetical manifest grants: home, Documents, Downloads. This is a teaching model, not a live permission check.</p><label class="check-row"><input id="deny-home" type="checkbox" checked>Deny broad home/host access</label><label class="check-row"><input id="reset-fs" type="checkbox">Reset inherited filesystem grants</label><label class="check-row"><input id="allow-download" type="checkbox">Explicitly allow Downloads read-only</label><div class="result" id="sandbox-result" aria-live="polite"></div>');
      const show=()=>{const reset=$("reset-fs").checked,deny=$("deny-home").checked,allow=$("allow-download").checked; let access=reset?[]:[...(deny?[]:["Broad home read/write"]),"Documents read/write","Downloads read/write"]; if(allow){access=access.filter(x=>!x.startsWith("Downloads"));access.push("Downloads read-only");}$("sandbox-result").innerHTML=`<h3>Remaining modeled access</h3>${access.length?access.map(a=>`<span class="path">${esc(a)}</span>`).join(""):"<p>No directly granted folders in this model. A file portal may still grant selected files.</p>"}<p>Filesystem access says nothing by itself about network, devices, sockets, or D-Bus capabilities.</p>`;};area.querySelectorAll("input").forEach(el=>el.addEventListener("change",show));show();
    }
    if(kind==="persistence") {
      const paths=[["Downloads/report.pdf",false],["Documents/report.pdf",true],["/run/secrets/example",false],["/saved/nixos-config",true],["~/.var/app/a-declared-app",true],["An undeclared native app profile",false]];
      base("What happens when the laptop reboots?",'<label for="state-path">Choose a location</label><select id="state-path">'+paths.map((x,i)=>`<option value="${i}">${esc(x[0])}</option>`).join("")+'</select>'+buttons([["now","Before reboot"],["reboot","After reboot"]])+'<div class="result" id="state-result" aria-live="polite"></div>');
      let reboot=false;const show=()=>{const [path,saved]=paths[Number($("state-path").value)];$("state-result").innerHTML=`<h3>${esc(path)}</h3><p>${!reboot?"May exist during this session.":saved?"Retained through persistent storage.":"Not retained by this model. Runtime secrets are regenerated during successful activation."}</p><p>Persistence protects continuity across reboot. It does not create an independent backup.</p>`;};choice(["now"],id=>{reboot=id==="reboot";show();});$("state-path").addEventListener("change",show);
    }
    if(kind==="keys") {
      base("Which identity can decrypt?",'<p class="small">Ciphertext is encrypted to both Aqua and Shadow recipients. No real keys are used here.</p><label class="check-row"><input id="admin-key" type="checkbox" checked>Aqua private identity is available</label><label class="check-row"><input id="host-key" type="checkbox">Shadow private identity is available</label><div class="result" id="keys-result" aria-live="polite"></div>');
      const show=()=>{$("keys-result").innerHTML=`<h3>${$("admin-key").checked||$("host-key").checked?"A recipient identity can decrypt.":"Neither private identity is available."}</h3><p>${$("admin-key").checked||$("host-key").checked?"Either authorized identity is enough. This is not two-factor encryption.":"Public recipients cannot recover a private identity. Restore an independent identity backup."}</p>`;};area.querySelectorAll("input").forEach(el=>el.addEventListener("change",show));show();
    }
    if(kind==="secret") {
      const phases=[["encrypt","SOPS creates ciphertext for the existing recipients. No service is configured yet."],["commit","Git stores ciphertext and public recipient metadata. Do not commit plaintext."],["declare","A sops-nix declaration chooses a runtime file, owner, mode, and consumer."],["activate","sops-nix uses the deployment identity to decrypt into protected /run paths."],["consume","The application reads its runtime file. Its process can see the plaintext it needs."],["reboot","Runtime files disappear and are regenerated if activation and identity access succeed."]];
      base("Trace a secret through the system",buttons(phases.map(([id])=>[id,id[0].toUpperCase()+id.slice(1)]))+'<div class="result" id="secret-result" aria-live="polite"></div>');choice(["encrypt"],id=>{$("secret-result").textContent=phases.find(x=>x[0]===id)[1];});
    }
    if(kind==="network") {
      base("An icon is not a routing test",'<p class="small">A conceptual checklist. These controls do not establish your actual network state.</p><label class="check-row"><input id="net-vpn" type="checkbox" checked>VPN is connected</label><label class="check-row"><input id="net-v6" type="checkbox">IPv6 route coverage is verified</label><label class="check-row"><input id="net-dns" type="checkbox">System and browser DNS routing are verified</label><label class="check-row"><input id="net-fail" type="checkbox">Disconnect behavior is verified</label><div class="result" id="net-result" aria-live="polite"></div>');
      const show=()=>{const missing=[];if(!$("net-vpn").checked)missing.push("Tunnel is disconnected: inspect the intended non-VPN policy.");if(!$("net-v6").checked)missing.push("IPv6 may follow a different route from IPv4.");if(!$("net-dns").checked)missing.push("DNS ownership and browser DNS paths remain unverified.");if(!$("net-fail").checked)missing.push("Tunnel failure behavior remains unverified.");$("net-result").innerHTML=missing.length?missing.map(x=>`<p>${esc(x)}</p>`).join(""):"<p>You have covered the key test categories in this model. Only real tests can confirm actual routing and failure behavior.</p>";};area.querySelectorAll("input").forEach(el=>el.addEventListener("change",show));show();
    }
    if(kind==="recovery") {
      const cases={driver:["Broken driver after update","Choose a known older boot generation. Confirm hardware behavior afterward."],data:["Deleted documents","Restore from a verified data backup or suitable snapshot. Package rollback alone cannot restore them."],disk:["Internal disk lost","Restore off-device backups and independent recovery identities. Local snapshots on the lost disk are also gone."],key:["One age identity lost","Use the remaining authorized identity to rewrap for a new identity, then verify deployment."],both:["Both age identities lost","Restore an independent private-identity backup. Public recipients are insufficient."]};
      base("Pick the recovery mechanism",buttons(Object.keys(cases).map(id=>[id,cases[id][0]]))+'<div class="result" id="recovery-result" aria-live="polite"></div>');choice(["driver"],id=>{$("recovery-result").textContent=cases[id][1];});
    }
    if(kind==="inventory") {
      base("Find a catalog entry",'<label for="inventory-filter">App ID search</label><input id="inventory-filter" type="search" placeholder="signal, prism, libreoffice…"><div class="inventory table-wrap" id="inventory-result"></div><p class="small">Snapshot generated from the catalog during this revision. Update it when catalog entries change.</p>');
      const show=()=>{const query=$("inventory-filter").value.toLowerCase();const apps=(window.shadowApps||[]).filter(x=>x.id.toLowerCase().includes(query));$("inventory-result").innerHTML='<table><tr><th>App ID</th><th>Origin</th><th>State</th><th>Exceptions</th></tr>'+apps.map(x=>`<tr><td><code>${esc(x.id)}</code></td><td>${esc(x.origin)}</td><td>${x.persist?"Retained":"None"}</td><td>${x.exceptions?"Declared":"Baseline"}</td></tr>`).join("")+'</table>';};$("inventory-filter").addEventListener("input",show);show();
    }
  }
  $("search").addEventListener("input",nav);
  $("previous").addEventListener("click",()=>{if(active>0)location.hash=lessons[active-1].id;});
  $("next").addEventListener("click",()=>{if(active<lessons.length-1)location.hash=lessons[active+1].id;});
  $("understood").addEventListener("click",()=>{const id=lessons[active].id;if(completed.has(id))completed.delete(id);else completed.add(id);save();$("understood").textContent=completed.has(id)?"✓ Understood · undo":"Mark understood";nav();});
  $("reset").addEventListener("click",()=>{completed.clear();save();render();notify("Learning progress reset.");});
  $("theme").addEventListener("click",()=>{const light=document.documentElement.classList.toggle("light");$("theme").textContent=light?"Dark theme":"Light theme";try{localStorage.setItem("shadow-theme",light?"light":"dark");}catch(_){}});
  $("theme").textContent=document.documentElement.classList.contains("light")?"Dark theme":"Light theme";
  $("menu").addEventListener("click",()=>{const open=document.body.classList.toggle("menu-open");$("menu").setAttribute("aria-expanded",String(open));});
  $("nav").addEventListener("click",()=>{document.body.classList.remove("menu-open");$("menu").setAttribute("aria-expanded","false");});
  window.addEventListener("hashchange",()=>{render();window.scrollTo(0,0);$("main").focus({preventScroll:true});});
  render();
})();
