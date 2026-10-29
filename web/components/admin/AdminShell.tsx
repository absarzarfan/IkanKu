"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, type ReactNode } from "react";
import { setLoggedIn, useLoggedIn, useProfile } from "@/lib/mockStore";

const nav = [
  { href: "/admin/dashboard", label: "Dashboard" },
  { href: "/admin/artikel/baru", label: "Tambah Artikel" },
  { href: "/admin/profil", label: "Profil" },
];

/** Mock guard: redirects to /admin/login unless the (fake) session flag is set. Not real auth. */
export default function AdminShell({ children }: { children: ReactNode }) {
  const router = useRouter();
  const path = usePathname();
  const session = useLoggedIn();
  const profile = useProfile();
  const name = profile?.nama;

  useEffect(() => {
    if (session === false) router.replace("/admin/login");
  }, [session, router]);

  if (!session || !name) return <div className="p-10 text-center">Memuat...</div>;
  return (
    <div className="min-h-screen bg-surface">
      <header className="bg-white shadow-sm">
        <div className="mx-auto flex max-w-[1440px] flex-wrap items-center gap-4 px-6 py-3 lg:px-[82px]">
          <Link href="/"><Image src="/img/home/logo.png" alt="IkanKu" width={96} height={50} className="h-[50px] w-auto" /></Link>
          <nav className="flex flex-1 flex-wrap gap-6" aria-label="Admin">
            {nav.map((n) => (
              <Link key={n.href} href={n.href} className={path.startsWith(n.href) ? "text-brand" : "hover:text-brand"}>{n.label}</Link>
            ))}
          </nav>
          <span className="text-sm">{name}</span>
          <button type="button" onClick={() => { setLoggedIn(false); router.replace("/admin/login"); }} className="rounded-lg border border-black px-4 py-1 text-sm hover:bg-brand hover:text-white">Keluar</button>
        </div>
      </header>
      <main className="mx-auto max-w-[1440px] px-6 py-10 lg:px-[82px]">{children}</main>
    </div>
  );
}
