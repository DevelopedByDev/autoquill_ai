'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { Mic, Download, Github, Sparkles, Zap } from 'lucide-react'

export default function HeroSection() {
  const handleDownload = () => {
    // For now, this would link to the actual download URL when available
    // Replace with actual download link from the autoquill_ai project
    window.open('https://github.com/DevelopedByDev/autoquill_ai/releases', '_blank')
  }

  const handleViewSource = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai', '_blank')
  }

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-slate-900">
      {/* Animated gradient background */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 opacity-95"></div>
      
      {/* Floating orbs */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-1/4 -left-20 w-96 h-96 bg-gradient-to-r from-primary-500/30 to-accent-500/30 rounded-full blur-3xl"
          animate={{ x: [0, 100, 0], y: [0, -50, 0] }}
          transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div 
          className="absolute bottom-1/3 -right-20 w-80 h-80 bg-gradient-to-r from-accent-500/30 to-coral/30 rounded-full blur-3xl"
          animate={{ x: [0, -80, 0], y: [0, 50, 0] }}
          transition={{ duration: 15, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div 
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-gradient-to-r from-coral/25 to-primary-500/25 rounded-full blur-3xl"
          animate={{ scale: [1, 1.2, 1], rotate: [0, 180, 360] }}
          transition={{ duration: 25, repeat: Infinity, ease: "easeInOut" }}
        />
      </div>

      {/* Grid pattern overlay */}
      <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZGVmcz48cGF0dGVybiBpZD0iZ3JpZCIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBwYXR0ZXJuVW5pdHM9InVzZXJTcGFjZU9uVXNlIj48cGF0aCBkPSJNIDQwIDAgTCAwIDAgMCA0MCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDI1NSwgMjU1LCAyNTUsIDAuMDUpIiBzdHJva2Utd2lkdGg9IjEiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-10"></div>

      <div className="relative z-10 max-w-6xl mx-auto px-6 text-center">
        {/* Floating icon with enhanced animation */}
        <motion.div 
          className="mb-8 flex justify-center"
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ duration: 1, ease: "easeOut" }}
        >
          <motion.div 
            className="relative"
            whileHover={{ scale: 1.1 }}
            animate={{ y: [-10, 10, -10] }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
          >
            <div className="w-28 h-28 bg-gradient-to-r from-primary-500 via-accent-500 to-coral rounded-3xl shadow-premium flex items-center justify-center backdrop-blur-sm border border-white/10">
              <Mic className="w-14 h-14 text-white" strokeWidth={2} />
            </div>
            <motion.div 
              className="absolute -inset-2 bg-gradient-to-r from-primary-500 via-accent-500 to-coral rounded-3xl opacity-75 blur-lg"
              animate={{ scale: [1, 1.1, 1] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            />
          </motion.div>
        </motion.div>

        {/* Main headline with enhanced typography */}
        <motion.h1 
          className="text-6xl md:text-7xl lg:text-8xl font-bold text-white mb-6 leading-tight"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.3 }}
        >
          Speak.{' '}
          <span className="bg-gradient-to-r from-primary-400 via-accent-400 to-coral bg-clip-text text-transparent">
            Create.
          </span>
          <br />
          <span className="text-4xl md:text-5xl lg:text-6xl text-slate-300 font-medium">
            Effortlessly.
          </span>
        </motion.h1>

        {/* Concise subtitle */}
        <motion.p 
          className="text-xl md:text-2xl text-slate-300 mb-12 leading-relaxed max-w-3xl mx-auto font-medium"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
        >
          The fastest voice-to-text app for macOS. Open source, private, and powered by AI.
        </motion.p>

        {/* Enhanced CTA buttons */}
        <motion.div 
          className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-16"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.7 }}
        >
          <motion.button
            onClick={handleDownload}
            whileHover={{ scale: 1.02, boxShadow: "0 20px 40px -8px rgba(14, 165, 233, 0.4)" }}
            whileTap={{ scale: 0.98 }}
            className="group bg-gradient-to-r from-primary-600 to-accent-600 text-white px-8 py-4 rounded-2xl text-lg font-bold shadow-premium hover:shadow-glow transition-all duration-300 flex items-center gap-3 min-w-[250px]"
          >
            <Download className="w-6 h-6 group-hover:scale-110 transition-transform" strokeWidth={2.5} />
            Download for macOS
            <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
          </motion.button>
          
          <motion.button
            onClick={handleViewSource}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="group border-2 border-slate-600 text-slate-200 px-8 py-4 rounded-2xl text-lg font-bold hover:border-slate-500 hover:bg-slate-800 transition-all duration-300 flex items-center gap-3 min-w-[250px] backdrop-blur-sm"
          >
            <Github className="w-6 h-6 group-hover:scale-110 transition-transform" strokeWidth={2.5} />
            View Source Code
          </motion.button>
        </motion.div>

        {/* Compact feature highlights */}
        <motion.div 
          className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.9 }}
        >
          <motion.div 
            className="group text-center bg-slate-800/80 backdrop-blur-md rounded-2xl p-6 border border-slate-700/50 hover:bg-slate-800/90 transition-all duration-300"
            whileHover={{ y: -5 }}
          >
            <Zap className="w-8 h-8 text-primary-400 mx-auto mb-3 group-hover:scale-110 transition-transform" strokeWidth={2} />
            <div className="text-xl font-bold text-white mb-2">Lightning Fast</div>
            <div className="text-slate-300 font-medium">Real-time transcription</div>
          </motion.div>
          
          <motion.div 
            className="group text-center bg-slate-800/80 backdrop-blur-md rounded-2xl p-6 border border-slate-700/50 hover:bg-slate-800/90 transition-all duration-300"
            whileHover={{ y: -5 }}
          >
            <Sparkles className="w-8 h-8 text-accent-400 mx-auto mb-3 group-hover:scale-110 transition-transform" strokeWidth={2} />
            <div className="text-xl font-bold text-white mb-2">AI Powered</div>
            <div className="text-slate-300 font-medium">Smart corrections</div>
          </motion.div>
          
          <motion.div 
            className="group text-center bg-slate-800/80 backdrop-blur-md rounded-2xl p-6 border border-slate-700/50 hover:bg-slate-800/90 transition-all duration-300"
            whileHover={{ y: -5 }}
          >
            <div className="w-8 h-8 text-coral mx-auto mb-3 text-2xl group-hover:scale-110 transition-transform">🔒</div>
            <div className="text-xl font-bold text-white mb-2">100% Private</div>
            <div className="text-slate-300 font-medium">Your data stays local</div>
          </motion.div>
        </motion.div>

        {/* Compact system requirements */}
        <motion.div 
          className="mt-16 text-slate-400 text-lg font-medium"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 1.1 }}
        >
          <p>macOS Monterey+ • Free Forever • No Account Required</p>
        </motion.div>
      </div>
    </section>
  )
} 