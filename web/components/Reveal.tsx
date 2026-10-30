"use client";
import { useEffect, useRef, type ReactNode } from "react";

/** Fade/rise-in on scroll using IntersectionObserver (no animation library). `delay` staggers siblings (ms). */
export default function Reveal({
  children,
  className = "",
  delay = 0,
}: {
  children: ReactNode;
  className?: string;
  delay?: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) {
          el.classList.add("is-visible");
          io.disconnect();
        }
      },
      { threshold: 0.1 },
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return (
    <div ref={ref} className={`reveal ${className}`} style={delay ? ({ "--d": `${delay}ms` } as React.CSSProperties) : undefined}>
      {children}
    </div>
  );
}
