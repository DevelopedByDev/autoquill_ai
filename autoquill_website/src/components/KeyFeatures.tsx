'use client'

import { motion, useInView } from 'framer-motion'
import { useRef } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Zap, Clipboard, Settings, Keyboard, Shield, Code2, Download, ArrowRight, Sparkles } from 'lucide-react'

export default function KeyFeatures() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  const features = [
    {
      icon: Zap,
      title: "Lightning Fast",
      description: "Real-time transcription with sub-second response times. Your thoughts become text instantly with enterprise-grade performance.",
      highlight: "< 500ms",
      color: "text-accent",
      bgColor: "bg-accent/10"
    },
    {
      icon: Clipboard,
      title: "Smart Clipboard",
      description: "Automatically copies transcribed text to your clipboard with intelligent formatting and context preservation.",
      highlight: "Auto-copy",
      color: "text-accent",
      bgColor: "bg-accent/10"
    },
    {
      icon: Settings,
      title: "AI Assistant",
      description: "Get smart completions, grammar corrections, and style suggestions powered by advanced language models.",
      highlight: "AI-powered",
      color: "text-accent",
      bgColor: "bg-accent/10"
    },
    {
      icon: Keyboard,
      title: "Custom Hotkeys",
      description: "Configure personalized keyboard shortcuts that seamlessly integrate with your existing workflow and tools.",
      highlight: "Customizable",
      color: "text-accent",
      bgColor: "bg-accent/10"
    },
    {
      icon: Shield,
      title: "Privacy First",
      description: "All processing happens locally on your Mac. Your voice data never leaves your device, ensuring complete privacy.",
      highlight: "100% Private",
      color: "text-accent",
      bgColor: "bg-accent/10"
    },
    {
      icon: Code2,
      title: "Open Source",
      description: "Completely transparent and open source under MIT license. Inspect, modify, and contribute to the codebase.",
      highlight: "MIT License",
      color: "text-accent",
      bgColor: "bg-accent/10"
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

  return (
    <section ref={ref} className="py-32 bg-gradient-subtle relative overflow-hidden">
      {/* Subtle background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 -left-32 w-96 h-96 bg-secondary/5 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-1/4 -right-32 w-80 h-80 bg-accent/5 rounded-full blur-3xl animate-float" style={{ animationDelay: '3s' }} />
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
              World-Class Features
            </Badge>
          </motion.div>
          
          <h2 className="text-luxury-headline mb-8 text-foreground">
            Perfect for Every Workflow
          </h2>
          
          <p className="text-luxury-body text-muted-foreground max-w-4xl mx-auto">
            A complete voice-to-text solution designed for professionals who value speed, privacy, and reliability. 
            Experience the future of productivity with AI-powered precision.
          </p>
        </motion.div>

        {/* Features Grid */}
        <motion.div 
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 mb-20"
          variants={containerVariants}
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              className="group"
            >
              <Card className="glass-card p-8 h-full shadow-subtle hover-lift">
                {/* Feature Header */}
                <div className="flex items-start justify-between mb-6">
                  <motion.div 
                    className={`w-16 h-16 rounded-2xl ${feature.bgColor} flex items-center justify-center ${feature.color} shadow-subtle`}
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    transition={{ type: "spring", stiffness: 300 }}
                  >
                    <feature.icon className="w-8 h-8" strokeWidth={2} />
                  </motion.div>
                  <Badge variant="outline" className="text-xs font-semibold border-border/30">
                    {feature.highlight}
                  </Badge>
                </div>

                {/* Feature Content */}
                <h3 className="text-xl font-semibold text-foreground mb-4 group-hover:text-primary transition-colors duration-300">
                  {feature.title}
                </h3>
                <p className="text-muted-foreground leading-relaxed">
                  {feature.description}
                </p>
              </Card>
            </motion.div>
          ))}
        </motion.div>

        {/* CTA Section */}
        <motion.div
          variants={itemVariants}
          className="text-center"
        >
          <Card className="glass-card p-12 shadow-luxury relative overflow-hidden group">
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
            
            <div className="relative z-10">
              <motion.h3 
                className="text-luxury-title text-foreground mb-6"
                animate={{ scale: [1, 1.02, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
              >
                Ready to Transform Your Workflow?
              </motion.h3>
              
              <p className="text-luxury-body text-muted-foreground mb-10 max-w-3xl mx-auto">
                Join thousands of professionals who've already made the switch to voice-first productivity. 
                Experience the difference that award-winning design makes.
              </p>
              
              <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                <Button
                  size="lg"
                  onClick={handleDownload}
                  className="gradient-luxury text-white px-10 py-6 text-lg font-semibold shadow-luxury hover:shadow-elegant transition-all duration-300 group min-w-[300px]"
                >
                  <Download className="w-5 h-5 mr-3 group-hover:scale-110 transition-transform" />
                  Download for Free
                  <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                </Button>
                
                <p className="text-sm text-muted-foreground font-medium">
                  No account required • Forever free • Open source
                </p>
              </div>
            </div>
          </Card>
        </motion.div>
      </motion.div>
    </section>
  )
} 