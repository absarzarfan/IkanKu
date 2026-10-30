import type { ReactNode } from "react";

// One inline-SVG icon set: 24px grid, 1.75 stroke, round caps/joins, currentColor. No icon package.
const paths = {
  fish: <><path d="M2 12s3.5-6 10-6c3.2 0 5.6 1.3 7.5 3.3L22 7.5v9l-2.5-1.8C17.6 16.7 15.2 18 12 18 5.5 18 2 12 2 12z" /><path d="M8 11.5h.01" /></>,
  cart: <><path d="M3 4h2.2l2 10.2a1.5 1.5 0 0 0 1.5 1.2h8.2a1.5 1.5 0 0 0 1.5-1.1L20 8H6" /><circle cx="9.5" cy="19.5" r="1" /><circle cx="17" cy="19.5" r="1" /></>,
  truck: <><path d="M2 6.5h11V16H2z" /><path d="M13 9.5h4.2l3.3 3.5V16H13z" /><circle cx="6.5" cy="17.5" r="1.8" /><circle cx="17" cy="17.5" r="1.8" /></>,
  star: <path d="M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1 5.9L12 16.9l-5.2 2.8 1-5.9L3.5 9.7l5.9-.8z" />,
  tag: <><path d="M3 12.2V4.5A1.5 1.5 0 0 1 4.5 3h7.7l8.3 8.3a1.5 1.5 0 0 1 0 2.1l-7.1 7.1a1.5 1.5 0 0 1-2.1 0z" /><path d="M7.5 7.5h.01" /></>,
  shield: <><path d="M12 3l7.5 3v5.5c0 4.5-3.2 8-7.5 9.5-4.3-1.5-7.5-5-7.5-9.5V6z" /><path d="M8.5 12l2.5 2.5 4.5-5" /></>,
  layers: <><path d="M12 3l9 4.5-9 4.5-9-4.5z" /><path d="M3 12l9 4.5 9-4.5" /><path d="M3 16.5l9 4.5 9-4.5" /></>,
  smile: <><circle cx="12" cy="12" r="9" /><path d="M8.5 14.5c.8 1.2 2 1.8 3.5 1.8s2.7-.6 3.5-1.8" /><path d="M9 9.5h.01M15 9.5h.01" /></>,
  card: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><path d="M3 10h18M7 15h3" /></>,
  phone: <path d="M5 4h3.5l1.8 4.5-2.2 1.4a11 11 0 0 0 5 5l1.4-2.2L19 14.5V18a2 2 0 0 1-2 2A13 13 0 0 1 3 6a2 2 0 0 1 2-2z" />,
  mail: <><rect x="3" y="5" width="18" height="14" rx="2.5" /><path d="M3.5 7.5l8.5 6 8.5-6" /></>,
  pin: <><path d="M12 21s7-6.2 7-11.5a7 7 0 1 0-14 0C5 14.8 12 21 12 21z" /><circle cx="12" cy="9.5" r="2.5" /></>,
  home: <><path d="M3.5 11L12 4l8.5 7" /><path d="M5.5 9.5V20h13V9.5" /><path d="M10 20v-5.5h4V20" /></>,
  printer: <><path d="M7 9V4h10v5" /><path d="M7 17H5a2 2 0 0 1-2-2v-4a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2h-2" /><path d="M7 14h10v6H7z" /></>,
  eye: <><path d="M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12z" /><circle cx="12" cy="12" r="3" /></>,
  flag: <path d="M5 21V4M5 4h11l-2 4 2 4H5" />,
  target: <><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="5" /><circle cx="12" cy="12" r="1" /></>,
  phoneApp: <><rect x="7" y="2.5" width="10" height="19" rx="2.5" /><path d="M11 18.5h2" /></>,
  quote: <><path d="M9 7H6a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h2.5c0 2-1 3-3 3.5" /><path d="M19 7h-3a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h2.5c0 2-1 3-3 3.5" /></>,
  chevronLeft: <path d="M14.5 5.5L8 12l6.5 6.5" />,
  chevronRight: <path d="M9.5 5.5L16 12l-6.5 6.5" />,
  chevronDown: <path d="M5.5 9.5L12 16l6.5-6.5" />,
  menu: <path d="M4 7h16M4 12h16M4 17h16" />,
  close: <path d="M6 6l12 12M18 6L6 18" />,
} satisfies Record<string, ReactNode>;

export type IconName = keyof typeof paths;

export function Icon({ name, size = 24, className = "", label }: { name: IconName; size?: number; className?: string; label?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.75} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden={label ? undefined : true} aria-label={label} role={label ? "img" : undefined}>
      {paths[name]}
    </svg>
  );
}

/** Rounded-square icon chip. "tint" for white/light surfaces, "glass" for blue gradient surfaces. */
export function IconChip({ name, tone = "tint", size = 48, className = "" }: { name: IconName; tone?: "tint" | "glass"; size?: 44 | 48 | 52; className?: string }) {
  return (
    <span className={`icon-chip icon-chip-${tone} ${className}`} style={{ width: size, height: size }} aria-hidden="true">
      <Icon name={name} size={Math.round(size * 0.5)} />
    </span>
  );
}
