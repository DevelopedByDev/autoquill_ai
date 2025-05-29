'use client'

import { motion } from 'framer-motion'
import { Mic, Download, Github } from 'lucide-react'

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 to-white overflow-hidden">
      {/* Subtle background decoration */}
      <div className="absolute inset-0 opacity-20">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-coral/20 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/3 right-1/3 w-80 h-80 bg-slate-300/30 rounded-full blur-3xl"></div>
      </div>

      <div className="relative z-10 max-w-5xl mx-auto px-6 text-center">
        {/* Floating mic icon */}
        <div className="mb-8 flex justify-center">
          <div className="relative">
            <div className="w-24 h-24 bg-gradient-to-r from-coral to-red-500 rounded-3xl shadow-2xl flex items-center justify-center">
              <Mic className="w-12 h-12 text-white" strokeWidth={2.5} />
            </div>
            <div className="absolute inset-0 border-2 border-coral rounded-3xl"></div>
            <div className="absolute inset-0 border border-coral rounded-3xl"></div>
          </div>
        </div>

        {/* Main headline */}
        <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold text-slate-900 mb-6 leading-tight">
          Transform Your Voice<br/>
          Into <span className="bg-gradient-to-r from-coral to-red-500 bg-clip-text text-transparent">Perfect Text</span>
        </h1>

        {/* Subtitle */}
        <p className="text-xl md:text-2xl text-slate-700 mb-12 leading-relaxed max-w-4xl mx-auto font-medium">
          The most elegant voice-to-text app for macOS. Speak naturally, get perfect text instantly. 
          Free, open-source, and designed for professionals.
        </p>

        {/* CTA buttons */}
        <div className="flex flex-col sm:flex-row gap-6 justify-center items-center mb-16">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="bg-gradient-to-r from-coral to-red-500 text-white px-10 py-5 rounded-2xl text-lg font-bold shadow-xl hover:shadow-2xl transition-all duration-300 flex items-center gap-3 min-w-[240px]"
          >
            <Download className="w-6 h-6" strokeWidth={2.5} />
            Download for macOS
          </motion.button>
          
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="border-2 border-slate-400 text-slate-800 px-10 py-5 rounded-2xl text-lg font-bold hover:border-slate-500 hover:bg-slate-50 transition-all duration-300 flex items-center gap-3 min-w-[240px]"
          >
            <Github className="w-6 h-6" strokeWidth={2.5} />
            View Source Code
          </motion.button>
        </div>

        {/* Feature highlights */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-4xl mx-auto">
          <div className="text-center bg-white/50 backdrop-blur-sm rounded-2xl p-6 border border-slate-200/50">
            <div className="text-3xl font-black text-slate-900 mb-2">⚡ Instant</div>
            <div className="text-slate-700 font-medium">Real-time transcription</div>
          </div>
          <div className="text-center bg-white/50 backdrop-blur-sm rounded-2xl p-6 border border-slate-200/50">
            <div className="text-3xl font-black text-slate-900 mb-2">🎯 Accurate</div>
            <div className="text-slate-700 font-medium">AI-powered precision</div>
          </div>
          <div className="text-center bg-white/50 backdrop-blur-sm rounded-2xl p-6 border border-slate-200/50">
            <div className="text-3xl font-black text-slate-900 mb-2">🔒 Private</div>
            <div className="text-slate-700 font-medium">Your data stays local</div>
          </div>
        </div>

        {/* System requirements */}
        <div className="mt-16 text-slate-600 text-lg font-medium">
          <p>Requires macOS Monterey or later • Always free • No account required</p>
        </div>
      </div>
    </section>
  )
} 