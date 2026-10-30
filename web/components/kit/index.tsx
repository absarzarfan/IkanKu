import Image from "next/image";
import type { ReactNode } from "react";
import { IconChip, type IconName } from "@/components/icons";

// Enrichment kit (Phase 9a): decorative, aria-hidden, no JS, fixed heights so nothing shifts.

/** Wave divider. `color` is the colour of the section BELOW the wave; place it at the top edge of that section. */
export function Wave({ color = "#fff", flip = false }: { color?: string; flip?: boolean }) {
  return (
    <div aria-hidden="true" className={`kit-wave ${flip ? "kit-wave-flip" : ""}`} style={{ color }}>
      <svg viewBox="0 0 1440 48" preserveAspectRatio="none" focusable="false">
        <path d="M0 26C180 4 360 4 540 22s360 24 540 4 270-14 360-6V48H0z" fill="currentColor" />
      </svg>
    </div>
  );
}

/** Low-opacity ripple/bubble shapes for blue bands (corners only, max opacity .12). */
export function Bubbles() {
  return (
    <svg aria-hidden="true" focusable="false" className="kit-bubbles" viewBox="0 0 1200 400" preserveAspectRatio="xMidYMid slice">
      <g fill="none" stroke="#fff" strokeWidth="2">
        <circle cx="70" cy="330" r="60" /><circle cx="70" cy="330" r="100" /><circle cx="70" cy="330" r="140" />
        <circle cx="1140" cy="60" r="50" /><circle cx="1140" cy="60" r="90" />
      </g>
      <g fill="#fff"><circle cx="190" cy="90" r="10" /><circle cx="240" cy="140" r="6" /><circle cx="1010" cy="330" r="12" /><circle cx="1070" cy="290" r="6" /></g>
    </svg>
  );
}

export function Eyebrow({ children, tone = "light" }: { children: ReactNode; tone?: "light" | "dark" }) {
  return <p className={`kit-eyebrow ${tone === "dark" ? "text-white" : "text-brand"}`}>{children}</p>;
}

export type Step = { title: string; text?: string; icon?: IconName };

/** Numbered vertical timeline for sequences (use only where the content is a real sequence). */
export function Timeline({ steps, tone = "light" }: { steps: Step[]; tone?: "light" | "dark" }) {
  return (
    <ol className={`kit-timeline ${tone === "dark" ? "kit-timeline-dark" : ""}`}>
      {steps.map((s, i) => (
        <li key={s.title}>
          <span className="kit-step-num" aria-hidden="true">{i + 1}</span>
          <div>
            <p className="font-semibold">{s.title}</p>
            {s.text && <p className="mt-1 text-sm">{s.text}</p>}
          </div>
        </li>
      ))}
    </ol>
  );
}

export type IconListItem = { icon: IconName; title: string; text?: string };

/** Icon-chip list: one chip per item, replaces plain bullet lists. */
export function IconList({ items, tone = "light" }: { items: IconListItem[]; tone?: "light" | "dark" }) {
  return (
    <ul className="grid gap-4">
      {items.map((it) => (
        <li key={it.title} className="flex items-start gap-4">
          <IconChip name={it.icon} tone={tone === "dark" ? "glass" : "tint"} size={44} />
          <div><p className="font-semibold">{it.title}</p>{it.text && <p className="mt-1 text-sm">{it.text}</p>}</div>
        </li>
      ))}
    </ul>
  );
}

/** Image frame: consistent radius; optional bottom gradient when text sits on the photo. */
export function Frame({ src, alt = "", ratio = "3/2", overlay = false, sizes = "(min-width:768px) 50vw, 100vw", priority = false, children, className = "" }: {
  src: string; alt?: string; ratio?: string; overlay?: boolean; sizes?: string; priority?: boolean; children?: ReactNode; className?: string;
}) {
  return (
    <div className={`kit-frame img-zoom ${className}`} style={{ aspectRatio: ratio }}>
      <Image src={src} alt={alt} fill sizes={sizes} priority={priority} className="object-cover" />
      {overlay && <div aria-hidden="true" className="kit-frame-shade" />}
      {children}
    </div>
  );
}
