import { id } from "./id";
import { en } from "./en";
import type { Dict } from "./types";
import type { Lang } from "./config";

export type { Dict } from "./types";
export * from "./config";

const dictionaries: Record<Lang, Dict> = { id, en };

/** Server-side dictionary lookup. Pass only the strings a client component needs as props. */
export function getDictionary(lang: Lang): Dict {
  return dictionaries[lang];
}
