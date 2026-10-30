"use client";
import { useState } from "react";
import { Icon, IconChip } from "@/components/icons";
import { Bubbles } from "@/components/kit";
import { faqCategoryOrder, faqs, faqUi, type FaqItem } from "@/data/faq";

// Two independent flex columns on md+, one list below md. Each item is one rounded card
// (button + panel share radius and width). Several items may be open at once.
const categories = faqCategoryOrder.filter((c) => faqs.some((f) => f.category === c));

function Item({ f, uid, open, onToggle }: { f: FaqItem; uid: string; open: boolean; onToggle: () => void }) {
  const btnId = `faq-btn-${uid}`;
  const panelId = `faq-panel-${uid}`;
  return (
    <li className="overflow-hidden rounded-2xl bg-white text-ink shadow-[0_8px_20px_-12px_rgba(5,3,21,.45)]">
      <h3>
        <button id={btnId} type="button" aria-expanded={open} aria-controls={panelId} onClick={onToggle} className="faq-btn flex min-h-[72px] w-full cursor-pointer items-center gap-4 px-5 py-3 text-left text-base font-semibold md:px-6">
          <IconChip name={f.icon} size={44} />
          <span className="min-w-0 flex-1">{f.question}</span>
          <Icon name="chevronDown" size={24} className={`shrink-0 text-brand transition-transform duration-200 ${open ? "rotate-180" : ""}`} />
        </button>
      </h3>
      <div id={panelId} role="region" aria-labelledby={btnId} data-open={open} inert={!open} className="faq-panel">
        <div>
          <div className="px-5 pb-6 pt-1 text-sm leading-relaxed text-body md:pl-[84px] md:pr-6">
            <p className="max-w-[62ch]">{f.answer}</p>
            {f.steps && (
              <ol className="mt-4 max-w-[62ch] list-decimal space-y-2 pl-5 marker:font-semibold marker:text-brand">
                {f.steps.map((s) => <li key={s}>{s}</li>)}
              </ol>
            )}
          </div>
        </div>
      </div>
    </li>
  );
}

export default function Faq() {
  const [open, setOpen] = useState<Set<string>>(() => new Set([faqs[0].id]));
  const [cat, setCat] = useState<string>(faqUi.all);
  const toggle = (id: string) => setOpen((s) => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n; });
  const list = cat === faqUi.all ? faqs : faqs.filter((f) => f.category === cat);
  const colA = list.filter((_, i) => i % 2 === 0);
  const colB = list.filter((_, i) => i % 2 === 1);
  const render = (items: FaqItem[], prefix: string) => items.map((f) => <Item key={f.id} f={f} uid={`${prefix}-${f.id}`} open={open.has(f.id)} onToggle={() => toggle(f.id)} />);

  return (
    <section id="faq" className="container-page section-y">
      <div className="band-blue relative overflow-hidden rounded-2xl px-6 py-12 shadow-[0_8px_8px_rgba(0,0,0,.25)] md:px-[64px] md:pb-[80px]">
        <Bubbles />
        <h2 className="text-3xl font-bold tracking-tight text-white md:text-h1 md:leading-[1.2]">{faqUi.title}</h2>
        <p className="mt-3 max-w-[60ch] text-white">{faqUi.intro}</p>
        <div role="group" aria-label={faqUi.filterLabel} className="mt-8 flex flex-wrap gap-2">
          {[faqUi.all, ...categories].map((c) => (
            <button key={c} type="button" aria-pressed={cat === c} onClick={() => setCat(c)} className="faq-chip">{c}</button>
          ))}
        </div>
        <ul className="mt-8 flex flex-col gap-4 md:hidden">{render(list, "m")}</ul>
        <div className="mt-8 hidden items-start gap-5 md:flex">
          <ul className="flex min-w-0 flex-1 flex-col gap-5">{render(colA, "a")}</ul>
          <ul className="flex min-w-0 flex-1 flex-col gap-5">{render(colB, "b")}</ul>
        </div>
      </div>
    </section>
  );
}
