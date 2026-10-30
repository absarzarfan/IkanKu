import { IconChip } from "@/components/icons";
import { AI_LABEL, ARTICLE_AUTHOR, SHOW_AI_LABEL, readingMinutes, type Article } from "@/lib/articles";
import { articleUi } from "@/data/article-ui";

export function AiLabel({ a }: { a: Article }) {
  if (!SHOW_AI_LABEL || !a.aiGenerated) return null;
  return <span className="inline-flex items-center rounded-full border border-current px-2.5 py-0.5 text-xs">{AI_LABEL}</span>;
}

/** Author, date and reading time. `tone="dark"` is for text on photos / blue bands. */
export function Byline({ a, tone = "light", chip = true }: { a: Article; tone?: "light" | "dark"; chip?: boolean }) {
  return (
    <div className="flex items-center gap-3">
      {chip && <IconChip name="fish" tone={tone === "dark" ? "glass" : "tint"} size={44} />}
      <div className="min-w-0 text-sm">
        <p className="font-semibold">{ARTICLE_AUTHOR}</p>
        <p>{a.date} &middot; {readingMinutes(a)} {articleUi.minutesRead}</p>
      </div>
    </div>
  );
}

export function Kicker({ a, tone = "light" }: { a: Article; tone?: "light" | "dark" }) {
  return <p className={`kit-eyebrow !mb-1 ${tone === "dark" ? "text-white" : "text-brand"}`}>{a.kicker ?? a.category}</p>;
}
