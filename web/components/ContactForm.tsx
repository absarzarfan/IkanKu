"use client";
import { useState, type FormEvent } from "react";

type Errors = Partial<Record<"nama" | "email" | "telepon" | "layanan" | "pesan", string>>;

const inputCls =
  "h-10 w-full rounded-lg bg-white px-4 text-base text-ink placeholder:text-[#757575] focus:outline-2 focus:outline-accent";

/** Front-end only: validates locally, sends nothing (no backend exists). */
export default function ContactForm() {
  const [errors, setErrors] = useState<Errors>({});
  const [sent, setSent] = useState(false);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const v = (k: string) => String(f.get(k) ?? "").trim();
    const err: Errors = {};
    if (!v("nama")) err.nama = "Nama wajib diisi";
    if (!/^\S+@\S+\.\S+$/.test(v("email"))) err.email = "Email tidak valid";
    if (!/^[+0-9][0-9\s-]{7,}$/.test(v("telepon"))) err.telepon = "Nomor telepon tidak valid";
    if (!v("layanan")) err.layanan = "Pilih layanan";
    if (v("pesan").length < 10) err.pesan = "Pesan minimal 10 karakter";
    setErrors(err);
    setSent(Object.keys(err).length === 0);
    if (Object.keys(err).length === 0) e.currentTarget.reset();
  }

  const fe = (k: keyof Errors) =>
    errors[k] ? <p role="alert" className="mt-1 text-sm text-[#ffd4d0]">{errors[k]}</p> : null;

  return (
    <form noValidate onSubmit={onSubmit} className="rounded-2xl bg-brand p-6 text-white shadow-[0_4px_4px_rgba(0,0,0,.25)] lg:px-[43px] lg:py-8">
      <h3 className="mb-6 text-2xl lg:text-[32px] lg:leading-[52px]">Kirimkan Saran Anda</h3>
      <div className="grid gap-5 sm:grid-cols-2">
        <label>Nama<input name="nama" placeholder="Nama" className={`${inputCls} mt-1`} />{fe("nama")}</label>
        <label>Email<input name="email" type="email" placeholder="Email" className={`${inputCls} mt-1`} />{fe("email")}</label>
        <label>Telepon<input name="telepon" type="tel" placeholder="Telepon" className={`${inputCls} mt-1`} />{fe("telepon")}</label>
        <label>Layanan
          <select name="layanan" defaultValue="" className={`${inputCls} mt-1 text-[#757575]`}>
            <option value="" disabled>Layanan</option>
            <option>Pembelian</option>
            <option>Pengiriman</option>
            <option>Akun</option>
            <option>Lainnya</option>
          </select>
          {fe("layanan")}
        </label>
        <label className="sm:col-span-2">Pesan
          <textarea name="pesan" placeholder="Tulis Pesan" rows={5} className={`${inputCls} mt-1 h-[137px] resize-none py-3`} />
          {fe("pesan")}
        </label>
      </div>
      <button type="submit" className="mt-6 h-[38px] rounded-lg bg-accent px-[42px] text-white transition hover:brightness-95">Submit</button>
      {sent && <p role="status" className="mt-4 text-sm">Terima kasih! Saran Anda tercatat (demo: belum dikirim ke server).</p>}
    </form>
  );
}
