import type { Metadata } from "next";
import { montserrat, poppins } from "@/lib/fonts";
import "../globals.css";

// Admin pages stay Indonesian and unprefixed: this is their own root layout (lang="id").
export const metadata: Metadata = {
  title: "IkanKu - Belanja Ikan Mudah",
  description: "IkanKu: temukan ikan air tawar segar langsung dari petani dengan harga terbaik.",
};

export default function AdminRootLayout({ children }: LayoutProps<"/admin">) {
  return (
    <html lang="id" className={`${poppins.variable} ${montserrat.variable}`}>
      <body className="min-h-screen flex flex-col overflow-x-hidden">{children}</body>
    </html>
  );
}
