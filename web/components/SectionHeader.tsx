import type { ReactNode } from "react";
import Reveal from "@/components/Reveal";

/** Shared section heading: title with the gradient bar, optional intro line. Colors follow the parent band. */
export default function SectionHeader({ title, intro, eyebrow, tone = "light" }: { title: ReactNode; eyebrow?: string; intro?: ReactNode; tone?: "light" | "dark" }) {
  return (
    <Reveal><header className="mx-auto max-w-[760px] text-center">
      {eyebrow && <p className={`kit-eyebrow ${tone === "light" ? "text-brand" : "text-white"}`}>{eyebrow}</p>}
      <h2 className={`section-title ${tone === "light" ? "text-brand" : "text-white"}`}>{title}</h2>
      {intro && <p className={`mx-auto mt-6 ${tone === "light" ? "text-body" : "text-white"}`}>{intro}</p>}
    </header></Reveal>
  );
}
