'use client'

import React from 'react'
import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Mic, Command, Cpu, CheckCircle, Zap, Target, Rocket, ArrowRight, Sparkles, Clock, Shield, Globe, Brain } from 'lucide-react'

export default function HowItWorks() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })

  const steps = [
    {
      icon: <Command className="w-8 h-8" strokeWidth={2} />,
      title: "Press Your Hotkey",
      description: "Hit your custom shortcut from anywhere on macOS to instantly activate voice capture",
      detail: "Customizable shortcuts • Global accessibility • Lightning fast activation",
      color: "from-blue-400 to-blue-600",
      bgGlow: "from-blue-500/20 to-blue-600/20",
      step: "01"
    },
    {
      icon: <Mic className="w-8 h-8" strokeWidth={2} />,
      title: "Speak Naturally", 
      description: "Talk normally while our advanced AI captures and understands your voice in real-time",
      detail: "Neural networks • Real-time processing • Natural language understanding",
      color: "from-green-400 to-emerald-600",
      bgGlow: "from-green-500/20 to-emerald-600/20",
      step: "02"
    },
    {
      icon: <Brain className="w-8 h-8" strokeWidth={2} />,
      title: "AI Processing",
      description: "Advanced machine learning algorithms transcribe and intelligently correct your speech",
      detail: "Smart punctuation • Context awareness • Grammar optimization",
      color: "from-purple-400 to-pink-600",
      bgGlow: "from-purple-500/20 to-pink-600/20",
      step: "03"
    },
    {
      icon: <Target className="w-8 h-8" strokeWidth={2} />,
      title: "Instant Results",
      description: "Perfectly formatted text appears instantly in your clipboard, ready to paste anywhere",
      detail: "Auto-clipboard • Format preservation • Universal compatibility",
      color: "from-orange-400 to-red-600",
      bgGlow: "from-orange-500/20 to-red-600/20",
      step: "04"
    }
  ]

  const features = [
    { 
      icon: <Zap className="w-6 h-6" />, 
      text: "Sub-second response time",
      color: "text-yellow-400"
    },
    { 
      icon: <Shield className="w-6 h-6" />, 
      text: "100% private & offline processing",
      color: "text-green-400"
    },
    { 
      icon: <Globe className="w-6 h-6" />, 
      text: "Works in any application",
      color: "text-blue-400"
    },
    { 
      icon: <Clock className="w-6 h-6" />, 
      text: "Always running in background",
      color: "text-purple-400"
    }
  ]

  // Advanced animation variants
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

  const stepVariants = {
    hidden: { 
      opacity: 0, 
      y: 60,
      scale: 0.8,
      rotateX: -20
    },
    visible: { 
      opacity: 1, 
      y: 0,
      scale: 1,
      rotateX: 0,
      transition: {
        duration: 0.8,
        ease: [0.19, 1, 0.22, 1]
      }
    }
  }

  const itemVariants = {
    hidden: { 
      opacity: 0, 
      y: 30,
      filter: "blur(10px)"
    },
    visible: { 
      opacity: 1, 
      y: 0,
      filter: "blur(0px)",
      transition: {
        duration: 0.6,
        ease: [0.19, 1, 0.22, 1]
      }
    }
  }

  const flowVariants = {
    hidden: { pathLength: 0, opacity: 0 },
    visible: { 
      pathLength: 1, 
      opacity: 1,
      transition: {
        pathLength: { duration: 2, ease: "easeInOut" },
        opacity: { duration: 0.5 }
      }
    }
  }

  return (
    <section ref={ref} className="py-32 bg-slate-950 relative overflow-hidden">
      {/* Revolutionary animated background */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div 
          className="absolute top-1/3 -left-48 w-96 h-96 bg-gradient-to-r from-primary-500/10 to-accent-500/10 rounded-full blur-3xl"
          animate={{ 
            x: [0, 120, 0], 
            y: [0, -80, 0],
            scale: [1, 1.4, 1],
            rotate: [0, 180, 360]
          }}
          transition={{ 
            duration: 35, 
            repeat: Infinity, 
            ease: "easeInOut" 
          }}
        />
        <motion.div 
          className="absolute bottom-1/3 -right-48 w-80 h-80 bg-gradient-to-r from-accent-500/10 to-coral/10 rounded-full blur-3xl"
          animate={{ 
            x: [0, -100, 0], 
            y: [0, 60, 0],
            scale: [1, 0.7, 1],
            rotate: [360, 180, 0]
          }}
          transition={{ 
            duration: 30, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 5
          }}
        />
        
        {/* Advanced mesh gradient */}
        <div className="absolute inset-0 bg-mesh-gradient opacity-[0.03]"></div>
        
        {/* Dynamic grid pattern */}
        <motion.div 
          className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZGVmcz48cGF0dGVybiBpZD0iZ3JpZCIgd2lkdGg9IjYwIiBoZWlnaHQ9IjYwIiBwYXR0ZXJuVW5pdHM9InVzZXJTcGFjZU9uVXNlIj48cGF0aCBkPSJNIDYwIDAgTCAwIDAgMCA2MCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJyZ2JhKDI1NSwgMjU1LCAyNTUsIDAuMDIpIiBzdHJva2Utd2lkdGg9IjEiLz48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9InVybCgjZ3JpZCkiLz48L3N2Zz4=')] opacity-40"
          animate={{ opacity: [0.2, 0.4, 0.2] }}
          transition={{ duration: 8, repeat: Infinity }}
        />
      </div>

      <motion.div 
        className="max-w-7xl mx-auto px-6 relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Enhanced header with advanced typography */}
        <motion.div 
          className="text-center mb-20"
          variants={itemVariants}
        >
          <motion.h2 
            className="text-fluid-6xl font-display font-bold text-white mb-8 leading-tight"
            style={{
              background: 'linear-gradient(135deg, #ffffff 0%, #3b82f6 30%, #d946ef 70%, #ff6b35 100%)',
              backgroundClip: 'text',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textShadow: '0 4px 30px rgba(0,0,0,0.3)'
            }}
          >
            How It Works
          </motion.h2>
          <motion.p 
            className="text-fluid-xl text-slate-300 max-w-4xl mx-auto leading-relaxed font-medium mb-12"
            variants={itemVariants}
          >
            Four simple steps to transform your voice into perfectly formatted text. 
            Experience the magic of AI-powered transcription that just works.
          </motion.p>

          {/* Feature highlights */}
          <motion.div 
            className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-4xl mx-auto"
            variants={containerVariants}
          >
            {features.map((feature, index) => (
              <motion.div
                key={index}
                className="glass-dark rounded-xl p-4 border border-white/10 backdrop-blur-xl"
                variants={itemVariants}
                whileHover={{ 
                  scale: 1.05,
                  y: -5,
                  transition: { duration: 0.2 }
                }}
              >
                <div className={`${feature.color} mb-2 flex justify-center`}>
                  {feature.icon}
                </div>
                <p className="text-sm text-slate-300 font-medium text-center">
                  {feature.text}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Revolutionary step-by-step process */}
        <motion.div 
          className="relative"
          variants={containerVariants}
        >
          {/* Connecting flow lines with SVG animation */}
          <div className="hidden lg:block absolute inset-0 pointer-events-none">
            <svg className="w-full h-full" viewBox="0 0 1000 400">
              <defs>
                <linearGradient id="flowGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.8" />
                  <stop offset="50%" stopColor="#d946ef" stopOpacity="0.8" />
                  <stop offset="100%" stopColor="#ff6b35" stopOpacity="0.8" />
                </linearGradient>
              </defs>
              
              <motion.path
                d="M 200 200 Q 350 150 500 200 Q 650 250 800 200"
                stroke="url(#flowGradient)"
                strokeWidth="3"
                fill="none"
                variants={flowVariants}
                initial="hidden"
                animate={isInView ? "visible" : "hidden"}
                style={{
                  filter: 'drop-shadow(0 0 10px rgba(59, 130, 246, 0.5))'
                }}
              />
              
              {/* Animated particles along the path */}
              {[...Array(5)].map((_, i) => (
                <motion.circle
                  key={i}
                  r="3"
                  fill="#60a5fa"
                  initial={{ opacity: 0 }}
                  animate={isInView ? {
                    opacity: [0, 1, 0],
                    cx: [200, 350, 500, 650, 800],
                    cy: [200, 150, 200, 250, 200]
                  } : {}}
                  transition={{
                    duration: 3,
                    delay: i * 0.5,
                    repeat: Infinity,
                    repeatDelay: 2
                  }}
                />
              ))}
            </svg>
          </div>

          {/* Enhanced step cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                className="group relative perspective-1000"
                variants={stepVariants}
                whileHover={{ scale: 1.05 }}
              >
                {/* Floating number badge */}
                <motion.div
                  className="absolute -top-4 -right-4 w-12 h-12 bg-gradient-to-r from-primary-500 to-accent-500 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg z-20"
                  whileHover={{ 
                    scale: 1.2,
                    rotate: 360,
                    transition: { duration: 0.6 }
                  }}
                  animate={{
                    boxShadow: [
                      "0 0 20px rgba(59, 130, 246, 0.3)",
                      "0 0 40px rgba(217, 70, 239, 0.3)",
                      "0 0 20px rgba(59, 130, 246, 0.3)"
                    ]
                  }}
                  transition={{
                    duration: 3,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  {step.step}
                </motion.div>

                {/* Main card with 3D effects */}
                <motion.div 
                  className="glass-dark rounded-3xl p-8 h-full shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden preserve-3d group-hover:border-white/20 transition-all duration-500"
                  whileHover={{ 
                    rotateY: 5,
                    rotateX: 5,
                    transition: { duration: 0.3 }
                  }}
                >
                  {/* Animated background glow */}
                  <motion.div
                    className={`absolute inset-0 bg-gradient-to-r ${step.bgGlow} rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
                    animate={{
                      scale: [1, 1.1, 1],
                      opacity: [0.1, 0.3, 0.1]
                    }}
                    transition={{
                      duration: 4,
                      repeat: Infinity,
                      ease: "easeInOut",
                      delay: index * 0.5
                    }}
                  />

                  <div className="relative z-10">
                    {/* Enhanced icon with animation */}
                    <motion.div 
                      className={`w-16 h-16 bg-gradient-to-r ${step.color} rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-lg group-hover:shadow-2xl transition-all duration-500`}
                      whileHover={{ 
                        scale: 1.1,
                        rotate: [0, -10, 10, 0],
                        transition: { duration: 0.6 }
                      }}
                      animate={{
                        y: [0, -5, 0]
                      }}
                      transition={{
                        duration: 3,
                        repeat: Infinity,
                        ease: "easeInOut",
                        delay: index * 0.2
                      }}
                    >
                      <motion.div
                        animate={{ rotate: [0, 360] }}
                        transition={{ 
                          duration: 20, 
                          repeat: Infinity, 
                          ease: "linear" 
                        }}
                      >
                        {step.icon}
                      </motion.div>
                    </motion.div>

                    {/* Enhanced content */}
                    <motion.h3 
                      className="text-2xl font-bold text-white mb-4 group-hover:text-gradient transition-all duration-300"
                      whileHover={{ scale: 1.02 }}
                    >
                      {step.title}
                    </motion.h3>
                    
                    <motion.p 
                      className="text-slate-300 mb-6 leading-relaxed font-medium group-hover:text-slate-200 transition-colors duration-300"
                      variants={itemVariants}
                    >
                      {step.description}
                    </motion.p>

                    {/* Technical details */}
                    <motion.div 
                      className="glass rounded-xl p-4 border border-white/10 bg-white/5"
                      whileHover={{ scale: 1.02 }}
                    >
                      <p className="text-sm text-slate-400 font-medium group-hover:text-slate-300 transition-colors duration-300">
                        {step.detail}
                      </p>
                    </motion.div>

                    {/* Floating particles */}
                    <div className="absolute inset-0 pointer-events-none">
                      {[...Array(3)].map((_, i) => (
                        <motion.div
                          key={i}
                          className="absolute w-1 h-1 bg-primary-400 rounded-full opacity-0 group-hover:opacity-100"
                          style={{
                            left: `${20 + i * 25}%`,
                            top: `${30 + i * 20}%`,
                          }}
                          animate={{
                            y: [-10, -20, -10],
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
                  </div>

                  {/* Connection arrow for large screens */}
                  {index < steps.length - 1 && (
                    <motion.div 
                      className="hidden lg:block absolute -right-4 top-1/2 transform -translate-y-1/2 text-primary-400 z-30"
                      animate={{
                        x: [0, 10, 0],
                        opacity: [0.5, 1, 0.5]
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut"
                      }}
                    >
                      <ArrowRight className="w-8 h-8 drop-shadow-lg" strokeWidth={2} />
                    </motion.div>
                  )}
                </motion.div>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* Revolutionary bottom summary */}
        <motion.div 
          className="mt-20 text-center"
          variants={itemVariants}
        >
          <motion.div 
            className="glass-dark rounded-3xl p-12 max-w-4xl mx-auto shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden"
            whileHover={{ scale: 1.02 }}
          >
            {/* Animated background pattern */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-primary-500/5 via-accent-500/5 to-coral/5"
              animate={{
                backgroundPosition: ['0% 0%', '100% 100%', '0% 0%'],
              }}
              transition={{
                duration: 15,
                repeat: Infinity,
                ease: "linear"
              }}
              style={{
                backgroundSize: '400% 400%'
              }}
            />

            <div className="relative z-10">
              <motion.div
                className="flex items-center justify-center gap-4 mb-6"
                animate={{ scale: [1, 1.05, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                <motion.div
                  className="w-12 h-12 bg-gradient-to-r from-primary-400 to-accent-400 rounded-full flex items-center justify-center"
                  animate={{ rotate: [0, 360] }}
                  transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                >
                  <Sparkles className="w-6 h-6 text-white" />
                </motion.div>
                <motion.h3 
                  className="text-fluid-3xl font-bold text-white"
                  style={{
                    background: 'linear-gradient(135deg, #ffffff 0%, #60a5fa 50%, #d946ef 100%)',
                    backgroundClip: 'text',
                    WebkitBackgroundClip: 'text',
                    WebkitTextFillColor: 'transparent'
                  }}
                >
                  That's It! Simple & Powerful
                </motion.h3>
              </motion.div>
              
              <motion.p 
                className="text-fluid-lg text-slate-300 leading-relaxed font-medium max-w-3xl mx-auto"
                variants={itemVariants}
              >
                From speaking to perfect text in seconds. AutoQuill AI handles the complexity 
                so you can focus on what matters most – your ideas and productivity.
              </motion.p>

              {/* Success indicators */}
              <motion.div 
                className="flex flex-wrap justify-center gap-6 mt-8"
                variants={containerVariants}
              >
                {[
                  { icon: <CheckCircle className="w-5 h-5" />, text: "Zero learning curve" },
                  { icon: <Zap className="w-5 h-5" />, text: "Instant results" },
                  { icon: <Shield className="w-5 h-5" />, text: "Completely private" }
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-2 text-green-400 font-medium"
                    variants={itemVariants}
                    whileHover={{ scale: 1.1 }}
                  >
                    {item.icon}
                    <span>{item.text}</span>
                  </motion.div>
                ))}
              </motion.div>
            </div>
          </motion.div>
        </motion.div>
      </motion.div>
    </section>
  )
} 