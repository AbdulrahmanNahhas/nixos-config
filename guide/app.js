"use strict";
// Optional filtering only. All content and diagrams work without JavaScript.
const search = document.getElementById("search");
const entries = [...document.querySelectorAll("[data-search]")];
search.addEventListener("input", () => {
  const query = search.value.trim().toLowerCase();
  let visible = 0;
  for (const entry of entries) {
    entry.hidden = Boolean(query && !entry.textContent.toLowerCase().includes(query));
    if (!entry.hidden) visible++;
  }
  document.getElementById("search-status").textContent = query ? visible + " matching entries. Expand a title to read it." : "";
});
function openTarget() {
  let id;
  try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
  const target = document.getElementById(id);
  if (!target) return;
  if (target.tagName === "DETAILS") { target.hidden = false; target.open = true; }
  target.scrollIntoView();
}
window.addEventListener("hashchange", openTarget);
if (location.hash) openTarget();
