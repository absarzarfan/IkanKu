import type { ReactNode } from "react";
import Navbar from "./Navbar";
import Footer from "./Footer";

export default function SiteShell({ children, footerContact = true }: { children: ReactNode; footerContact?: boolean }) {
  return (
    <>
      <a href="#main" className="skip-link">Lewati ke konten utama</a>
      <Navbar />
      <main id="main" tabIndex={-1} className="flex-1 outline-none">{children}</main>
      <Footer showContact={footerContact} />
    </>
  );
}
