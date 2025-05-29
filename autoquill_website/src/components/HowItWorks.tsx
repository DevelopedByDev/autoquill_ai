'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { Keyboard, Mic, ClipboardCheck, Sparkles } from 'lucide-react'

export default function HowItWorks() {
  const handleDownload = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai/releases', '_blank')
  }

  const steps = [
    {
      icon: <Keyboard className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "01",
      title: "Press Hotkey",
      description: "Hit your shortcut from anywhere on macOS"
    },
    {
      icon: <Mic className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "02", 
      title: "Speak Naturally",
      description: "Talk normally - AI handles the rest"
    },
    {
      icon: <ClipboardCheck className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "03",
      title: "Perfect Text",
      description: "Instant transcription to your clipboard"
    }
  ]

  return (
    <section className="py-24 bg-slate-900 relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-1/3 -left-20 w-96 h-96 bg-gradient-to-r from-primary-500/20 to-accent-500/20 rounded-full blur-3xl"
          animate={{ x: [0, 80, 0], y: [0, -40, 0] }}
          transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div 
          className="absolute bottom-1/3 -right-20 w-80 h-80 bg-gradient-to-r from-accent-500/20 to-coral/20 rounded-full blur-3xl"
          animate={{ x: [0, -60, 0], y: [0, 30, 0] }}
          transition={{ duration: 15, repeat: Infinity, ease: "easeInOut" }}
        />
      </div>

      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6 bg-gradient-to-r from-white via-primary-300 to-accent-300 bg-clip-text text-transparent">
            How It Works
          </h2>
          <p className="text-xl text-slate-300 max-w-2xl mx-auto font-medium leading-relaxed">
            Three simple steps to transform your voice into perfect text.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="grid md:grid-cols-3 gap-8 relative">
          {/* Connection lines */}
          <div className="hidden md:block absolute top-20 left-1/6 right-1/6 h-0.5 bg-gradient-to-r from-primary-400 via-accent-400 to-coral z-0"></div>

          {steps.map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: index * 0.2 }}
              className="relative z-10"
            >
              <motion.div 
                className="bg-slate-800/80 backdrop-blur-md rounded-3xl p-8 text-center shadow-medium hover:shadow-large transition-all duration-300 border border-slate-700/50 hover:border-primary-400/50 group"
                whileHover={{ y: -5 }}
              >
                {/* Step number */}
                <div className="absolute -top-6 left-1/2 transform -translate-x-1/2">
                  <div className="w-14 h-14 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-premium">
                    {step.number}
                  </div>
                </div>

                {/* Icon */}
                <motion.div
                  whileHover={{ scale: 1.05 }}
                  className="w-20 h-20 bg-gradient-to-r from-slate-600 to-slate-700 rounded-3xl flex items-center justify-center mx-auto mb-6 mt-6 group-hover:from-primary-500 group-hover:to-accent-500 transition-all duration-300"
                >
                  {step.icon}
                </motion.div>

                {/* Content */}
                <h3 className="text-2xl font-bold text-white mb-4">
                  {step.title}
                </h3>
                <p className="text-slate-300 leading-relaxed font-medium">
                  {step.description}
                </p>
              </motion.div>
            </motion.div>
          ))}
        </div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center mt-16"
        >
          <p className="text-xl text-slate-300 mb-8 font-medium">
            Ready to experience the future of text input?
          </p>
          <motion.button
            onClick={handleDownload}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="bg-gradient-to-r from-primary-500 to-accent-500 text-white px-10 py-5 rounded-2xl font-bold text-lg shadow-premium hover:shadow-glow transition-all duration-300 group"
          >
            <span className="flex items-center gap-2">
              Download AutoQuill AI
              <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
            </span>
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
} 