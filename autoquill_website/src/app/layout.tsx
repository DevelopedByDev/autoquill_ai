import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ 
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "AutoQuill AI - Transform Your Voice Into Perfect Text",
  description: "The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly. Free, open-source, and designed for professionals.",
  keywords: ["voice to text", "speech recognition", "macOS app", "productivity", "AI transcription", "open source"],
  authors: [{ name: "AutoQuill AI Team" }],
  creator: "AutoQuill AI",
  publisher: "AutoQuill AI",
  metadataBase: new URL('https://autoquill.ai'),
  openGraph: {
    title: "AutoQuill AI - Transform Your Voice Into Perfect Text",
    description: "The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly.",
    url: "https://autoquill.ai",
    siteName: "AutoQuill AI",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "AutoQuill AI - Voice to Text for macOS",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "AutoQuill AI - Transform Your Voice Into Perfect Text",
    description: "The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly.",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#0f172a",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={`${inter.className} antialiased bg-slate-900 text-white`}>
        {children}
      </body>
    </html>
  );
}
