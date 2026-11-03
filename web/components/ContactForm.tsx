"use client";
import { useState, type FormEvent } from "react";

export type FormLabels = { title: string; name: string; email: string; phone: string; service: string; message: string; messagePlaceholder: string; serviceOptions: string[]; submit: string; sending: string; errName: string; errEmail: string; errPhone: string; errService: string; errMessage: string; errSummary: string; success: string };

type Errors = Partial<Record<"nama" | "email" | "telepon" | "layanan" | "pesan", string>>;

const inputCls =
  "h-11 w-full rounded-lg bg-white px-4 text-base text-ink placeholder:text-placeholder focus:outline-2 focus:outline-white";

/** Front-end only: validates locally, sends nothing (no backend exists). */
export default function ContactForm({ labels: t }: { labels: FormLabels }) {
  const [errors, setErrors] = useState<Errors>({});
  const [sent, setSent] = useState(false);
  const [sending, setSending] = useState(false);

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const v = (k: string) => String(f.get(k) ?? "").trim();
    const err: Errors = {};
    if (!v("nama")) err.nama = t.errName;
    if (!/^\S+@\S+\.\S+$/.test(v("email"))) err.email = t.errEmail;
    if (!/^[+0-9][0-9\s-]{7,}$/.test(v("telepon"))) err.telepon = t.errPhone;
    if (!v("layanan")) err.layanan = t.errService;
    if (v("pesan").length < 10) err.pesan = t.errMessage;
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
      <h3 className="mb-6 text-2xl lg:text-h2 lg:leading-[52px]">{t.title}</h3>
      <div className="grid gap-5 sm:grid-cols-2">
        <label>{t.name}<input name="nama" {...inv("nama")} placeholder={t.name} className={`${inputCls} mt-1`} />{fe("nama")}</label>
        <label>{t.email}<input name="email" {...inv("email")} type="email" placeholder={t.email} className={`${inputCls} mt-1`} />{fe("email")}</label>
        <label>{t.phone}<input name="telepon" {...inv("telepon")} type="tel" placeholder={t.phone} className={`${inputCls} mt-1`} />{fe("telepon")}</label>
        <label>{t.service}
          <select name="layanan" {...inv("layanan")} defaultValue="" className={`${inputCls} mt-1 text-placeholder`}>
            <option value="" disabled>{t.service}</option>
            {t.serviceOptions.map((o) => <option key={o}>{o}</option>)}
          </select>
          {fe("layanan")}
        </label>
        <label className="sm:col-span-2">{t.message}
          <textarea name="pesan" {...inv("pesan")} placeholder={t.messagePlaceholder} rows={5} className={`${inputCls} mt-1 h-[137px] resize-none py-3`} />
          {fe("pesan")}
        </label>
      </div>
      <button type="submit" disabled={sending} className="mt-6 inline-flex min-h-11 items-center gap-2 btn-cta rounded-lg px-[42px]">{sending && <span aria-hidden className="spin size-4 rounded-full border-2 border-white/40 border-t-white" />}{sending ? t.sending : t.submit}</button>
      {hasErrors && !sending && <p role="alert" className="mt-4 text-sm">{t.errSummary}</p>}
      {sent && <p role="status" className="mt-4 text-sm">{t.success}</p>}
    </form>
  );
}
