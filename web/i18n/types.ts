import type { id } from "./id";

type Widen<T> = T extends string ? string : T extends readonly (infer U)[] ? Widen<U>[] : { [K in keyof T]: Widen<T[K]> };

/** Shape of every dictionary: the keys of id.ts with plain string values. */
export type Dict = Widen<typeof id>;
