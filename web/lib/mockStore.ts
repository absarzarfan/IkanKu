"use client";
import { useMemo, useSyncExternalStore } from "react";

// Front-end-only mock persistence (browser localStorage). No backend, no auth, no network.
export type Post = { id: string; title: string; body: string; status: "DRAF" | "TERBIT"; savedAt: string };
export type Profile = {
  nama: string; username: string; posisi: string; email: string; telepon: string; ttl: string; gender: string;
};

export const defaultProfile: Profile = {
  nama: "Hafid Daris",
  username: "hafid.daris",
  posisi: "Admin",
  email: "admin@ikanku.example",
  telepon: "0812-0000-0000",
  ttl: "Batam, 01-01-2000",
  gender: "Laki-laki",
};

const KEYS = { posts: "ikanku.mock.posts", profile: "ikanku.mock.profile", session: "ikanku.mock.session" } as const;
const EVENT = "ikanku-mock-change";
const EMPTY = Symbol("loading");

function raw(key: string): string | null {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}
function write(key: string, value: unknown) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
  } catch {
    /* storage unavailable: ignore */
  }
  window.dispatchEvent(new Event(EVENT));
}
function subscribe(cb: () => void) {
  window.addEventListener(EVENT, cb);
  window.addEventListener("storage", cb);
  return () => {
    window.removeEventListener(EVENT, cb);
    window.removeEventListener("storage", cb);
  };
}

/** Returns parsed value, or `undefined` while hydrating on the server/first render. */
function useStored<T>(key: string, fallback: T): T | undefined {
  const r = useSyncExternalStore(subscribe, () => raw(key) ?? "", () => EMPTY as unknown as string);
  return useMemo(() => {
    if ((r as unknown) === EMPTY) return undefined;
    if (!r) return fallback;
    try {
      return JSON.parse(r) as T;
    } catch {
      return fallback;
    }
  }, [r, fallback]);
}

const NO_POSTS: Post[] = [];
export const usePosts = () => useStored<Post[]>(KEYS.posts, NO_POSTS);
export const useProfile = () => useStored<Profile>(KEYS.profile, defaultProfile);
export const useLoggedIn = () => useStored<boolean>(KEYS.session, false);

export const getPosts = (): Post[] => {
  try {
    return JSON.parse(raw(KEYS.posts) ?? "[]") as Post[];
  } catch {
    return [];
  }
};
export const savePosts = (p: Post[]) => write(KEYS.posts, p);
export const saveProfile = (p: Profile) => write(KEYS.profile, p);
export const setLoggedIn = (v: boolean) => write(KEYS.session, v);
