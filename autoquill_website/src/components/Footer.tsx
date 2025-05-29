'use client'

import { motion } from 'framer-motion'
import { Github, Twitter, Mail, ExternalLink } from 'lucide-react'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  const links = {
    product: [
      { name: 'Download', href: '#' },
      { name: 'Features', href: '#' },
      { name: 'How It Works', href: '#' },
      { name: 'Pricing', href: '#' }
    ],
    resources: [
      { name: 'Documentation', href: '#' },
      { name: 'API Reference', href: '#' },
      { name: 'GitHub', href: 'https://github.com', external: true },
      { name: 'Support', href: '#' }
    ],
    company: [
      { name: 'About', href: '#' },
      { name: 'Blog', href: '#' },
      { name: 'Privacy Policy', href: '#' },
      { name: 'Terms of Service', href: '#' }
    ]
  }

  const socialLinks = [
    { icon: <Github className="w-5 h-5" />, href: 'https://github.com', label: 'GitHub' },
    { icon: <Twitter className="w-5 h-5" />, href: 'https://twitter.com', label: 'Twitter' },
    { icon: <Mail className="w-5 h-5" />, href: 'mailto:hello@autoquill.ai', label: 'Email' }
  ]

  return (
    <footer className="bg-slate-900 text-white">
      <div className="max-w-6xl mx-auto px-6 py-16">
        {/* Main footer content */}
        <div className="grid md:grid-cols-4 gap-12 mb-12">
          {/* Brand section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="md:col-span-1"
          >
            <h3 className="text-2xl font-bold text-white mb-4">AutoQuill AI</h3>
            <p className="text-slate-400 mb-6 leading-relaxed">
              The most elegant voice-to-text app for macOS. Transform your voice into perfect text at the speed of thought.
            </p>
            <div className="flex items-center gap-4">
              {socialLinks.map((link, index) => (
                <motion.a
                  key={index}
                  href={link.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  whileHover={{ scale: 1.1, y: -2 }}
                  whileTap={{ scale: 0.9 }}
                  className="w-10 h-10 bg-slate-800 rounded-lg flex items-center justify-center text-slate-400 hover:text-white hover:bg-coral transition-all duration-300"
                  aria-label={link.label}
                >
                  {link.icon}
                </motion.a>
              ))}
            </div>
          </motion.div>

          {/* Navigation links */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
          >
            <h4 className="font-semibold text-white mb-6">Product</h4>
            <ul className="space-y-3">
              {links.product.map((link, index) => (
                <li key={index}>
                  <a
                    href={link.href}
                    className="text-slate-400 hover:text-white transition-colors duration-300 flex items-center gap-1"
                  >
                    {link.name}
                    {link.external && <ExternalLink className="w-3 h-3" />}
                  </a>
                </li>
              ))}
            </ul>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <h4 className="font-semibold text-white mb-6">Resources</h4>
            <ul className="space-y-3">
              {links.resources.map((link, index) => (
                <li key={index}>
                  <a
                    href={link.href}
                    target={link.external ? '_blank' : undefined}
                    rel={link.external ? 'noopener noreferrer' : undefined}
                    className="text-slate-400 hover:text-white transition-colors duration-300 flex items-center gap-1"
                  >
                    {link.name}
                    {link.external && <ExternalLink className="w-3 h-3" />}
                  </a>
                </li>
              ))}
            </ul>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
          >
            <h4 className="font-semibold text-white mb-6">Company</h4>
            <ul className="space-y-3">
              {links.company.map((link, index) => (
                <li key={index}>
                  <a
                    href={link.href}
                    className="text-slate-400 hover:text-white transition-colors duration-300 flex items-center gap-1"
                  >
                    {link.name}
                    {link.external && <ExternalLink className="w-3 h-3" />}
                  </a>
                </li>
              ))}
            </ul>
          </motion.div>
        </div>

        {/* Bottom section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="border-t border-slate-800 pt-8 flex flex-col md:flex-row justify-between items-center gap-6"
        >
          <div className="text-slate-400 text-sm">
            © {currentYear} AutoQuill AI. All rights reserved.
          </div>
          
          <div className="flex items-center gap-6 text-sm">
            <span className="text-slate-400">Made with ❤️ for productivity</span>
            <div className="flex items-center gap-4">
              <span className="bg-coral/10 text-coral px-3 py-1 rounded-full font-semibold">
                Open Source
              </span>
              <span className="bg-green-500/10 text-green-400 px-3 py-1 rounded-full font-semibold">
                Free Forever
              </span>
            </div>
          </div>
        </motion.div>

        {/* Tech attribution */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.5 }}
          className="mt-8 text-center text-slate-500 text-sm"
        >
          <p>
            Powered by{' '}
            <span className="text-coral font-semibold">Groq</span>
            {', '}
            <span className="text-blue-400 font-semibold">Whisper AI</span>
            {', and '}
            <span className="text-purple-400 font-semibold">advanced speech recognition</span>
          </p>
        </motion.div>
      </div>
    </footer>
  )
} 