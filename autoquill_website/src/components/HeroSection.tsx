'use client'

import React, { useEffect, useState } from 'react'
import { motion, useAnimation, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Mic, Download, Github, Sparkles, Zap, Shield, Cpu, Command } from 'lucide-react'

export default function HeroSection() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })
  const [isLoaded, setIsLoaded] = useState(false)

  useEffect(() => {
    const timer = setTimeout(() => setIsLoaded(true), 500)
    return () => clearTimeout(timer)
  }, [])

  const handleDownload = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai/releases', '_blank')
  }

  const handleViewSource = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai', '_blank')
  }

  // Advanced floating animation variants
  const floatingVariants = {
    float: {
      y: [-20, -10, -20],
      transition: {
        duration: 6,
        repeat: Infinity,
        ease: "easeInOut"
      }
    }
  }

  // Stream-in animation for text
  const streamInVariants = {
    hidden: { 
      opacity: 0, 
      y: 30, 
      filter: "blur(10px)",
      scale: 0.95
    },
    visible: { 
      opacity: 1, 
      y: 0, 
      filter: "blur(0px)",
      scale: 1,
      transition: {
        duration: 0.8,
        ease: [0.19, 1, 0.22, 1],
      }
    }
  }

  // Container animation with stagger
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.3
      }
    }
  }

  return (
    <section ref={ref} className="relative min-h-screen flex items-center justify-center overflow-hidden bg-slate-950">
      {/* Advanced mesh gradient background */}
      <div className="absolute inset-0 bg-mesh-gradient opacity-20"></div>
      
      {/* Animated gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-950 via-slate-900/95 to-slate-950 animate-gradient-xy"></div>
      
      {/* Floating geometric shapes with advanced animations */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-1/4 -left-32 w-96 h-96 bg-gradient-to-r from-primary-500/20 to-accent-500/20 rounded-full blur-3xl"
          animate={{ 
            x: [0, 150, 0], 
            y: [0, -80, 0],
            scale: [1, 1.2, 1]
          }}
          transition={{ 
            duration: 25, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 0
          }}
        />
        <motion.div 
          className="absolute bottom-1/3 -right-32 w-80 h-80 bg-gradient-to-r from-accent-500/25 to-coral/25 rounded-full blur-3xl"
          animate={{ 
            x: [0, -120, 0], 
            y: [0, 60, 0],
            scale: [1, 0.8, 1]
          }}
          transition={{ 
            duration: 20, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 5
          }}
        />
        <motion.div 
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-gradient-to-r from-coral/15 to-primary-500/15 rounded-full blur-3xl animate-morph"
          animate={{ 
            rotate: [0, 360],
            scale: [1, 1.3, 1]
          }}
          transition={{ 
            duration: 30, 
            repeat: Infinity, 
            ease: "linear"
          }}
        />
      </div>

      {/* Grid pattern overlay with glassmorphism */}
      <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZGVmcz48cGF0dGVybiBpZD0iZ3JpZCIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBwYXR0ZXJuVW5pdHM9InVzZXJTcGFjZU9uVXNlIj48cGF0aCBkPSJNIDQwIDAgTCAwIDAgMCA0MCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDI1NSwgMjU1LCAyNTUsIDAuMDMpIiBzdHJva2Utd2lkdGg9IjEiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-30"></div>

      <motion.div 
        className="relative z-10 max-w-7xl mx-auto px-6 text-center"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Floating microphone icon with glassmorphism */}
        <motion.div 
          className="mb-12 flex justify-center"
          variants={streamInVariants}
        >
          <motion.div 
            className="relative group cursor-pointer"
            variants={floatingVariants}
            animate="float"
            whileHover={{ 
              scale: 1.1,
              rotateY: 15,
              transition: { duration: 0.3 }
            }}
          >
            <div className="w-32 h-32 glass-dark rounded-3xl shadow-premium flex items-center justify-center backdrop-blur-xl border border-white/10 group-hover:border-primary-400/30 transition-all duration-500">
              <Mic className="w-16 h-16 text-white drop-shadow-lg" strokeWidth={1.5} />
            </div>
            {/* Glow effect */}
            <motion.div 
              className="absolute -inset-4 bg-gradient-to-r from-primary-500/30 via-accent-500/30 to-coral/30 rounded-3xl opacity-0 blur-xl group-hover:opacity-100 transition-opacity duration-500"
              animate={{
                scale: [1, 1.05, 1],
                opacity: [0.3, 0.6, 0.3]
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
            {/* Floating particles */}
            <div className="absolute inset-0 pointer-events-none">
              {[...Array(6)].map((_, i) => (
                <motion.div
                  key={i}
                  className="absolute w-1 h-1 bg-primary-400 rounded-full"
                  style={{
                    left: `${20 + i * 15}%`,
                    top: `${20 + i * 10}%`,
                  }}
                  animate={{
                    y: [-5, -15, -5],
                    opacity: [0, 1, 0]
                  }}
                  transition={{
                    duration: 2,
                    delay: i * 0.3,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                />
              ))}
            </div>
          </motion.div>
        </motion.div>

        {/* Main headline with advanced typography */}
        <motion.div variants={streamInVariants}>
          <motion.h1 
            className="font-display text-fluid-8xl font-bold text-white mb-8 leading-tight tracking-tight"
            style={{
              textShadow: '0 4px 20px rgba(0,0,0,0.3)'
            }}
          >
            <motion.span
              className="inline-block"
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.5 }}
            >
              Speak.{' '}
            </motion.span>
            <motion.span 
              className="inline-block bg-gradient-to-r from-primary-400 via-accent-400 to-coral bg-clip-text text-transparent animate-gradient-x"
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.7 }}
            >
              Create.
            </motion.span>
            <br />
            <motion.span 
              className="inline-block text-fluid-6xl text-slate-300 font-medium"
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: 0.9 }}
            >
              Effortlessly.
            </motion.span>
          </motion.h1>
        </motion.div>

        {/* Enhanced subtitle with stream-in effect */}
        <motion.p 
          className="text-fluid-xl text-slate-300 mb-16 leading-relaxed max-w-4xl mx-auto font-medium"
          variants={streamInVariants}
          style={{
            textShadow: '0 2px 10px rgba(0,0,0,0.3)'
          }}
        >
          The most advanced voice-to-text app for macOS. Open source, AI-powered, and designed for the future.
        </motion.p>

        {/* Revolutionary CTA buttons with advanced interactions */}
        <motion.div 
          className="flex flex-col sm:flex-row gap-6 justify-center items-center mb-20"
          variants={streamInVariants}
        >
          <motion.button
            onClick={handleDownload}
            className="group relative overflow-hidden bg-gradient-to-r from-primary-600 via-accent-600 to-coral text-white px-10 py-5 rounded-2xl text-lg font-bold shadow-premium border border-white/10 min-w-[280px]"
            whileHover={{ 
              scale: 1.03,
              boxShadow: "0 25px 50px -12px rgba(59, 130, 246, 0.4)"
            }}
            whileTap={{ scale: 0.98 }}
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 1.1 }}
          >
            {/* Animated background */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-primary-500 to-accent-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
              initial={{ x: '-100%' }}
              whileHover={{ x: '0%' }}
              transition={{ duration: 0.6, ease: "easeOut" }}
            />
            <span className="relative flex items-center gap-3 z-10">
              <Download className="w-6 h-6 group-hover:scale-110 transition-transform duration-300" strokeWidth={2} />
              Download for macOS
              <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform duration-300" />
            </span>
            {/* Shimmer effect */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
              initial={{ x: '-100%', skewX: -45 }}
              animate={{ x: '200%' }}
              transition={{
                duration: 2,
                delay: 2,
                repeat: Infinity,
                repeatDelay: 5,
                ease: "easeInOut"
              }}
            />
          </motion.button>
          
          <motion.button
            onClick={handleViewSource}
            className="group glass-dark border-2 border-slate-600/50 text-slate-200 px-10 py-5 rounded-2xl text-lg font-bold hover:border-slate-500/70 backdrop-blur-xl transition-all duration-300 flex items-center gap-3 min-w-[280px] hover:bg-white/5"
            whileHover={{ 
              scale: 1.03,
              boxShadow: "0 20px 40px -12px rgba(0, 0, 0, 0.3)"
            }}
            whileTap={{ scale: 0.98 }}
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6, delay: 1.3 }}
          >
            <Github className="w-6 h-6 group-hover:scale-110 group-hover:rotate-12 transition-all duration-300" strokeWidth={2} />
            View Source Code
            <motion.div
              className="w-2 h-2 bg-green-400 rounded-full"
              animate={{
                scale: [1, 1.5, 1],
                opacity: [1, 0.6, 1]
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            />
          </motion.button>
        </motion.div>

        {/* Enhanced feature highlights with glassmorphism cards */}
        <motion.div 
          className="grid grid-cols-1 md:grid-cols-4 gap-6 max-w-5xl mx-auto"
          variants={containerVariants}
          initial="hidden"
          animate={isInView ? "visible" : "hidden"}
        >
          {[
            { icon: Zap, title: "Lightning Fast", desc: "Sub-second response", color: "from-yellow-400 to-orange-500" },
            { icon: Shield, title: "100% Private", desc: "Your data stays local", color: "from-green-400 to-emerald-500" },
            { icon: Cpu, title: "AI Powered", desc: "Smart corrections", color: "from-purple-400 to-pink-500" },
            { icon: Command, title: "Hotkey Driven", desc: "Seamless workflow", color: "from-blue-400 to-cyan-500" }
          ].map((feature, index) => (
            <motion.div 
              key={index}
              className="group glass-dark rounded-2xl p-6 border border-white/10 hover:border-white/20 backdrop-blur-xl transition-all duration-500 hover:bg-white/5"
              variants={streamInVariants}
              whileHover={{ 
                y: -8,
                scale: 1.02,
                transition: { duration: 0.3 }
              }}
            >
              <motion.div
                className={`w-12 h-12 bg-gradient-to-r ${feature.color} rounded-xl flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300`}
                whileHover={{ rotate: [0, -10, 10, 0] }}
                transition={{ duration: 0.6 }}
              >
                <feature.icon className="w-6 h-6 text-white" strokeWidth={2} />
              </motion.div>
              <div className="text-lg font-bold text-white mb-2 group-hover:text-gradient transition-all duration-300">
                {feature.title}
              </div>
              <div className="text-slate-400 font-medium group-hover:text-slate-300 transition-colors duration-300">
                {feature.desc}
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* System requirements with stream-in effect */}
        <motion.div 
          className="mt-20 text-slate-400 text-lg font-medium"
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 1.5 }}
        >
          <p className="flex items-center justify-center gap-2 flex-wrap">
            <span className="flex items-center gap-1">
              <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
              macOS Monterey+
            </span>
            <span className="text-slate-600">•</span>
            <span className="flex items-center gap-1">
              <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse"></div>
              Free Forever
            </span>
            <span className="text-slate-600">•</span>
            <span className="flex items-center gap-1">
              <div className="w-2 h-2 bg-purple-400 rounded-full animate-pulse"></div>
              No Account Required
            </span>
          </p>
        </motion.div>
      </motion.div>

      {/* Scroll indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
        initial={{ opacity: 0, y: 20 }}
        animate={isInView ? { opacity: 1, y: 0 } : {}}
        transition={{ duration: 1, delay: 2 }}
      >
        <motion.div
          className="w-6 h-10 border-2 border-white/30 rounded-full flex justify-center p-1"
          animate={{ opacity: [1, 0.3, 1] }}
          transition={{ duration: 2, repeat: Infinity }}
        >
          <motion.div
            className="w-1 h-2 bg-white rounded-full"
            animate={{ y: [0, 12, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
        </motion.div>
      </motion.div>
    </section>
  )
} 