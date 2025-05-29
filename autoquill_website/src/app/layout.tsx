import type { Metadata, Viewport } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import "./globals.css";

export const metadata: Metadata = {
  title: "AutoQuill AI - Transform Your Voice Into Perfect Text",
  description: "The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly. Free, open-source, and designed for professionals.",
  keywords: ["voice to text", "speech recognition", "macOS app", "productivity", "AI transcription", "open source"],
  authors: [{ name: "AutoQuill AI Team" }],
  creator: "AutoQuill AI",
  publisher: "AutoQuill AI",
  metadataBase: new URL('https://autoquill.ai'),
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: '1024x1024', type: 'image/x-icon' },
      { url: '/autoquill-logo.png', sizes: '1024x1024', type: 'image/png' }
    ],
    shortcut: '/favicon.ico',
    apple: '/autoquill-logo.png'
  },
  openGraph: {
    title: "AutoQuill AI - Transform Your Voice Into Perfect Text",
    description: "The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly.",
    url: "https://autoquill.ai",
    siteName: "AutoQuill AI",
    images: [
      {
        url: "/autoquill-logo.png",
        width: 1024,
        height: 1024,
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
    images: ["/autoquill-logo.png"],
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
  themeColor: "#FFFFFF",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/autoquill-logo.png" type="image/png" />
        <link rel="apple-touch-icon" href="/autoquill-logo.png" />
      </head>
      <body className={`${GeistSans.className} antialiased bg-background text-foreground`}>
        {children}
      </body>
    </html>
  );
}
