import type { ReactNode } from "react";
import Navbar from "./Navbar";
import Footer from "./Footer";

export default function SiteShell({ children, footerContact = true }: { children: ReactNode; footerContact?: boolean }) {
  return (
    <>
      <Navbar />
      <main className="flex-1">{children}</main>
      <Footer showContact={footerContact} />
    </>
  );
}
