import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import SiteShell from "@/components/SiteShell";
import ContactForm from "@/components/ContactForm";
import Faq from "@/components/Faq";

export const metadata: Metadata = { title: "Hubungi Kami - IkanKu" };

const contacts = [
  { icon: "ic-wa.svg", label: "Telepon", val: "(021) 123-4567", card: "phone.svg" },
  { icon: "ic-mail.svg", label: "Email", val: "support@ikansegar.com", card: "mail.svg" },
  { icon: "ic-pin.svg", label: "Lokasi", val: "Jl. Ikan Segar No. 123, Kota Nelayan, Provinsi Bahari", card: "pin.svg" },
];

export default function HubungiKamiPage() {
  return (
    <SiteShell>
      <section className="relative isolate overflow-hidden">
        <Image src="/img/hubungi/hero.png" alt="" fill priority sizes="100vw" className="-z-10 object-cover" />
        <div className="absolute inset-0 -z-10 bg-gradient-to-b from-transparent from-50% to-brand" />
        <div className="mx-auto flex min-h-[320px] max-w-[1440px] flex-col items-center justify-end px-6 pb-14 text-white lg:min-h-[600px] lg:pb-[130px]">
          <h1 className="text-4xl font-bold lg:text-5xl">Hubungi Kami</h1>
          <p className="mt-4 flex items-center gap-2 text-base font-bold">
            <Image src="/img/hubungi/home.svg" alt="" width={20} height={22} />
            <Link href="/" className="underline">Beranda</Link> <span>- Hubungi Kami</span>
          </p>
        </div>
      </section>

      <Faq />

      <section className="mx-auto grid max-w-[1284px] gap-10 px-6 py-8 lg:grid-cols-2 lg:gap-[80px] lg:px-[78px]">
        <div>
          <h2 className="text-3xl font-bold leading-[1.2] tracking-tight text-brand md:text-5xl">Bagaimana Cara Menghubungi Kami?</h2>
          <p className="mt-8 max-w-[539px]">Kami disini untuk membantu anda dengan segala pertanyaan atau kebutuhan terkait apliaksi IkanKu Ini. Jangan ragu untuk menghubungi kami melalui salah satu cara dibawah ini.</p>
          <ul className="mt-8 space-y-6">
            {[
              { t: "Lokasi", v: contacts[2].val, i: "ic-pin.svg" },
              { t: "Telepon", v: contacts[0].val, i: "ic-wa.svg" },
              { t: "Email", v: contacts[1].val, i: "ic-mail.svg" },
            ].map((c) => (
              <li key={c.t} className="flex gap-4">
                <Image src={`/img/hubungi/${c.i}`} alt="" width={22} height={22} className="mt-1 h-[22px] w-[22px] shrink-0" />
                <div><p className="font-bold text-brand">{c.t}</p><p className="mt-3">{c.v}</p></div>
              </li>
            ))}
          </ul>
        </div>
        <ContactForm />
      </section>

      <section className="mx-auto max-w-[1278px] px-6 py-8">
        <div className="rounded-lg bg-brand p-3 md:p-7">
          <Image src="/img/hubungi/map.png" alt="Peta lokasi IkanKu" width={1218} height={340} className="h-[240px] w-full rounded-lg object-cover md:h-[340px]" />
        </div>
      </section>

      <section className="mx-auto max-w-[1440px] px-6 py-16 text-center">
        <h2 className="text-3xl font-bold leading-[1.2] tracking-tight text-brand md:text-5xl">Satu Klik<br />Berhubung Dengan Kami</h2>
        <div className="mt-14 flex flex-wrap justify-center gap-8 lg:gap-[100px]">
          {contacts.map((c) => (
            <div key={c.label} className="flex size-[236px] flex-col items-center justify-center gap-4 bg-brand p-4 text-white">
              <Image src={`/img/hubungi/${c.card}`} alt="" width={40} height={40} className="h-10 w-10" />
              <p>{c.label}</p>
              <p className="text-sm">{c.val}</p>
            </div>
          ))}
        </div>
      </section>
    </SiteShell>
  );
}
