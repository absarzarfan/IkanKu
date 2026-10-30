"use client";
import Image from "next/image";
import { useRef, useState, type KeyboardEvent } from "react";
import { Icon, IconChip } from "@/components/icons";
import { visiMisiTabs, visiMisiUi } from "@/data/visi-misi";

// Accessible tablist: roving tabindex, arrow/Home/End keys, underline moves with transform.
export default function VisiMisi() {
  const [i, setI] = useState(0);
  const refs = useRef<(HTMLButtonElement | null)[]>([]);
  const n = visiMisiTabs.length;

  const go = (next: number) => { setI(next); refs.current[next]?.focus(); };
  const onKey = (e: KeyboardEvent) => {
    if (e.key === "ArrowRight") { e.preventDefault(); go((i + 1) % n); }
    else if (e.key === "ArrowLeft") { e.preventDefault(); go((i + n - 1) % n); }
    else if (e.key === "Home") { e.preventDefault(); go(0); }
    else if (e.key === "End") { e.preventDefault(); go(n - 1); }
  };
  const tab = visiMisiTabs[i];

  return (
    <section className="container-page flex flex-col items-center gap-10 pb-16 md:flex-row md:items-start md:justify-center">
      <div className="relative h-[320px] w-[234px] shrink-0 overflow-hidden rounded-t-3xl">
        <Image src="/img/home/phone.png" alt="Aplikasi IkanKu" fill sizes="234px" className="object-cover object-top" />
      </div>
      <div className="w-full min-w-0 md:max-w-[720px]">
        <p className="text-4xl font-bold text-brand md:text-h1 md:leading-[52px]">{visiMisiUi.heading}</p>
        <div className="relative mt-6 border-b border-black/15">
          <div role="tablist" aria-label={visiMisiUi.tablistLabel} onKeyDown={onKey} className="grid grid-cols-3">
            {visiMisiTabs.map((t, k) => (
              <button
                key={t.key}
                ref={(el) => { refs.current[k] = el; }}
                id={`vm-tab-${k}`}
                type="button"
                role="tab"
                aria-selected={i === k}
                aria-controls={`vm-panel-${k}`}
                tabIndex={i === k ? 0 : -1}
                onClick={() => setI(k)}
                className={`vm-tab inline-flex min-h-12 cursor-pointer items-center justify-center gap-2 px-2 text-sm font-semibold ${i === k ? "text-brand" : "text-muted"}`}
              >
                <Icon name={t.icon} size={18} />{t.key}
              </button>
            ))}
          </div>
          <span aria-hidden="true" className="vm-underline" style={{ transform: `translateX(${i * 100}%)` }} />
        </div>
        {visiMisiTabs.map((t, k) => (
          <div key={t.key} id={`vm-panel-${k}`} role="tabpanel" aria-labelledby={`vm-tab-${k}`} hidden={i !== k} tabIndex={0} className="vm-panel pt-8 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-brand">
            {i === k && (
              <>
                <p className="max-w-[60ch] text-xl font-semibold leading-snug text-heading md:text-2xl">{tab.lead}</p>
                <ul className="mt-8 grid gap-4 sm:grid-cols-2">
                  {tab.items.map((it, m) => (
                    <li key={it.title} className="card relative flex items-start gap-4 p-5">
                      <IconChip name={it.icon} size={44} />
                      <div className="min-w-0">
                        <p className="font-semibold text-heading">{it.title}</p>
                        <p className="mt-1 text-sm text-body">{it.text}</p>
                      </div>
                      <span className="absolute right-4 top-4 rounded-full bg-brand/10 px-2 py-0.5 text-xs font-semibold text-brand">{String(m + 1).padStart(2, "0")}</span>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </div>
        ))}
      </div>
    </section>
  );
}
