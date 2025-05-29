'use client'

import React from 'react'
import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Download, Check, Star, Users, Globe, Github, Sparkles } from 'lucide-react'

export default function DownloadSection() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  const handleDownload = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai/releases', '_blank')
  }

  const handleViewSource = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai', '_blank')
  }

  const features = [
    "Real-time voice transcription",
    "Smart clipboard integration", 
    "Custom keyboard shortcuts",
    "AI-powered corrections",
    "Complete privacy protection"
  ]

  const stats = [
    { icon: <Users className="w-5 h-5" />, value: "10K+", label: "Users" },
    { icon: <Star className="w-5 h-5" />, value: "4.8", label: "Rating" },
    { icon: <Globe className="w-5 h-5" />, value: "50+", label: "Languages" },
    { icon: <Github className="w-5 h-5" />, value: "Open", label: "Source" }
  ]

  return (
    <section ref={ref} className="py-24 bg-slate-800 relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-r from-primary-500/20 to-accent-500/20 rounded-full blur-3xl"
          animate={{ x: [0, 50, 0], y: [0, -30, 0] }}
          transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div 
          className="absolute bottom-0 right-1/4 w-80 h-80 bg-gradient-to-r from-accent-500/20 to-coral/20 rounded-full blur-3xl"
          animate={{ x: [0, -40, 0], y: [0, 20, 0] }}
          transition={{ duration: 15, repeat: Infinity, ease: "easeInOut" }}
        />
      </div>

      <div className="max-w-5xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6 bg-gradient-to-r from-white via-primary-300 to-accent-300 bg-clip-text text-transparent">
            Ready to Transform Your Workflow?
          </h2>
          <p className="text-xl text-slate-300 max-w-2xl mx-auto">
            Join thousands using AutoQuill AI to work faster and more efficiently.
          </p>
        </motion.div>

        {/* Main download card */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="bg-slate-700/80 backdrop-blur-xl rounded-3xl p-8 md:p-12 shadow-premium border border-slate-600/50 mb-12"
        >
          <div className="grid md:grid-cols-2 gap-12 items-center">
            {/* Left side - Features */}
            <div>
              <h3 className="text-2xl font-bold text-white mb-6 flex items-center gap-3">
                <Sparkles className="w-6 h-6 text-primary-400" />
                What's Included
              </h3>
              <ul className="space-y-4 mb-8">
                {features.map((feature, index) => (
                  <motion.li
                    key={index}
                    initial={{ opacity: 0, x: -20 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 0.6, delay: 0.4 + index * 0.1 }}
                    className="flex items-center gap-3"
                  >
                    <div className="w-6 h-6 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center flex-shrink-0">
                      <Check className="w-4 h-4 text-white" strokeWidth={3} />
                    </div>
                    <span className="text-slate-300 font-medium">{feature}</span>
                  </motion.li>
                ))}
              </ul>
              
              <div className="text-sm text-slate-400 bg-gradient-to-r from-slate-800 to-slate-700 rounded-xl p-4 border border-slate-600">
                <p className="font-semibold text-primary-300">✓ Always free • ✓ No account required • ✓ Open source</p>
              </div>
            </div>

            {/* Right side - Download */}
            <div className="text-center">
              <div className="mb-8 p-6 bg-gradient-to-r from-slate-800 to-slate-700 rounded-2xl border border-slate-600">
                <div className="text-5xl font-bold bg-gradient-to-r from-primary-400 to-accent-400 bg-clip-text text-transparent mb-2">Free</div>
                <div className="text-slate-400 font-medium">Forever & Always</div>
              </div>

              <motion.button
                onClick={handleDownload}
                whileHover={{ scale: 1.02, boxShadow: "0 20px 40px -8px rgba(14, 165, 233, 0.3)" }}
                whileTap={{ scale: 0.98 }}
                className="w-full bg-gradient-to-r from-primary-500 to-accent-500 text-white py-4 px-8 rounded-xl text-lg font-bold shadow-premium hover:shadow-glow transition-all duration-300 mb-6 flex items-center justify-center gap-3 group"
              >
                <Download className="w-6 h-6 group-hover:scale-110 transition-transform" />
                Download for macOS
                <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
              </motion.button>

              <div className="text-sm text-slate-400 mb-6 space-y-1">
                <p className="font-semibold">Version 2.1.0 • 15 MB</p>
                <p>Intel & Apple Silicon • macOS Monterey+</p>
              </div>

              <motion.button
                onClick={handleViewSource}
                whileHover={{ scale: 1.02 }}
                className="inline-flex items-center gap-2 text-slate-300 hover:text-primary-400 transition-colors duration-300 font-medium group"
              >
                <Github className="w-5 h-5 group-hover:scale-110 transition-transform" />
                View source code on GitHub
              </motion.button>
            </div>
          </div>
        </motion.div>

        {/* Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-12"
        >
          {stats.map((stat, index) => (
            <motion.div 
              key={index} 
              className="bg-slate-700/80 backdrop-blur-md rounded-2xl p-6 text-center shadow-medium border border-slate-600/50 hover:bg-slate-700/95 transition-all duration-300 group"
              whileHover={{ y: -3 }}
            >
              <div className="flex items-center justify-center gap-2 text-primary-400 mb-2 group-hover:scale-110 transition-transform">
                {stat.icon}
                <span className="text-2xl font-bold">{stat.value}</span>
              </div>
              <div className="text-sm text-slate-400 font-medium">{stat.label}</div>
            </motion.div>
          ))}
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center bg-slate-700/80 backdrop-blur-xl rounded-2xl p-8 shadow-premium border border-slate-600/50"
        >
          <h3 className="text-2xl font-bold text-white mb-4">
            Experience the Future of Text Creation
          </h3>
          <p className="text-lg text-slate-300 mb-6 max-w-2xl mx-auto">
            Join the voice-first revolution. Your most productive workflow awaits.
          </p>
          <motion.button
            onClick={handleDownload}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="bg-gradient-to-r from-primary-500 to-accent-500 text-white px-8 py-4 rounded-xl font-bold shadow-premium transition-all duration-300 group"
          >
            <span className="flex items-center gap-2">
              Get Started Now
              <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
            </span>
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
} 