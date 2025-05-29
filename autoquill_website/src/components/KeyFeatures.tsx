'use client'

import { motion } from 'framer-motion'
import { Zap, Clipboard, Settings, Keyboard, Shield, Code2 } from 'lucide-react'

export default function KeyFeatures() {
  const features = [
    {
      icon: <Zap className="w-10 h-10" strokeWidth={2.5} />,
      title: "Lightning Fast",
      description: "Real-time transcription with sub-second response times. Your thoughts become text instantly.",
      highlight: "< 500ms"
    },
    {
      icon: <Clipboard className="w-10 h-10" strokeWidth={2.5} />,
      title: "Smart Clipboard",
      description: "Automatically copies transcribed text to your clipboard. Paste anywhere, anytime.",
      highlight: "Auto-copy"
    },
    {
      icon: <Settings className="w-10 h-10" strokeWidth={2.5} />,
      title: "AI Assistant Mode",
      description: "Get smart completions, grammar corrections, and style suggestions powered by AI.",
      highlight: "AI-powered"
    },
    {
      icon: <Keyboard className="w-10 h-10" strokeWidth={2.5} />,
      title: "Custom Hotkeys",
      description: "Configure your own keyboard shortcuts. Work seamlessly across all applications.",
      highlight: "Customizable"
    },
    {
      icon: <Shield className="w-10 h-10" strokeWidth={2.5} />,
      title: "Privacy First",
      description: "All processing happens locally on your Mac. Your voice data never leaves your device.",
      highlight: "100% Private"
    },
    {
      icon: <Code2 className="w-10 h-10" strokeWidth={2.5} />,
      title: "Open Source",
      description: "Completely transparent and open source. Inspect, modify, and contribute to the code.",
      highlight: "MIT License"
    }
  ]

  return (
    <section className="py-24 bg-slate-900">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
            Everything You Need
          </h2>
          <p className="text-xl text-slate-300 max-w-3xl mx-auto font-medium leading-relaxed">
            A complete voice-to-text solution designed for professionals who value 
            speed, privacy, and reliability.
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              className="group"
            >
              <div className="bg-slate-800 rounded-3xl p-8 hover:shadow-xl transition-all duration-300 border-2 border-slate-700 hover:border-coral/30 h-full">
                {/* Icon and highlight */}
                <div className="flex items-start justify-between mb-6">
                  <div className="w-20 h-20 bg-gradient-to-r from-coral to-red-500 rounded-3xl flex items-center justify-center text-white shadow-lg group-hover:scale-105 transition-all duration-300">
                    {feature.icon}
                  </div>
                  <div className="bg-gradient-to-r from-coral/20 to-red-500/20 text-coral px-4 py-2 rounded-full text-sm font-bold border border-coral/30">
                    {feature.highlight}
                  </div>
                </div>

                {/* Content */}
                <h3 className="text-2xl font-bold text-white mb-4">
                  {feature.title}
                </h3>
                <p className="text-slate-300 leading-relaxed font-medium">
                  {feature.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Bottom section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-16 text-center bg-gradient-to-r from-coral to-red-500 rounded-3xl p-12 text-white relative overflow-hidden"
        >
          <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-black/10"></div>
          <div className="relative z-10">
            <h3 className="text-3xl md:text-4xl font-bold mb-6">
              Ready to Transform Your Workflow?
            </h3>
            <p className="text-xl text-white/95 mb-8 max-w-2xl mx-auto leading-relaxed font-medium">
              Join thousands of professionals who've already made the switch to voice-first productivity.
            </p>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="bg-white text-coral px-10 py-5 rounded-2xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all duration-300"
            >
              Download for Free
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  )
} 