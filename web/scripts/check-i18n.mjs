// Fails if the Indonesian and English dictionaries have different keys or any empty value. No packages.
// Node >= 22.18 strips TypeScript types natively, so the .ts dictionaries are imported directly.
import { id } from "../i18n/id.ts";
import { en } from "../i18n/en.ts";

function flatten(value, path = "", out = new Map()) {
  if (typeof value === "string") out.set(path, value);
  else if (Array.isArray(value)) value.forEach((v, i) => flatten(v, `${path}[${i}]`, out));
  else if (value && typeof value === "object") for (const [k, v] of Object.entries(value)) flatten(v, path ? `${path}.${k}` : k, out);
  else out.set(path, value);
  return out;
}

const a = flatten(id);
const b = flatten(en);
const problems = [];
for (const k of a.keys()) if (!b.has(k)) problems.push(`missing in en: ${k}`);
for (const k of b.keys()) if (!a.has(k)) problems.push(`missing in id: ${k}`);
for (const [name, map] of [["id", a], ["en", b]]) {
  for (const [k, v] of map) if (typeof v !== "string" || v.trim() === "") problems.push(`empty value in ${name}: ${k}`);
}
// Placeholders must match ({n}, {total}, {title}, {name}).
for (const [k, v] of a) {
  const other = b.get(k);
  if (typeof v !== "string" || typeof other !== "string") continue;
  const ph = (s) => [...s.matchAll(/\{(\w+)\}/g)].map((m) => m[1]).sort().join(",");
  if (ph(v) !== ph(other)) problems.push(`placeholder mismatch: ${k}`);
}

console.log(`i18n keys: id=${a.size} en=${b.size}`);
if (problems.length) {
  console.error(problems.join("\n"));
  process.exit(1);
}
console.log("i18n OK");
