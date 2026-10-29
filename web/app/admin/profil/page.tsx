"use client";
import Link from "next/link";
import AdminShell from "@/components/admin/AdminShell";
import { defaultProfile, useProfile } from "@/lib/mockStore";

export default function Profil() {
  const p = useProfile() ?? defaultProfile;
  const rows: [string, string][] = [
    ["Username", p.username], ["Posisi", p.posisi], ["Email", p.email],
    ["Nomor Telepon", p.telepon], ["Tempat Tanggal Lahir", p.ttl], ["Jenis Kelamin", p.gender],
  ];
  return (
    <AdminShell>
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-brand">{p.nama}</h1>
        <Link href="/admin/profil/edit" className="rounded-lg bg-accent px-6 py-2 text-white hover:brightness-95">Edit Profil</Link>
      </div>
      <dl className="mt-8 grid gap-6 rounded-2xl bg-white p-6 sm:grid-cols-2">
        {rows.map(([k, v]) => (
          <div key={k}><dt className="text-sm text-muted">{k}</dt><dd className="mt-1 text-lg">{v}</dd></div>
        ))}
      </dl>
    </AdminShell>
  );
}
