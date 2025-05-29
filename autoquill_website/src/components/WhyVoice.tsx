'use client'

import React from 'react'
import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { 
  Zap, Shield, Cpu, Globe, Clock, Brain, Target, Rocket, 
  TrendingUp, Users, Award, Heart, Sparkles, CheckCircle, 
  ArrowRight, Star, Trophy, Lightbulb, Workflow, Gauge
} from 'lucide-react'

export default function WhyVoice() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: "-100px" })

  const benefits = [
    {
      icon: <Zap className="w-8 h-8" strokeWidth={2} />,
      title: "Lightning Fast",
      description: "10x faster than typing with real-time transcription that keeps up with your thoughts",
      detail: "Average 150 WPM vs 40 WPM typing",
      color: "from-yellow-400 to-orange-500",
      bgGlow: "from-yellow-500/20 to-orange-500/20",
      metric: "10x",
      stat: "Faster"
    },
    {
      icon: <Brain className="w-8 h-8" strokeWidth={2} />,
      title: "Enhanced Focus",
      description: "Stay in your creative flow without breaking concentration to look at the keyboard",
      detail: "Maintain natural thought patterns",
      color: "from-purple-400 to-pink-500",
      bgGlow: "from-purple-500/20 to-pink-500/20",
      metric: "100%",
      stat: "Natural"
    },
    {
      icon: <Target className="w-8 h-8" strokeWidth={2} />,
      title: "Perfect Accuracy",
      description: "AI-powered correction ensures your voice becomes flawless, professional text",
      detail: "Context-aware grammar optimization",
      color: "from-green-400 to-emerald-500",
      bgGlow: "from-green-500/20 to-emerald-500/20",
      metric: "99%",
      stat: "Accurate"
    },
    {
      icon: <Shield className="w-8 h-8" strokeWidth={2} />,
      title: "Completely Private",
      description: "Everything processed locally on your device. Zero data sent to external servers",
      detail: "Your voice never leaves your Mac",
      color: "from-blue-400 to-blue-600",
      bgGlow: "from-blue-500/20 to-blue-600/20",
      metric: "0%",
      stat: "Tracking"
    },
    {
      icon: <Rocket className="w-8 h-8" strokeWidth={2} />,
      title: "Instant Results",
      description: "Sub-second processing with immediate text output to your clipboard",
      detail: "Real-time voice-to-text conversion",
      color: "from-indigo-400 to-purple-600",
      bgGlow: "from-indigo-500/20 to-purple-600/20",
      metric: "<500ms",
      stat: "Response"
    },
    {
      icon: <Globe className="w-8 h-8" strokeWidth={2} />,
      title: "Universal Compatibility",
      description: "Works seamlessly across all macOS applications and workflows",
      detail: "System-wide integration",
      color: "from-cyan-400 to-teal-500",
      bgGlow: "from-cyan-500/20 to-teal-500/20",
      metric: "Any",
      stat: "App"
    }
  ]

  const stats = [
    {
      icon: <Users className="w-6 h-6" />,
      value: "15,000+",
      label: "Happy Users",
      description: "Professionals worldwide trust AutoQuill AI"
    },
    {
      icon: <TrendingUp className="w-6 h-6" />,
      value: "300%",
      label: "Productivity Boost",
      description: "Average improvement in content creation speed"
    },
    {
      icon: <Award className="w-6 h-6" />,
      value: "4.9/5",
      label: "User Rating",
      description: "Consistently rated as essential productivity tool"
    },
    {
      icon: <Heart className="w-6 h-6" />,
      value: "98%",
      label: "Would Recommend", 
      description: "Users recommend AutoQuill AI to colleagues"
    }
  ]

  const useCases = [
    {
      icon: <Lightbulb className="w-6 h-6" />,
      title: "Content Creation",
      items: ["Blog posts", "Articles", "Documentation", "Social media"]
    },
    {
      icon: <Workflow className="w-6 h-6" />,
      title: "Professional Work",
      items: ["Emails", "Reports", "Meeting notes", "Presentations"]
    },
    {
      icon: <Gauge className="w-6 h-6" />,
      title: "Quick Tasks",
      items: ["To-do lists", "Reminders", "Quick notes", "Brainstorming"]
    }
  ]

  // Advanced animation variants
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.12,
        delayChildren: 0.2
      }
    }
  }

  const cardVariants = {
    hidden: { 
      opacity: 0, 
      y: 60,
      scale: 0.9,
      rotateX: -15
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

  const numberVariants = {
    hidden: { scale: 0, rotate: -180 },
    visible: { 
      scale: 1, 
      rotate: 0,
      transition: {
        type: "spring",
        stiffness: 260,
        damping: 20,
        duration: 0.8
      }
    }
  }

  return (
    <section ref={ref} className="py-32 bg-slate-900 relative overflow-hidden">
      {/* Revolutionary animated background */}
      <div className="absolute inset-0 overflow-hidden opacity-30">
        <motion.div 
          className="absolute top-1/4 left-0 w-96 h-96 bg-gradient-to-r from-primary-500/20 to-accent-500/20 rounded-full blur-3xl"
          animate={{ 
            x: [0, 150, 0], 
            y: [0, -100, 0],
            scale: [1, 1.5, 1],
            rotate: [0, 180, 360]
          }}
          transition={{ 
            duration: 40, 
            repeat: Infinity, 
            ease: "easeInOut" 
          }}
        />
        <motion.div 
          className="absolute bottom-1/4 right-0 w-80 h-80 bg-gradient-to-r from-accent-500/20 to-coral/20 rounded-full blur-3xl"
          animate={{ 
            x: [0, -120, 0], 
            y: [0, 80, 0],
            scale: [1, 0.6, 1],
            rotate: [360, 180, 0]
          }}
          transition={{ 
            duration: 35, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 8
          }}
        />
        <motion.div 
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-gradient-to-r from-coral/15 to-primary-500/15 rounded-full blur-3xl"
          animate={{ 
            scale: [1, 1.8, 1],
            rotate: [0, 360],
            opacity: [0.1, 0.3, 0.1]
          }}
          transition={{ 
            duration: 25, 
            repeat: Infinity, 
            ease: "easeInOut",
            delay: 15
          }}
        />
        
        {/* Advanced mesh pattern */}
        <div className="absolute inset-0 bg-mesh-gradient opacity-[0.02]"></div>
      </div>

      <motion.div 
        className="max-w-7xl mx-auto px-6 relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Revolutionary header */}
        <motion.div 
          className="text-center mb-20"
          variants={itemVariants}
        >
          <motion.h2 
            className="text-fluid-6xl font-display font-bold text-white mb-8 leading-tight"
            style={{
              background: 'linear-gradient(135deg, #ffffff 0%, #3b82f6 25%, #d946ef 50%, #ff6b35 75%, #ffffff 100%)',
              backgroundClip: 'text',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textShadow: '0 4px 30px rgba(0,0,0,0.3)'
            }}
          >
            Why Voice Is The Future
          </motion.h2>
          <motion.p 
            className="text-fluid-xl text-slate-300 max-w-4xl mx-auto leading-relaxed font-medium mb-12"
            variants={itemVariants}
          >
            Transform how you create content. Voice input isn't just faster – it's more natural, 
            more intuitive, and unlocks creativity in ways typing never could.
          </motion.p>

          {/* Statistics showcase */}
          <motion.div 
            className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-5xl mx-auto mb-16"
            variants={containerVariants}
          >
            {stats.map((stat, index) => (
              <motion.div
                key={index}
                className="glass-dark rounded-2xl p-6 text-center shadow-medium border border-white/10 backdrop-blur-xl group hover:border-white/20 transition-all duration-500"
                variants={cardVariants}
                whileHover={{ 
                  y: -8,
                  scale: 1.02,
                  transition: { duration: 0.3 }
                }}
              >
                <motion.div
                  className="text-primary-400 mb-3 flex justify-center"
                  variants={numberVariants}
                >
                  {stat.icon}
                </motion.div>
                <motion.div 
                  className="text-3xl font-bold text-white mb-2"
                  variants={numberVariants}
                >
                  {stat.value}
                </motion.div>
                <div className="text-sm font-medium text-slate-300 mb-2 group-hover:text-white transition-colors duration-300">
                  {stat.label}
                </div>
                <div className="text-xs text-slate-400 group-hover:text-slate-300 transition-colors duration-300">
                  {stat.description}
                </div>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* Revolutionary benefits grid */}
        <motion.div 
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-20"
          variants={containerVariants}
        >
          {benefits.map((benefit, index) => (
            <motion.div
              key={index}
              className="group relative perspective-1000"
              variants={cardVariants}
            >
              {/* Floating metric badge */}
              <motion.div
                className="absolute -top-4 -right-4 glass-dark border border-white/20 rounded-2xl px-4 py-2 z-20 backdrop-blur-xl"
                whileHover={{ 
                  scale: 1.1,
                  rotate: [0, -5, 5, 0],
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
                <div className="text-white font-bold text-sm">
                  {benefit.metric}
                </div>
                <div className="text-slate-400 text-xs">
                  {benefit.stat}
                </div>
              </motion.div>

              {/* Main benefit card */}
              <motion.div 
                className="glass-dark rounded-3xl p-8 h-full shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden preserve-3d group-hover:border-white/20 transition-all duration-500"
                whileHover={{ 
                  rotateY: 3,
                  rotateX: 3,
                  scale: 1.02,
                  transition: { duration: 0.3 }
                }}
              >
                {/* Animated background glow */}
                <motion.div
                  className={`absolute inset-0 bg-gradient-to-r ${benefit.bgGlow} rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
                  animate={{
                    scale: [1, 1.1, 1],
                    opacity: [0.1, 0.3, 0.1]
                  }}
                  transition={{
                    duration: 4,
                    repeat: Infinity,
                    ease: "easeInOut",
                    delay: index * 0.3
                  }}
                />

                <div className="relative z-10">
                  {/* Enhanced icon */}
                  <motion.div 
                    className={`w-16 h-16 bg-gradient-to-r ${benefit.color} rounded-2xl flex items-center justify-center mb-6 shadow-lg group-hover:shadow-2xl transition-all duration-500`}
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
                      delay: index * 0.1
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
                      {benefit.icon}
                    </motion.div>
                  </motion.div>

                  {/* Content */}
                  <motion.h3 
                    className="text-2xl font-bold text-white mb-4 group-hover:text-gradient transition-all duration-300"
                    whileHover={{ scale: 1.02 }}
                  >
                    {benefit.title}
                  </motion.h3>
                  
                  <motion.p 
                    className="text-slate-300 mb-4 leading-relaxed font-medium group-hover:text-slate-200 transition-colors duration-300"
                    variants={itemVariants}
                  >
                    {benefit.description}
                  </motion.p>

                  {/* Technical detail */}
                  <motion.div 
                    className="glass rounded-xl p-3 border border-white/10 bg-white/5"
                    whileHover={{ scale: 1.02 }}
                  >
                    <p className="text-sm text-slate-400 font-medium group-hover:text-slate-300 transition-colors duration-300">
                      {benefit.detail}
                    </p>
                  </motion.div>

                  {/* Floating particles */}
                  <div className="absolute inset-0 pointer-events-none">
                    {[...Array(4)].map((_, i) => (
                      <motion.div
                        key={i}
                        className="absolute w-1 h-1 bg-primary-400 rounded-full opacity-0 group-hover:opacity-100"
                        style={{
                          left: `${15 + i * 20}%`,
                          top: `${25 + i * 15}%`,
                        }}
                        animate={{
                          y: [-8, -18, -8],
                          opacity: [0, 1, 0]
                        }}
                        transition={{
                          duration: 2,
                          delay: i * 0.2,
                          repeat: Infinity,
                          ease: "easeInOut"
                        }}
                      />
                    ))}
                  </div>
                </div>
              </motion.div>
            </motion.div>
          ))}
        </motion.div>

        {/* Revolutionary use cases section */}
        <motion.div 
          className="glass-dark rounded-3xl p-12 shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden mb-20"
          variants={itemVariants}
          whileHover={{ scale: 1.01 }}
        >
          {/* Animated background pattern */}
          <motion.div
            className="absolute inset-0 bg-gradient-to-r from-primary-500/5 via-accent-500/5 to-coral/5"
            animate={{
              backgroundPosition: ['0% 0%', '100% 100%', '0% 0%'],
            }}
            transition={{
              duration: 20,
              repeat: Infinity,
              ease: "linear"
            }}
            style={{
              backgroundSize: '300% 300%'
            }}
          />

          <div className="relative z-10">
            <motion.div className="text-center mb-12" variants={itemVariants}>
              <motion.h3 
                className="text-fluid-4xl font-bold text-white mb-6"
                style={{
                  background: 'linear-gradient(135deg, #ffffff 0%, #60a5fa 50%, #d946ef 100%)',
                  backgroundClip: 'text',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent'
                }}
              >
                Perfect For Every Workflow
              </motion.h3>
              <motion.p 
                className="text-fluid-lg text-slate-300 max-w-3xl mx-auto leading-relaxed font-medium"
                variants={itemVariants}
              >
                Whether you're creating content, handling professional tasks, or managing daily activities,
                voice input revolutionizes how you work.
              </motion.p>
            </motion.div>

            <motion.div 
              className="grid grid-cols-1 md:grid-cols-3 gap-8"
              variants={containerVariants}
            >
              {useCases.map((useCase, index) => (
                <motion.div
                  key={index}
                  className="glass rounded-2xl p-6 border border-white/10 backdrop-blur-xl group hover:border-white/20 transition-all duration-500"
                  variants={cardVariants}
                  whileHover={{ 
                    y: -5,
                    scale: 1.02,
                    transition: { duration: 0.3 }
                  }}
                >
                  <motion.div
                    className="text-primary-400 mb-4 flex justify-center"
                    animate={{ rotate: [0, 360] }}
                    transition={{ 
                      duration: 15, 
                      repeat: Infinity, 
                      ease: "linear" 
                    }}
                  >
                    {useCase.icon}
                  </motion.div>
                  <h4 className="text-xl font-bold text-white mb-4 text-center group-hover:text-gradient transition-all duration-300">
                    {useCase.title}
                  </h4>
                  <div className="space-y-2">
                    {useCase.items.map((item, itemIndex) => (
                      <motion.div
                        key={itemIndex}
                        className="flex items-center gap-3 text-slate-300 group-hover:text-slate-200 transition-colors duration-300"
                        initial={{ opacity: 0, x: -20 }}
                        animate={isInView ? { opacity: 1, x: 0 } : {}}
                        transition={{ 
                          duration: 0.6, 
                          delay: 0.8 + index * 0.2 + itemIndex * 0.1 
                        }}
                        whileHover={{ x: 5 }}
                      >
                        <motion.div
                          className="w-2 h-2 bg-primary-400 rounded-full flex-shrink-0"
                          animate={{ scale: [1, 1.3, 1] }}
                          transition={{ 
                            duration: 2, 
                            repeat: Infinity,
                            delay: itemIndex * 0.2
                          }}
                        />
                        <span className="font-medium">{item}</span>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              ))}
            </motion.div>
          </div>
        </motion.div>

        {/* Revolutionary final CTA */}
        <motion.div 
          className="text-center"
          variants={itemVariants}
        >
          <motion.div 
            className="glass-dark rounded-3xl p-12 max-w-4xl mx-auto shadow-premium border border-white/10 backdrop-blur-xl relative overflow-hidden"
            whileHover={{ scale: 1.02 }}
          >
            {/* Advanced animated background */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-primary-500/10 via-accent-500/10 to-coral/10"
              animate={{
                backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
              }}
              transition={{
                duration: 8,
                repeat: Infinity,
                ease: "linear"
              }}
              style={{
                backgroundSize: '200% 200%'
              }}
            />

            <div className="relative z-10">
              <motion.div
                className="flex items-center justify-center gap-4 mb-8"
                animate={{ scale: [1, 1.02, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                <motion.div
                  className="w-16 h-16 bg-gradient-to-r from-primary-400 to-accent-400 rounded-full flex items-center justify-center"
                  animate={{ rotate: [0, 360] }}
                  transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                >
                  <Trophy className="w-8 h-8 text-white" />
                </motion.div>
                <motion.h3 
                  className="text-fluid-4xl font-bold text-white"
                  style={{
                    background: 'linear-gradient(135deg, #ffffff 0%, #60a5fa 50%, #d946ef 100%)',
                    backgroundClip: 'text',
                    WebkitBackgroundClip: 'text',
                    WebkitTextFillColor: 'transparent'
                  }}
                >
                  Join The Voice Revolution
                </motion.h3>
              </motion.div>
              
              <motion.p 
                className="text-fluid-lg text-slate-300 leading-relaxed font-medium max-w-3xl mx-auto mb-8"
                variants={itemVariants}
              >
                Stop limiting yourself to the speed of your fingers. Unlock the power of your voice 
                and experience productivity like never before.
              </motion.p>

              {/* Enhanced guarantee indicators */}
              <motion.div 
                className="flex flex-wrap justify-center gap-8 mb-8"
                variants={containerVariants}
              >
                {[
                  { icon: <CheckCircle className="w-5 h-5" />, text: "Free Forever", color: "text-green-400" },
                  { icon: <Shield className="w-5 h-5" />, text: "100% Private", color: "text-blue-400" },
                  { icon: <Star className="w-5 h-5" />, text: "Open Source", color: "text-yellow-400" },
                  { icon: <Zap className="w-5 h-5" />, text: "Instant Setup", color: "text-purple-400" }
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className={`flex items-center gap-2 ${item.color} font-bold`}
                    variants={itemVariants}
                    whileHover={{ scale: 1.1, y: -2 }}
                  >
                    {item.icon}
                    <span>{item.text}</span>
                  </motion.div>
                ))}
              </motion.div>

              <motion.p 
                className="text-slate-400 text-lg font-medium"
                variants={itemVariants}
              >
                Ready to transform how you create? Your voice is waiting.
              </motion.p>
            </div>
          </motion.div>
        </motion.div>
      </motion.div>
    </section>
  )
} 