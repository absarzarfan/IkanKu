"use client";
import Link from "next/link";
import { useState } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { savePosts, usePosts } from "@/lib/mockStore";

const PER = 5;

export default function Dashboard() {
  const posts = usePosts() ?? [];
  const [page, setPage] = useState(1);
  const pages = Math.max(1, Math.ceil(posts.length / PER));
  const shown = posts.slice((page - 1) * PER, page * PER);

  function remove(id: string) {
    savePosts(posts.filter((p) => p.id !== id));
  }

  return (
    <AdminShell>
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-brand">Dashboard</h1>
        <Link href="/admin/artikel/baru" className="rounded-lg bg-accent px-6 py-2 text-white hover:brightness-95">Tambah Artikel</Link>
      </div>
      <div className="mt-8 rounded-2xl bg-white p-6">
        {posts.length === 0 ? (
          <p className="py-16 text-center text-muted">belum ada postingan</p>
        ) : (
          <ul className="divide-y">
            {shown.map((p) => (
              <li key={p.id} className="flex flex-wrap items-center gap-3 py-4">
                <div className="min-w-0 flex-1">
                  <p className="truncate font-bold">{p.title || "(tanpa judul)"}</p>
                  <p className="text-sm text-muted">{p.status} - {p.savedAt}</p>
                </div>
                <button type="button" onClick={() => remove(p.id)} className="text-sm text-red-orange-600 underline">Hapus</button>
              </li>
            ))}
          </ul>
        )}
        <p className="mt-6 text-center font-bold">Page {page} of {pages}</p>
        <div className="mt-2 flex justify-center gap-6">
          <button type="button" disabled={page <= 1} onClick={() => setPage(page - 1)} className="disabled:opacity-30">Previous</button>
          <button type="button" disabled={page >= pages} onClick={() => setPage(page + 1)} className="disabled:opacity-30">Next</button>
        </div>
      </div>
    </AdminShell>
  );
}
