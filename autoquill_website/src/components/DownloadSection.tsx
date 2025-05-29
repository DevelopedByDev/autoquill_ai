'use client'

import React, { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Download, Github, Sparkles, CheckCircle, Zap, Crown } from 'lucide-react'

export default function DownloadSection() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  const handleDownload = () => {
    const link = document.createElement('a')
    link.href = '/AutoQuill-installer.dmg'
    link.download = 'AutoQuill-installer.dmg'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  const handleViewSource = () => {
    window.open('https://github.com/DevelopedByDev/autoquill_ai', '_blank')
  }

  const features = [
    { text: "Real-time voice transcription", icon: Zap },
    { text: "Smart clipboard integration", icon: CheckCircle }, 
    { text: "Custom keyboard shortcuts", icon: Sparkles },
    { text: "AI-powered corrections", icon: Sparkles },
    { text: "Complete privacy protection", icon: CheckCircle }
  ]

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

  return (
    <section ref={ref} className="py-32 bg-background relative overflow-hidden">
      {/* Subtle background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-accent/5 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-secondary/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '3s' }} />
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
              <Crown className="w-4 h-4 mr-2" />
              Ready to Get Started?
            </Badge>
          </motion.div>

          <h2 className="text-luxury-headline mb-8 text-foreground">
            Ready to Transform Your Workflow?
          </h2>
          
          <p className="text-luxury-body text-muted-foreground max-w-4xl mx-auto">
            Join thousands using AutoQuill AI to work faster, smarter, and more efficiently than ever before. 
            Experience the future of voice-to-text technology today.
          </p>
        </motion.div>

        {/* Main Download Card */}
        <motion.div
          variants={itemVariants}
          className="mb-16"
        >
          <Card className="glass-card p-12 shadow-luxury relative overflow-hidden">
            {/* Animated background pattern */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-primary/5 via-secondary/5 to-accent/5"
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
            
            <div className="relative z-10 grid md:grid-cols-2 gap-12 items-center">
              {/* Features List */}
              <motion.div variants={itemVariants}>
                <motion.h3 
                  className="text-luxury-title text-foreground mb-8 flex items-center gap-3"
                  whileHover={{ scale: 1.02 }}
                >
                  <motion.div
                    className="w-8 h-8 bg-gradient-luxury rounded-xl flex items-center justify-center"
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
                      whileHover={{ x: 8, transition: { duration: 0.2 } }}
                    >
                      <motion.div 
                        className="w-8 h-8 bg-gradient-luxury rounded-xl flex items-center justify-center shadow-subtle"
                        whileHover={{ 
                          scale: 1.1,
                          rotate: 180,
                          transition: { duration: 0.3 }
                        }}
                      >
                        <CheckCircle className="w-4 h-4 text-white" strokeWidth={2} />
                      </motion.div>
                      <div className="flex items-center gap-2">
                        <feature.icon className="w-4 h-4 text-primary" />
                        <span className="text-muted-foreground font-medium group-hover:text-foreground transition-colors duration-300">
                          {feature.text}
                        </span>
                      </div>
                    </motion.div>
                  ))}
                </div>
                
                {/* Guarantee badge */}
                <Card className="glass-card p-4 bg-muted/30">
                  <p className="font-semibold text-center text-foreground">
                    ✓ Forever Free • ✓ No Registration • ✓ Open Source • ✓ Privacy First
                  </p>
                </Card>
              </motion.div>

              {/* Download Section */}
              <motion.div 
                className="text-center"
                variants={itemVariants}
              >
                {/* Pricing display */}
                <motion.div 
                  className="mb-8 p-8 glass-card rounded-3xl relative overflow-hidden"
                  whileHover={{ scale: 1.02 }}
                  initial={{ opacity: 0, y: 30 }}
                  animate={isInView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.6, delay: 0.8 }}
                >
                  {/* Animated background glow */}
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-r from-primary/10 to-secondary/10 rounded-3xl"
                    animate={{
                      scale: [1, 1.05, 1],
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
                      className="text-6xl font-bold text-foreground mb-2"
                      animate={{ scale: [1, 1.02, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    >
                      Free
                    </motion.div>
                    <div className="text-muted-foreground font-medium text-lg">Forever & Always</div>
                  </div>
                </motion.div>

                {/* Download Button */}
                <Button
                  size="lg"
                  onClick={handleDownload}
                  className="w-full gradient-luxury text-white py-6 px-8 text-xl font-semibold shadow-luxury hover:shadow-elegant transition-all duration-300 group mb-6"
                >
                  <Download className="w-6 h-6 mr-3 group-hover:scale-110 group-hover:-translate-y-1 transition-all duration-300" />
                  Download for macOS
                  <motion.div
                    className="ml-2"
                    animate={{ rotate: [0, 360] }}
                    transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles className="w-5 h-5" />
                  </motion.div>
                </Button>

                {/* Version info */}
                <motion.div 
                  className="text-sm text-muted-foreground mb-6 space-y-2"
                  initial={{ opacity: 0 }}
                  animate={isInView ? { opacity: 1 } : {}}
                  transition={{ duration: 0.6, delay: 1.2 }}
                >
                  <p className="font-semibold flex items-center justify-center gap-2">
                    <motion.div
                      className="w-2 h-2 bg-secondary rounded-full"
                      animate={{ scale: [1, 1.5, 1], opacity: [1, 0.5, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    />
                    Version 2.1.0 • 15 MB • macOS Monterey+
                  </p>
                  <p>Intel & Apple Silicon Compatible</p>
                </motion.div>

                {/* Source code link */}
                <Button
                  variant="outline"
                  onClick={handleViewSource}
                  className="w-full hover-lift"
                >
                  <Github className="w-5 h-5 mr-2" />
                  View Source Code on GitHub
                  <motion.div
                    className="w-2 h-2 bg-primary rounded-full ml-2"
                    animate={{ scale: [1, 1.5, 1] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  />
                </Button>
              </motion.div>
            </div>
          </Card>
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          variants={itemVariants}
          className="text-center"
        >
          <Card className="glass-card p-12 shadow-luxury relative overflow-hidden group">
            {/* Animated background pattern */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-accent/5 via-primary/5 to-secondary/5"
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
                className="text-luxury-title text-foreground mb-6"
                animate={{ scale: [1, 1.02, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                Experience the Future of Text Creation
              </motion.h3>
              
              <p className="text-luxury-body text-muted-foreground mb-8 max-w-3xl mx-auto">
                Join the voice-first revolution. Your most productive workflow awaits with cutting-edge AI technology and elegant design.
              </p>
              
              <Button
                size="lg"
                onClick={handleDownload}
                className="gradient-luxury text-white px-10 py-5 text-lg font-semibold shadow-luxury hover:shadow-elegant transition-all duration-300 group min-w-[280px]"
              >
                <span className="flex items-center">
                  Get Started Now
                  <motion.div
                    className="ml-2"
                    animate={{ rotate: [0, 360] }}
                    transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles className="w-5 h-5" />
                  </motion.div>
                </span>
              </Button>
            </div>
          </Card>
        </motion.div>
      </motion.div>
    </section>
  )
} 