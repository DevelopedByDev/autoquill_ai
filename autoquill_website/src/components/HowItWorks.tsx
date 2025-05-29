'use client'

import React, { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Command, Mic, Brain, Target, ArrowRight, Sparkles, Zap, Shield, Globe, CheckCircle, Download } from 'lucide-react'

export default function HowItWorks() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  const steps = [
    {
      icon: Command,
      title: "Press Your Hotkey",
      description: "Hit your custom shortcut from anywhere on macOS to instantly activate voice capture with lightning-fast response.",
      detail: "Customizable shortcuts • Global accessibility • Lightning fast activation",
      color: "text-primary",
      bgColor: "bg-primary/10",
      step: "01"
    },
    {
      icon: Mic,
      title: "Speak Naturally", 
      description: "Talk normally while our advanced AI captures and understands your voice in real-time with perfect accuracy.",
      detail: "Neural networks • Real-time processing • Natural language understanding",
      color: "text-secondary",
      bgColor: "bg-secondary/10",
      step: "02"
    },
    {
      icon: Brain,
      title: "AI Processing",
      description: "Advanced machine learning algorithms transcribe and intelligently correct your speech with enterprise-grade precision.",
      detail: "Smart punctuation • Context awareness • Grammar optimization",
      color: "text-accent",
      bgColor: "bg-accent/10",
      step: "03"
    },
    {
      icon: Target,
      title: "Instant Results",
      description: "Perfectly formatted text appears instantly in your clipboard, ready to paste anywhere with complete accuracy.",
      detail: "Auto-clipboard • Format preservation • Universal compatibility",
      color: "text-primary",
      bgColor: "bg-primary/10",
      step: "04"
    }
  ]

  const features = [
    { 
      icon: Zap, 
      text: "Sub-second response time",
      color: "text-accent"
    },
    { 
      icon: Shield, 
      text: "100% private & offline processing",
      color: "text-secondary"
    },
    { 
      icon: Globe, 
      text: "Works in any application",
      color: "text-primary"
    },
    { 
      icon: CheckCircle, 
      text: "Zero learning curve required",
      color: "text-accent"
    }
  ]

  const handleDownload = () => {
    const link = document.createElement('a')
    link.href = '/AutoQuill-installer.dmg'
    link.download = 'AutoQuill-installer.dmg'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

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
      filter: "blur(10px)"
    },
    visible: { 
      opacity: 1, 
      y: 0,
      filter: "blur(0px)",
      transition: {
        duration: 0.6,
        ease: [0.22, 1, 0.36, 1]
      }
    }
  }

  const stepVariants = {
    hidden: { 
      opacity: 0, 
      y: 50,
      scale: 0.9
    },
    visible: { 
      opacity: 1, 
      y: 0,
      scale: 1,
      transition: {
        duration: 0.8,
        ease: [0.22, 1, 0.36, 1]
      }
    }
  }

  return (
    <section ref={ref} className="py-32 bg-gradient-subtle relative overflow-hidden">
      {/* Subtle background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/3 -left-32 w-96 h-96 bg-primary/5 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-1/3 -right-32 w-80 h-80 bg-secondary/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '2s' }} />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-accent/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '4s' }} />
      </div>

      <motion.div 
        className="max-w-7xl mx-auto px-6 relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Section Header */}
        <motion.div 
          className="text-center mb-20"
          variants={itemVariants}
        >
          <motion.div className="mb-6 flex justify-center">
            <Badge variant="secondary" className="px-4 py-2 text-sm font-medium bg-muted/50 border border-border/50">
              <Sparkles className="w-4 h-4 mr-2" />
              Simple & Powerful
            </Badge>
          </motion.div>

          <h2 className="text-luxury-headline mb-8 text-foreground">
            How It Works
          </h2>
          
          <p className="text-luxury-body text-muted-foreground max-w-4xl mx-auto">
            Four simple steps to transform your voice into perfectly formatted text. Experience the magic of AI-powered transcription that just works.
          </p>
        </motion.div>

        {/* Feature highlights */}
        <motion.div 
          className="grid grid-cols-2 md:grid-cols-4 gap-6 max-w-5xl mx-auto mb-20"
          variants={containerVariants}
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              className="text-center"
            >
              <Card className="glass-card p-6 hover-lift shadow-subtle">
                <motion.div 
                  className={`w-12 h-12 mx-auto mb-4 rounded-xl bg-muted/50 flex items-center justify-center ${feature.color}`}
                  whileHover={{ scale: 1.1, rotate: 5 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <feature.icon className="w-6 h-6" strokeWidth={2} />
                </motion.div>
                <p className="text-sm text-muted-foreground font-medium">
                  {feature.text}
                </p>
              </Card>
            </motion.div>
          ))}
        </motion.div>

        {/* Steps Process */}
        <motion.div 
          className="relative mb-20"
          variants={containerVariants}
        >
          {/* Connecting flow lines for desktop */}
          <div className="hidden lg:block absolute inset-0 pointer-events-none">
            <svg className="w-full h-full" viewBox="0 0 1000 300" preserveAspectRatio="xMidYMid meet">
              <defs>
                <linearGradient id="flowGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#4F5D61" stopOpacity="0.6" />
                  <stop offset="33%" stopColor="#99B3B6" stopOpacity="0.6" />
                  <stop offset="66%" stopColor="#FF6E35" stopOpacity="0.6" />
                  <stop offset="100%" stopColor="#4F5D61" stopOpacity="0.6" />
                </linearGradient>
              </defs>
              
              <motion.path
                d="M 200 150 Q 350 100 500 150 Q 650 200 800 150"
                stroke="url(#flowGradient)"
                strokeWidth="2"
                fill="none"
                initial={{ pathLength: 0, opacity: 0 }}
                animate={isInView ? { pathLength: 1, opacity: 1 } : {}}
                transition={{ duration: 2, ease: "easeInOut", delay: 0.5 }}
                style={{
                  filter: 'drop-shadow(0 0 8px rgba(79, 93, 97, 0.3))'
                }}
              />
            </svg>
          </div>

          {/* Step cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                variants={stepVariants}
                className="relative group"
              >
                {/* Step number badge */}
                <motion.div
                  className="absolute -top-4 -right-4 w-12 h-12 bg-gradient-luxury text-white rounded-2xl flex items-center justify-center text-sm font-bold shadow-elegant z-20"
                  whileHover={{ 
                    scale: 1.2,
                    rotate: 360,
                    transition: { duration: 0.6 }
                  }}
                  animate={{
                    boxShadow: [
                      "0 0 20px rgba(79, 93, 97, 0.3)",
                      "0 0 40px rgba(153, 179, 182, 0.3)",
                      "0 0 20px rgba(79, 93, 97, 0.3)"
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

                {/* Main card */}
                <Card className="glass-card p-8 h-full shadow-subtle hover-lift relative overflow-hidden">
                  {/* Animated background glow */}
                  <motion.div
                    className={`absolute inset-0 ${step.bgColor} rounded-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
                    animate={{
                      scale: [1, 1.05, 1],
                      opacity: [0.05, 0.15, 0.05]
                    }}
                    transition={{
                      duration: 4,
                      repeat: Infinity,
                      ease: "easeInOut",
                      delay: index * 0.5
                    }}
                  />

                  <div className="relative z-10">
                    {/* Icon */}
                    <motion.div 
                      className={`w-16 h-16 ${step.bgColor} rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-subtle ${step.color}`}
                      whileHover={{ 
                        scale: 1.1,
                        rotate: [0, -5, 5, 0],
                        transition: { duration: 0.6 }
                      }}
                      animate={{
                        y: [0, -3, 0]
                      }}
                      transition={{
                        duration: 3,
                        repeat: Infinity,
                        ease: "easeInOut",
                        delay: index * 0.2
                      }}
                    >
                      <step.icon className="w-8 h-8" strokeWidth={2} />
                    </motion.div>

                    {/* Content */}
                    <h3 className="text-xl font-semibold text-foreground mb-4 group-hover:text-primary transition-colors duration-300">
                      {step.title}
                    </h3>
                    
                    <p className="text-muted-foreground mb-6 leading-relaxed">
                      {step.description}
                    </p>

                    {/* Technical details */}
                    <Card className="glass-card p-4 bg-muted/30">
                      <p className="text-sm text-muted-foreground font-medium">
                        {step.detail}
                      </p>
                    </Card>

                    {/* Connection arrow for large screens */}
                    {index < steps.length - 1 && (
                      <motion.div 
                        className="hidden lg:block absolute -right-4 top-1/2 transform -translate-y-1/2 text-primary/60 z-30"
                        animate={{
                          x: [0, 8, 0],
                          opacity: [0.6, 1, 0.6]
                        }}
                        transition={{
                          duration: 2,
                          repeat: Infinity,
                          ease: "easeInOut"
                        }}
                      >
                        <ArrowRight className="w-6 h-6" strokeWidth={2} />
                      </motion.div>
                    )}
                  </div>
                </Card>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* Bottom summary */}
        <motion.div 
          className="text-center"
          variants={itemVariants}
        >
          <Card className="glass-card p-12 max-w-4xl mx-auto shadow-luxury relative overflow-hidden group">
            {/* Animated background pattern */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-primary/5 via-secondary/5 to-accent/5"
              animate={{
                backgroundPosition: ['0% 50%', '100% 50%', '0% 50%'],
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
                animate={{ scale: [1, 1.02, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                <motion.div
                  className="w-12 h-12 bg-gradient-luxury rounded-2xl flex items-center justify-center"
                  animate={{ rotate: [0, 360] }}
                  transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                >
                  <Sparkles className="w-6 h-6 text-white" />
                </motion.div>
                <h3 className="text-luxury-title text-foreground">
                  That's It! Simple & Powerful
                </h3>
              </motion.div>
              
              <p className="text-luxury-body text-muted-foreground mb-10 max-w-3xl mx-auto">
                From speaking to perfect text in seconds. AutoQuill AI handles the complexity 
                so you can focus on what matters most – your ideas and productivity.
              </p>

              {/* CTA Button */}
              <Button
                size="lg"
                onClick={handleDownload}
                className="gradient-luxury text-white px-10 py-6 text-lg font-semibold shadow-luxury hover:shadow-elegant transition-all duration-300 group min-w-[300px]"
              >
                <Download className="w-5 h-5 mr-3 group-hover:scale-110 transition-transform" />
                Try It Now - Free Forever
                <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
              </Button>

              {/* Success indicators */}
              <motion.div 
                className="flex flex-wrap justify-center gap-6 mt-8"
                variants={containerVariants}
              >
                {[
                  { icon: CheckCircle, text: "Zero learning curve" },
                  { icon: Zap, text: "Instant results" },
                  { icon: Shield, text: "Completely private" }
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-2 text-secondary font-medium"
                    variants={itemVariants}
                    whileHover={{ scale: 1.05 }}
                  >
                    <item.icon className="w-4 h-4" />
                    <span className="text-sm">{item.text}</span>
                  </motion.div>
                ))}
              </motion.div>
            </div>
          </Card>
        </motion.div>
      </motion.div>
    </section>
  )
} 