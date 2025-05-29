'use client'

import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Download, Check, Star, Users, Globe, Github } from 'lucide-react'

export default function DownloadSection() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  const features = [
    "Real-time voice transcription",
    "Smart clipboard integration", 
    "Custom keyboard shortcuts",
    "AI-powered corrections",
    "Complete privacy protection",
    "Open source & transparent"
  ]

  const stats = [
    { icon: <Users className="w-5 h-5" />, value: "10K+", label: "Active Users" },
    { icon: <Star className="w-5 h-5" />, value: "4.8", label: "App Store Rating" },
    { icon: <Globe className="w-5 h-5" />, value: "50+", label: "Languages" },
    { icon: <Github className="w-5 h-5" />, value: "2K+", label: "GitHub Stars" }
  ]

  return (
    <section ref={ref} className="py-24 bg-slate-50">
      <div className="max-w-4xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-slate-900 mb-6">
            Start Speaking, Start Creating
          </h2>
          <p className="text-xl text-slate-600 max-w-2xl mx-auto">
            Download AutoQuill AI today and transform the way you work with text. 
            Free forever, no strings attached.
          </p>
        </motion.div>

        {/* Main download card */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="bg-white rounded-3xl p-12 shadow-large border border-slate-100 mb-12"
        >
          <div className="grid md:grid-cols-2 gap-12 items-center">
            {/* Left side - Features */}
            <div>
              <h3 className="text-2xl font-bold text-slate-900 mb-6">
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
                    <div className="w-6 h-6 bg-coral rounded-full flex items-center justify-center flex-shrink-0">
                      <Check className="w-4 h-4 text-white" />
                    </div>
                    <span className="text-slate-700">{feature}</span>
                  </motion.li>
                ))}
              </ul>
              
              <div className="text-sm text-slate-500">
                <p>✓ Always free • ✓ No account required • ✓ Open source</p>
              </div>
            </div>

            {/* Right side - Download */}
            <div className="text-center">
              <div className="mb-8">
                <div className="text-5xl font-bold text-slate-900 mb-2">Free</div>
                <div className="text-slate-600">Forever & Always</div>
              </div>

              <motion.button
                whileHover={{ scale: 1.02, boxShadow: "0 20px 40px -8px rgba(245, 80, 54, 0.3)" }}
                whileTap={{ scale: 0.98 }}
                className="w-full bg-gradient-coral text-white py-4 px-8 rounded-xl text-lg font-semibold shadow-coral hover:shadow-lg transition-all duration-300 mb-6 flex items-center justify-center gap-3"
              >
                <Download className="w-6 h-6" />
                Download for macOS
              </motion.button>

              <div className="text-sm text-slate-500 mb-6">
                <p>Version 2.1.0 • 15 MB • Intel & Apple Silicon</p>
                <p>Requires macOS Monterey 12.0 or later</p>
              </div>

              <motion.a
                href="#"
                whileHover={{ scale: 1.02 }}
                className="inline-flex items-center gap-2 text-slate-600 hover:text-coral transition-colors duration-300"
              >
                <Github className="w-5 h-5" />
                View source code
              </motion.a>
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
            <div key={index} className="bg-white rounded-2xl p-6 text-center shadow-soft">
              <div className="flex items-center justify-center gap-2 text-coral mb-2">
                {stat.icon}
                <span className="text-2xl font-bold">{stat.value}</span>
              </div>
              <div className="text-sm text-slate-600">{stat.label}</div>
            </div>
          ))}
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center bg-white rounded-2xl p-8 shadow-soft"
        >
          <h3 className="text-2xl font-bold text-slate-900 mb-4">
            Ready to Experience the Future?
          </h3>
          <p className="text-lg text-slate-600 mb-6 max-w-2xl mx-auto">
            Join thousands of professionals who've already discovered the power of voice-first productivity. 
            Your workflow will never be the same.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="bg-gradient-coral text-white px-8 py-4 rounded-xl font-semibold shadow-coral transition-all duration-300"
            >
              Download Now
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="border-2 border-slate-300 text-slate-700 px-8 py-4 rounded-xl font-semibold hover:border-slate-400 hover:bg-slate-50 transition-all duration-300"
            >
              Watch Demo
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  )
} 