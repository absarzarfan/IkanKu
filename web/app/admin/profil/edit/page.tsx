"use client";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import AdminShell from "@/components/admin/AdminShell";
import { defaultProfile, saveProfile, useProfile, type Profile } from "@/lib/mockStore";

const fields: { k: keyof Profile; label: string }[] = [
  { k: "nama", label: "Nama" },
  { k: "username", label: "Username" },
  { k: "posisi", label: "Posisi" },
  { k: "email", label: "Email" },
  { k: "telepon", label: "Nomor Telepon" },
  { k: "ttl", label: "Tempat Tanggal Lahir" },
];

function Form({ initial }: { initial: Profile }) {
  const router = useRouter();
  const [p, setP] = useState<Profile>(initial);
  const [err, setErr] = useState<Partial<Record<keyof Profile, string>>>({});

  function onSubmit(e: FormEvent) {
    e.preventDefault();
    const n: typeof err = {};
    if (!p.nama.trim()) n.nama = "Nama wajib diisi";
    if (!p.username.trim()) n.username = "Username wajib diisi";
    if (!/^\S+@\S+\.\S+$/.test(p.email)) n.email = "Email tidak valid";
    setErr(n);
    if (Object.keys(n).length) return;
    saveProfile(p);
    router.push("/admin/profil");
  }

  return (
    <form noValidate onSubmit={onSubmit} className="mt-8 grid gap-6 rounded-2xl bg-white p-6 sm:grid-cols-2">
      {fields.map((f) => (
        <label key={f.k} className="block">{f.label}
          <input value={p[f.k]} onChange={(e) => setP({ ...p, [f.k]: e.target.value })} className="mt-1 h-11 w-full rounded-lg border border-black/30 px-4" />
          {err[f.k] && <span role="alert" className="text-sm text-red-orange-600">{err[f.k]}</span>}
        </label>
      ))}
      <label className="block">Jenis Kelamin
        <select value={p.gender} onChange={(e) => setP({ ...p, gender: e.target.value })} className="mt-1 h-11 w-full rounded-lg border border-black/30 px-4">
          <option>Laki-laki</option><option>Perempuan</option>
        </select>
      </label>
      <div className="flex gap-4 sm:col-span-2">
        <button type="submit" className="rounded-lg bg-accent px-6 py-2 text-white hover:brightness-95">Simpan</button>
        <button type="button" onClick={() => router.push("/admin/profil")} className="rounded-lg border border-black px-6 py-2">Batal</button>
      </div>
    </form>
  );
}

export default function EditProfil() {
  const stored = useProfile();
  return (
    <AdminShell>
      <h1 className="text-3xl font-bold text-brand">Edit Profil</h1>
      <Form initial={stored ?? defaultProfile} />
    </AdminShell>
  );
}
