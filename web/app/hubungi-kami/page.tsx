import { Icon, IconChip, type IconName } from "@/components/icons";
import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import ContactForm from "@/components/ContactForm";
import Faq from "@/components/Faq";
import { contact } from "@/data/contact";

export const metadata: Metadata = { title: "Hubungi Kami - IkanKu" };

const contacts: { icon: IconName; label: string; val: string; href: string | undefined }[] = [
  { icon: "phone", label: "Telepon", val: contact.phone, href: contact.phoneHref },
  { icon: "mail", label: "Email", val: contact.email, href: contact.emailHref },
  { icon: "pin", label: "Lokasi", val: contact.address, href: undefined },
];

export default function HubungiKamiPage() {
  return (
    <SiteShell>
      <section className="curve-b relative isolate overflow-hidden">
        <Image src="/img/hubungi/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent from-50% to-brand" />
        <div className="container-page flex min-h-[320px] flex-col items-center justify-end pb-14 text-white lg:min-h-[600px] lg:pb-[130px]">
          <h1 className="text-4xl font-bold lg:text-h1">Hubungi Kami</h1>
          <p className="mt-4 flex items-center gap-2 text-base font-bold">
            <Icon name="home" size={20} />
            <Link href="/" className="underline">Beranda</Link> <span>- Hubungi Kami</span>
          </p>
        </div>
      </section>

      <Faq />

      <section className="container-page section-y grid gap-10 lg:grid-cols-2 lg:gap-[80px]">
        <div>
          <h2 className="text-3xl font-bold leading-[1.15] text-brand md:text-h1">Bagaimana Cara Menghubungi Kami?</h2>
          <p className="mt-8 max-w-[539px]">Kami di sini untuk membantu Anda dengan segala pertanyaan atau kebutuhan terkait aplikasi IkanKu. Jangan ragu untuk menghubungi kami melalui salah satu cara di bawah ini.</p>
          <ul className="mt-8 space-y-6">
            {[contacts[2], contacts[0], contacts[1]].map((c) => (
              <li key={c.label} className="flex items-start gap-4">
                <IconChip name={c.icon} size={44} />
                <div><p className="font-bold text-brand">{c.label}</p><p className="mt-1">{c.href ? <a href={c.href} className="hover:text-brand">{c.val}</a> : c.val}</p></div>
              </li>
            ))}
          </ul>
        </div>
        <ContactForm />
      </section>

      <section className="container-page section-y">
        <div className="rounded-3xl bg-brand surface-brand p-3 shadow-[0_24px_48px_-24px_rgba(23,123,205,.6)] md:p-7">
          <Image src="/img/hubungi/map.png" alt="Peta lokasi IkanKu" width={1218} height={340} className="h-[240px] w-full rounded-lg object-cover md:h-[340px]" />
        </div>
      </section>

      <section className="container-page section-y text-center">
        <h2 className="section-title text-brand">Satu Klik<br />Berhubung Dengan Kami</h2>
        <div className="mt-14 flex flex-wrap justify-center gap-8 lg:gap-[100px]">
          {contacts.map((c) => (
            <div key={c.label} className="card-lift flex size-[236px] flex-col items-center justify-center gap-4 rounded-3xl bg-brand surface-brand p-4 text-center text-white shadow-[0_24px_48px_-24px_rgba(23,123,205,.6)]">
              <IconChip name={c.icon} tone="glass" size={52} />
              <p>{c.label}</p>
              <p className="text-sm">{c.href ? <a href={c.href} className="underline-offset-2 hover:underline">{c.val}</a> : c.val}</p>
            </div>
          ))}
        </div>
      </section>
    </SiteShell>
  );
}
