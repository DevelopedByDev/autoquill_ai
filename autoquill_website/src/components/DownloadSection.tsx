'use client'

import React from 'react'
import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Download, Check, Star, Users, Globe, Github, Sparkles, Zap, Shield, Trophy, Target, Rocket } from 'lucide-react'

export default function DownloadSection() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })

  const handleDownload = () => {
    // Link to the local DMG file
    const link = document.createElement('a')
    link.href = '/downloads/AutoQuill-installer.dmg'
    link.download = 'AutoQuill-installer.dmg'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  const handleViewSource = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai', '_blank')
  }

  const features = [
    { text: "Real-time voice transcription", icon: <Zap className="w-4 h-4" /> },
    { text: "Smart clipboard integration", icon: <Target className="w-4 h-4" /> }, 
    { text: "Custom keyboard shortcuts", icon: <Rocket className="w-4 h-4" /> },
    { text: "AI-powered corrections", icon: <Shield className="w-4 h-4" /> },
    { text: "Complete privacy protection", icon: <Trophy className="w-4 h-4" /> }
  ]

  const stats = [
    { icon: <Users className="w-5 h-5" />, value: "15K+", label: "Active Users", color: "from-blue-400 to-blue-600" },
    { icon: <Star className="w-5 h-5" />, value: "4.9", label: "User Rating", color: "from-yellow-400 to-orange-500" },
    { icon: <Globe className="w-5 h-5" />, value: "50+", label: "Languages", color: "from-green-400 to-emerald-500" },
    { icon: <Github className="w-5 h-5" />, value: "Open", label: "Source", color: "from-purple-400 to-pink-500" }
  ]

  // Advanced animation variants
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2
      }
    }
  }

  const itemVariants = {
    hidden: { 
      opacity: 0, 
      y: 30,
      scale: 0.9,
      filter: "blur(10px)"
    },
    visible: { 
      opacity: 1, 
      y: 0,
      scale: 1,
      filter: "blur(0px)",
      transition: {
        duration: 0.6,
        ease: [0.19, 1, 0.22, 1]
      }
    }
  }

  const cardVariants = {
    hidden: { 
      opacity: 0, 
      y: 50,
      rotateX: -15
    },
    visible: { 
      opacity: 1, 
      y: 0,
      rotateX: 0,
      transition: {
        duration: 0.8,
        ease: [0.19, 1, 0.22, 1]
      }
    }
  }

  return (
    <section ref={ref} className="py-32 bg-slate-900 relative overflow-hidden">
      {/* Advanced animated background */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-r from-primary-500/15 to-accent-500/15 rounded-full blur-3xl"
          animate={{ 
            x: [0, 80, 0], 
            y: [0, -60, 0],
            scale: [1, 1.3, 1]
          }}
          transition={{ 
            duration: 28, 
            repeat: Infinity, 
            ease: "easeInOut" 
          }}
        />
        <motion.div 
          className="absolute bottom-0 right-1/4 w-80 h-80 bg-gradient-to-r from-accent-500/15 to-coral/15 rounded-full blur-3xl"
          animate={{ 
            x: [0, -60, 0], 
            y: [0, 40, 0],
            scale: [1, 0.8, 1]
          }}
          transition={{ 
            duration: 22, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 3
          }}
        />
        {/* Mesh gradient overlay */}
        <div className="absolute inset-0 bg-mesh-gradient opacity-5"></div>
      </div>

      <motion.div 
        className="max-w-6xl mx-auto px-6 relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Enhanced header with stream-in animation */}
        <motion.div
          className="text-center mb-16"
          variants={itemVariants}
        >
          <motion.h2 
            className="text-fluid-5xl font-display font-bold text-white mb-6"
            style={{
              background: 'linear-gradient(135deg, #ffffff 0%, #60a5fa 50%, #d946ef 100%)',
              backgroundClip: 'text',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textShadow: '0 4px 20px rgba(0,0,0,0.3)'
            }}
          >
            Ready to Transform Your Workflow?
          </motion.h2>
          <motion.p 
            className="text-fluid-xl text-slate-300 max-w-3xl mx-auto leading-relaxed font-medium"
            variants={itemVariants}
          >
            Join thousands using AutoQuill AI to work faster, smarter, and more efficiently than ever before.
          </motion.p>
        </motion.div>

        {/* Revolutionary main download card with 3D effects */}
        <motion.div
          className="perspective-1000 mb-16"
          variants={cardVariants}
        >
          <motion.div
            className="glass-dark rounded-3xl p-8 md:p-12 shadow-premium border border-white/10 backdrop-blur-xl preserve-3d"
            whileHover={{ 
              rotateY: 2,
              rotateX: 2,
              scale: 1.02,
              transition: { duration: 0.3 }
            }}
          >
            <div className="grid md:grid-cols-2 gap-12 items-center">
              {/* Enhanced features list */}
              <motion.div variants={itemVariants}>
                <motion.h3 
                  className="text-2xl font-bold text-white mb-8 flex items-center gap-3"
                  whileHover={{ scale: 1.05 }}
                >
                  <motion.div
                    className="w-8 h-8 bg-gradient-to-r from-primary-400 to-accent-400 rounded-xl flex items-center justify-center"
                    animate={{ rotate: [0, 360] }}
                    transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles className="w-4 h-4 text-white" />
                  </motion.div>
                  Premium Features Included
                </motion.h3>
                <div className="space-y-4 mb-8">
                  {features.map((feature, index) => (
                    <motion.div
                      key={index}
                      className="flex items-center gap-4 group"
                      initial={{ opacity: 0, x: -30 }}
                      animate={isInView ? { opacity: 1, x: 0 } : {}}
                      transition={{ duration: 0.6, delay: 0.6 + index * 0.1 }}
                      whileHover={{ x: 10, transition: { duration: 0.2 } }}
                    >
                      <motion.div 
                        className="w-8 h-8 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center flex-shrink-0 shadow-lg"
                        whileHover={{ 
                          scale: 1.2,
                          rotate: 180,
                          transition: { duration: 0.3 }
                        }}
                      >
                        <Check className="w-4 h-4 text-white" strokeWidth={3} />
                      </motion.div>
                      <div className="flex items-center gap-2">
                        {feature.icon}
                        <span className="text-slate-300 font-medium group-hover:text-white transition-colors duration-300">
                          {feature.text}
                        </span>
                      </div>
                    </motion.div>
                  ))}
                </div>
                
                {/* Enhanced guarantee badge */}
                <motion.div 
                  className="glass rounded-xl p-4 border border-primary-400/20"
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={isInView ? { opacity: 1, scale: 1 } : {}}
                  transition={{ duration: 0.6, delay: 1.2 }}
                  whileHover={{ scale: 1.05 }}
                >
                  <p className="font-semibold text-primary-300 text-center">
                    ✓ Forever Free • ✓ No Registration • ✓ Open Source • ✓ Privacy First
                  </p>
                </motion.div>
              </motion.div>

              {/* Enhanced download section */}
              <motion.div 
                className="text-center"
                variants={itemVariants}
              >
                {/* Fixed pricing display with better visibility */}
                <motion.div 
                  className="mb-8 p-8 glass rounded-3xl border border-white/10 relative overflow-hidden"
                  whileHover={{ scale: 1.05 }}
                  initial={{ opacity: 0, y: 30 }}
                  animate={isInView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.6, delay: 0.8 }}
                >
                  {/* Animated background glow */}
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-accent-500/20 rounded-3xl"
                    animate={{
                      scale: [1, 1.1, 1],
                      opacity: [0.3, 0.6, 0.3]
                    }}
                    transition={{
                      duration: 4,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                  />
                  <div className="relative z-10">
                    <motion.div 
                      className="text-6xl font-bold text-white mb-2"
                      style={{
                        background: 'linear-gradient(135deg, #ffffff 0%, #60a5fa 50%, #d946ef 100%)',
                        backgroundClip: 'text',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent'
                      }}
                      animate={{ scale: [1, 1.05, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    >
                      Free
                    </motion.div>
                    <div className="text-slate-300 font-medium text-lg">Forever & Always</div>
                  </div>
                </motion.div>

                {/* Revolutionary download button */}
                <motion.button
                  onClick={handleDownload}
                  className="group relative w-full bg-gradient-to-r from-primary-500 via-accent-500 to-coral text-white py-6 px-8 rounded-2xl text-xl font-bold shadow-premium border border-white/20 mb-6 overflow-hidden"
                  whileHover={{ 
                    scale: 1.05,
                    boxShadow: "0 30px 60px -12px rgba(59, 130, 246, 0.4)"
                  }}
                  whileTap={{ scale: 0.98 }}
                  initial={{ opacity: 0, y: 30 }}
                  animate={isInView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.6, delay: 1.0 }}
                >
                  {/* Animated background waves */}
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-primary-400 to-accent-400 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
                    initial={{ x: '-100%' }}
                    whileHover={{ x: '0%' }}
                    transition={{ duration: 0.8, ease: "easeOut" }}
                  />
                  
                  <span className="relative flex items-center justify-center gap-3 z-10">
                    <Download className="w-6 h-6 group-hover:scale-110 group-hover:-translate-y-1 transition-all duration-300" />
                    Download for macOS
                    <motion.div
                      animate={{ rotate: [0, 360] }}
                      transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                    >
                      <Sparkles className="w-5 h-5" />
                    </motion.div>
                  </span>

                  {/* Particle effect */}
                  <div className="absolute inset-0 pointer-events-none">
                    {[...Array(8)].map((_, i) => (
                      <motion.div
                        key={i}
                        className="absolute w-1 h-1 bg-white rounded-full opacity-0 group-hover:opacity-100"
                        style={{
                          left: `${10 + i * 10}%`,
                          top: `${20 + (i % 3) * 20}%`,
                        }}
                        animate={{
                          y: [-10, -30, -10],
                          opacity: [0, 1, 0]
                        }}
                        transition={{
                          duration: 1.5,
                          delay: i * 0.1,
                          repeat: Infinity,
                          ease: "easeInOut"
                        }}
                      />
                    ))}
                  </div>
                </motion.button>

                {/* Enhanced version info */}
                <motion.div 
                  className="text-sm text-slate-400 mb-6 space-y-2"
                  initial={{ opacity: 0 }}
                  animate={isInView ? { opacity: 1 } : {}}
                  transition={{ duration: 0.6, delay: 1.2 }}
                >
                  <p className="font-semibold flex items-center justify-center gap-2">
                    <motion.div
                      className="w-2 h-2 bg-green-400 rounded-full"
                      animate={{ scale: [1, 1.5, 1], opacity: [1, 0.5, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    />
                    Version 2.1.0 • 15 MB
                  </p>
                  <p>Intel & Apple Silicon • macOS Monterey+</p>
                </motion.div>

                {/* Enhanced source code link */}
                <motion.button
                  onClick={handleViewSource}
                  className="group inline-flex items-center gap-2 text-slate-300 hover:text-primary-400 transition-all duration-300 font-medium"
                  whileHover={{ scale: 1.05 }}
                  initial={{ opacity: 0 }}
                  animate={isInView ? { opacity: 1 } : {}}
                  transition={{ duration: 0.6, delay: 1.4 }}
                >
                  <Github className="w-5 h-5 group-hover:scale-110 group-hover:rotate-12 transition-all duration-300" />
                  View source code on GitHub
                  <motion.div
                    className="w-1 h-1 bg-primary-400 rounded-full"
                    animate={{ scale: [1, 2, 1] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  />
                </motion.button>
              </motion.div>
            </div>
          </motion.div>
        </motion.div>

        {/* Enhanced stats grid with glassmorphism */}
        <motion.div
          className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-16"
          variants={containerVariants}
        >
          {stats.map((stat, index) => (
            <motion.div 
              key={index} 
              className="glass-dark rounded-2xl p-6 text-center shadow-medium border border-white/10 backdrop-blur-xl hover:border-white/20 transition-all duration-500 group"
              variants={itemVariants}
              whileHover={{ 
                y: -8,
                scale: 1.03,
                transition: { duration: 0.3 }
              }}
            >
              <motion.div 
                className={`flex items-center justify-center gap-2 mb-3 group-hover:scale-110 transition-transform duration-300`}
                whileHover={{ rotate: [0, -10, 10, 0] }}
                transition={{ duration: 0.6 }}
              >
                <div className={`w-8 h-8 bg-gradient-to-r ${stat.color} rounded-xl flex items-center justify-center`}>
                  {stat.icon}
                </div>
                <span className="text-3xl font-bold text-white">{stat.value}</span>
              </motion.div>
              <div className="text-sm text-slate-400 font-medium group-hover:text-slate-300 transition-colors duration-300">
                {stat.label}
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Fixed bottom CTA with proper text colors */}
        <motion.div
          className="text-center glass-dark rounded-3xl p-12 shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden"
          variants={itemVariants}
          whileHover={{ scale: 1.02 }}
        >
          {/* Animated background pattern */}
          <motion.div
            className="absolute inset-0 bg-gradient-to-r from-primary-500/10 via-accent-500/10 to-coral/10"
            animate={{
              backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
            }}
            transition={{
              duration: 10,
              repeat: Infinity,
              ease: "linear"
            }}
            style={{
              backgroundSize: '200% 200%'
            }}
          />
          
          <div className="relative z-10">
            <motion.h3 
              className="text-fluid-3xl font-bold text-white mb-6"
              animate={{ scale: [1, 1.02, 1] }}
              transition={{ duration: 3, repeat: Infinity }}
            >
              Experience the Future of Text Creation
            </motion.h3>
            <motion.p 
              className="text-fluid-lg text-slate-300 mb-8 max-w-3xl mx-auto leading-relaxed font-medium"
              variants={itemVariants}
            >
              Join the voice-first revolution. Your most productive workflow awaits with cutting-edge AI technology.
            </motion.p>
            <motion.button
              onClick={handleDownload}
              className="group bg-gradient-to-r from-primary-500 to-accent-500 text-white px-10 py-5 rounded-2xl font-bold text-lg shadow-premium transition-all duration-300 relative overflow-hidden min-w-[280px]"
              whileHover={{ 
                scale: 1.05,
                boxShadow: "0 25px 50px -12px rgba(59, 130, 246, 0.4)"
              }}
              whileTap={{ scale: 0.98 }}
            >
              <span className="flex items-center justify-center gap-2 relative z-10">
                Get Started Now
                <motion.div
                  animate={{ rotate: [0, 360] }}
                  transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                >
                  <Sparkles className="w-5 h-5" />
                </motion.div>
              </span>
              
              {/* Ripple effect */}
              <motion.div
                className="absolute inset-0 bg-white/20 rounded-2xl scale-0 group-hover:scale-100 transition-transform duration-500"
                style={{ transformOrigin: 'center' }}
              />
            </motion.button>
          </div>
        </motion.div>
      </motion.div>
    </section>
  )
} 