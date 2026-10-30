import type { ReactNode } from "react";

/** Shared section heading: title with the gradient bar, optional intro line. Colors follow the parent band. */
export default function SectionHeader({ title, intro, tone = "light" }: { title: ReactNode; intro?: ReactNode; tone?: "light" | "dark" }) {
  return (
    <header className="mx-auto max-w-[760px] text-center">
      <h2 className={`section-title ${tone === "light" ? "text-brand" : "text-white"}`}>{title}</h2>
      {intro && <p className={`mx-auto mt-6 ${tone === "light" ? "text-black/70" : "text-white/90"}`}>{intro}</p>}
    </header>
  );
}
