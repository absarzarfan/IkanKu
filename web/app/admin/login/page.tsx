"use client";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";
import { setLoggedIn } from "@/lib/mockStore";

/** MOCK login: no credential check, no network. Any well-formed email + password (>=6) passes. */
export default function AdminLogin() {
  const router = useRouter();
  const [show, setShow] = useState(false);
  const [err, setErr] = useState<{ email?: string; password?: string }>({});

  function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const email = String(f.get("email") ?? "").trim();
    const password = String(f.get("password") ?? "");
    const next: typeof err = {};
    if (!/^\S+@\S+\.\S+$/.test(email)) next.email = "Email tidak valid";
    if (password.length < 6) next.password = "Password minimal 6 karakter";
    setErr(next);
    if (Object.keys(next).length) return;
    setLoggedIn(true);
    router.push("/admin/dashboard");
  }

  return (
    <div className="grid min-h-screen bg-white lg:grid-cols-2">
      <div className="flex flex-col justify-center px-6 py-12 lg:px-[120px]">
        <Link href="/"><Image src="/img/home/logo.png" alt="IkanKu" width={120} height={63} className="mb-12 h-[63px] w-auto" /></Link>
        <h1 className="text-3xl font-bold">Log in</h1>
        <form noValidate onSubmit={onSubmit} className="mt-8 max-w-[420px] space-y-5">
          <label className="block">Email
            <input name="email" type="email" placeholder="get@ziontutorial.com" className="mt-1 h-12 w-full rounded-lg border border-black/30 px-4" />
            {err.email && <span role="alert" className="text-sm text-red-orange-600">{err.email}</span>}
          </label>
          <label className="block">Password
            <input name="password" type={show ? "text" : "password"} placeholder="Password" className="mt-1 h-12 w-full rounded-lg border border-black/30 px-4" />
            {err.password && <span role="alert" className="text-sm text-red-orange-600">{err.password}</span>}
          </label>
          <div className="flex items-center justify-between text-sm">
            <label className="flex items-center gap-2"><input type="checkbox" checked={show} onChange={(e) => setShow(e.target.checked)} /> Show password</label>
            <span className="text-brand">Forgot password?</span>
          </div>
          <button type="submit" className="h-12 w-full btn-primary rounded-lg">Log in</button>
          <p className="text-xs text-muted">Demo: login tiruan, belum terhubung ke backend.</p>
        </form>
      </div>
      <div className="hidden items-center justify-center bg-brand p-12 lg:flex">
        <p className="max-w-[420px] text-center text-[34px] font-bold leading-tight text-white">Temukan Aneka Ikan Segar di IkanKu</p>
      </div>
    </div>
  );
}
