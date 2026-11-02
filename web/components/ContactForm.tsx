"use client";
import { useState, type FormEvent } from "react";

type Errors = Partial<Record<"nama" | "email" | "telepon" | "layanan" | "pesan", string>>;

const inputCls =
  "h-11 w-full rounded-lg bg-white px-4 text-base text-ink placeholder:text-placeholder focus:outline-2 focus:outline-white";

/** Front-end only: validates locally, sends nothing (no backend exists). */
export default function ContactForm() {
  const [errors, setErrors] = useState<Errors>({});
  const [sent, setSent] = useState(false);
  const [sending, setSending] = useState(false);

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
    setSent(false);
    if (Object.keys(err).length > 0) return;
    const form = e.currentTarget;
    setSending(true);
    // Demo only: there is no backend, so the "send" is simulated.
    window.setTimeout(() => { setSending(false); setSent(true); form.reset(); }, 600);
  }

  const fe = (k: keyof Errors) =>
    errors[k] ? <p id={`err-${k}`} role="alert" className="mt-1 text-sm font-medium text-white">{errors[k]}</p> : null;
  const inv = (k: keyof Errors) => ({ "aria-invalid": errors[k] ? true : undefined, "aria-describedby": errors[k] ? `err-${k}` : undefined });
  const hasErrors = Object.keys(errors).length > 0;

  return (
    <form noValidate onSubmit={onSubmit} className="rounded-2xl bg-brand surface-brand p-6 text-white shadow-[0_18px_40px_-18px_rgba(5,3,21,.55)] lg:px-[43px] lg:py-8">
      <h3 className="mb-6 text-2xl lg:text-h2 lg:leading-[52px]">Kirimkan Saran Anda</h3>
      <div className="grid gap-5 sm:grid-cols-2">
        <label>Nama<input name="nama" {...inv("nama")} placeholder="Nama" className={`${inputCls} mt-1`} />{fe("nama")}</label>
        <label>Email<input name="email" {...inv("email")} type="email" placeholder="Email" className={`${inputCls} mt-1`} />{fe("email")}</label>
        <label>Telepon<input name="telepon" {...inv("telepon")} type="tel" placeholder="Telepon" className={`${inputCls} mt-1`} />{fe("telepon")}</label>
        <label>Layanan
          <select name="layanan" {...inv("layanan")} defaultValue="" className={`${inputCls} mt-1 text-placeholder`}>
            <option value="" disabled>Layanan</option>
            <option>Pembelian</option>
            <option>Pengiriman</option>
            <option>Akun</option>
            <option>Lainnya</option>
          </select>
          {fe("layanan")}
        </label>
        <label className="sm:col-span-2">Pesan
          <textarea name="pesan" {...inv("pesan")} placeholder="Tulis Pesan" rows={5} className={`${inputCls} mt-1 h-[137px] resize-none py-3`} />
          {fe("pesan")}
        </label>
      </div>
      <button type="submit" disabled={sending} className="mt-6 inline-flex min-h-11 items-center gap-2 btn-cta rounded-lg px-[42px]">{sending && <span aria-hidden className="spin size-4 rounded-full border-2 border-white/40 border-t-white" />}{sending ? "Mengirim..." : "Submit"}</button>
      {hasErrors && !sending && <p role="alert" className="mt-4 text-sm">Periksa kembali isian yang ditandai, lalu kirim lagi.</p>}
      {sent && <p role="status" className="mt-4 text-sm">Terima kasih! Saran Anda tercatat (demo: belum dikirim ke server).</p>}
    </form>
  );
}
