import { Icon } from "@/components/icons";
import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import ContactForm from "@/components/ContactForm";
import Faq from "@/components/Faq";
import ContactInfo from "@/components/ContactInfo";
import { Eyebrow } from "@/components/kit";
import { contact } from "@/data/contact";

export const metadata: Metadata = { title: "Hubungi Kami - IkanKu" };

export default function HubungiKamiPage() {
  return (
    <SiteShell footerContact={false}>
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
        </div>
        <ContactForm />
      </section>

      <section className="container-page section-y">
        <div className="card overflow-hidden">
          <iframe src={contact.map.embedUrl} title="Peta lokasi Politeknik Negeri Batam" loading="lazy" referrerPolicy="no-referrer-when-downgrade" allowFullScreen width="100%" className="block h-[280px] w-full border-0 md:h-[clamp(280px,40vh,420px)]" />
        </div>
        <div className="mt-6 flex justify-center">
          <a href={contact.map.openUrl} target="_blank" rel="noopener noreferrer" className="btn-outline inline-flex min-h-11 items-center rounded-lg border border-black px-5 py-2 text-sm">Buka di Google Maps</a>
        </div>
      </section>

      <section className="tint-soft"><div className="container-page section-y text-center">
        <Eyebrow>Kontak</Eyebrow>
        <h2 className="section-title text-brand">Satu Klik<br />Berhubung Dengan Kami</h2>
        <p className="mx-auto mt-4 text-sm text-body">{contact.institution} - {contact.tagline}</p>
        <div className="mt-10 text-left"><ContactInfo items={["phone", "email", "fax", "address"]} variant="cards" /></div>
      </div></section>
    </SiteShell>
  );
}
