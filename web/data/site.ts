// Download link and QR image, one source for every "Unduh Aplikasi" / "Download on Google Play" button.
// NEEDS CONFIRMATION: DOWNLOAD_URL is empty on purpose (no real store URL is known). Buttons fall back to "#".
export const DOWNLOAD_URL = "";
export const downloadHref = DOWNLOAD_URL || "#";
// UNKNOWN origin: verify by scanning with a phone before publishing.
export const QR_IMAGE = "/img/produk/qr.png";
