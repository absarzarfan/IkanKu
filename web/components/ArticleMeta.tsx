import { IconChip } from "@/components/icons";

/** Label such as "Written with AI assistance" / "Translated from Indonesian" (text decided by the server). */
export function AiLabel({ text }: { text?: string | null }) {
  if (!text) return null;
  return <span className="inline-flex items-center rounded-full border border-current px-2.5 py-0.5 text-xs">{text}</span>;
}

/** Author, date and reading time as one prepared line. `tone="dark"` is for text on photos / blue bands. */
export function Byline({ author, meta, tone = "light", chip = true }: { author: string; meta: string; tone?: "light" | "dark"; chip?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      {chip && <IconChip name="fish" tone={tone === "dark" ? "glass" : "tint"} size={44} />}
      <div className="min-w-0 text-sm">
        <p className="font-semibold">{author}</p>
        <p>{meta}</p>
      </div>
    </div>
  );
}

export function Kicker({ text, tone = "light" }: { text: string; tone?: "light" | "dark" }) {
  return <p className={`kit-eyebrow !mb-1 ${tone === "dark" ? "text-white" : "text-brand"}`}>{text}</p>;
}
