import { IconChip, type IconName } from "@/components/icons";
import { contact } from "@/data/contact";

export type ContactItem = "address" | "phone" | "fax" | "email";

// Single renderer for contact details; values come from data/contact.ts only.
const defs: Record<ContactItem, { icon: IconName; compact: string; card: string; value: string; href?: string; external?: boolean }> = {
  address: { icon: "pin", compact: "Alamat", card: "Lokasi", value: contact.address, href: contact.map.openUrl, external: true },
  phone: { icon: "phone", compact: "Nomor telepon", card: "Telepon", value: contact.phone, href: contact.phoneHref },
  fax: { icon: "printer", compact: "Fax", card: "Fax", value: contact.fax },
  email: { icon: "mail", compact: "Email", card: "Email", value: contact.email, href: contact.emailHref },
};

const ext = { target: "_blank", rel: "noopener noreferrer" } as const;

export default function ContactInfo({ items, variant }: { items: ContactItem[]; variant: "compact" | "cards" }) {
  if (variant === "cards") {
    return (
      <ul className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {items.map((k) => {
          const d = defs[k];
          return (
            <li key={k} className="card-lift flex min-h-[200px] flex-col items-center justify-center gap-3 rounded-3xl bg-brand surface-brand p-6 text-center text-white shadow-[0_24px_48px_-24px_rgba(22,114,196,.6)]">
              <IconChip name={d.icon} tone="glass" size={52} />
              <p className="font-semibold">{d.card}</p>
              <p className="break-words text-sm">
                {d.href ? <a href={d.href} {...(d.external ? ext : {})} className="underline-offset-2 hover:underline">{d.value}</a> : d.value}
              </p>
            </li>
          );
        })}
      </ul>
    );
  }
  return (
    <ul className="grid gap-x-10 gap-y-6 text-lg text-ink sm:grid-cols-2">
      {items.map((k) => {
        const d = defs[k];
        return (
          <li key={k} className={`flex items-start gap-4 ${k === "address" ? "sm:col-span-2" : ""}`}>
            <IconChip name={d.icon} size={44} />
            <div>
              <p>{d.compact}</p>
              {d.href ? <a href={d.href} {...(d.external ? ext : {})} className="footer-link mt-1 block break-words">{d.value}</a> : <p className="mt-1">{d.value}</p>}
            </div>
          </li>
        );
      })}
    </ul>
  );
}
