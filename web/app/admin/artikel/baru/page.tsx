"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { getPosts, savePosts } from "@/lib/mockStore";

const MAX_TITLE = 80;
const stamp = () => {
  const d = new Date();
  const p = (n: number) => String(n).padStart(2, "0");
  return `${p(d.getDate())}-${p(d.getMonth() + 1)}-${d.getFullYear()} ${p(d.getHours())}.${p(d.getMinutes())}`;
};

/** Local-only editor: title (max 80), body with char/word counters, save draft / publish to localStorage. */
export default function TambahArtikel() {
  const router = useRouter();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [saved, setSaved] = useState<string | null>(null);
  const [error, setError] = useState("");
  const words = body.trim() ? body.trim().split(/\s+/).length : 0;

  function save(status: "DRAF" | "TERBIT") {
    if (!title.trim()) return setError("Judul wajib diisi");
    if (status === "TERBIT" && body.trim().length < 20) return setError("Isi artikel minimal 20 karakter untuk diterbitkan");
    setError("");
    const at = stamp();
    savePosts([{ id: String(Date.now()), title: title.trim(), body, status, savedAt: at }, ...getPosts()]);
    setSaved(at);
    if (status === "TERBIT") router.push("/admin/dashboard");
  }

  return (
    <AdminShell>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-3xl font-bold text-brand">Tambah Artikel</h1>
        <p className="text-sm text-muted">{saved ? `tersimpan sebagai DRAF ${saved}` : "belum disimpan"}</p>
      </div>
      <div className="mt-6 rounded-2xl bg-white p-6">
        <input value={title} maxLength={MAX_TITLE} onChange={(e) => setTitle(e.target.value)} placeholder="Tulis judul disini" aria-label="Judul" className="w-full border-b border-black/20 pb-3 text-2xl font-bold outline-none focus:border-brand md:text-h2" />
        <p className="mt-2 text-sm text-muted">Karakter judul : {title.length}/{MAX_TITLE}</p>
        <textarea value={body} onChange={(e) => setBody(e.target.value)} placeholder="Mulai Menulis Cerita...." aria-label="Isi artikel" rows={14} className="mt-6 w-full resize-y rounded-lg border border-black/10 p-4 outline-none focus:border-brand" />
        <p className="mt-2 text-sm text-muted">Karakter : {body.length} &nbsp; Kata : {words}</p>
        {error && <p role="alert" className="mt-3 text-red-orange-600">{error}</p>}
        <div className="mt-6 flex gap-4">
          <button type="button" onClick={() => save("DRAF")} className="rounded-lg border border-black px-6 py-2 hover:bg-surface">Simpan Draf</button>
          <button type="button" onClick={() => save("TERBIT")} className="rounded-lg bg-accent px-6 py-2 text-white hover:brightness-95">Terbitkan</button>
        </div>
      </div>
    </AdminShell>
  );
}
