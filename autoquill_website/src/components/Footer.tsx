'use client'

import React, { useRef } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { motion, useInView } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Github, Twitter, Mail, ExternalLink, Heart, Sparkles, Globe, Shield, Download, ArrowUp } from 'lucide-react'

export default function Footer() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, amount: 0.2 })

  const quickLinks = [
    { name: 'Features', href: '#features' },
    { name: 'How It Works', href: '#how-it-works' },
    { name: 'Download', href: '#download' },
    { name: 'GitHub', href: 'https://github.com/DevelopedByDev/autoquill_ai', external: true }
  ]

  const resources = [
    { name: 'Documentation', href: 'https://github.com/DevelopedByDev/autoquill_ai/wiki', external: true },
    { name: 'Release Notes', href: 'https://github.com/DevelopedByDev/autoquill_ai/releases', external: true },
    { name: 'Contributing', href: 'https://github.com/DevelopedByDev/autoquill_ai/blob/main/CONTRIBUTING.md', external: true },
    { name: 'License', href: 'https://github.com/DevelopedByDev/autoquill_ai/blob/main/LICENSE', external: true }
  ]

  const socialLinks = [
    { 
      name: 'GitHub', 
      href: 'https://github.com/DevelopedByDev/autoquill_ai', 
      icon: Github,
      color: 'text-primary',
      bgColor: 'bg-primary/10'
    },
    { 
      name: 'Twitter', 
      href: 'https://twitter.com/autoquill_ai', 
      icon: Twitter,
      color: 'text-secondary',
      bgColor: 'bg-secondary/10'
    },
    { 
      name: 'Email', 
      href: 'mailto:hello@autoquill.ai', 
      icon: Mail,
      color: 'text-accent',
      bgColor: 'bg-accent/10'
    }
  ]

  const features = [
    { icon: Shield, text: '100% Private & Secure', color: 'text-secondary' },
    { icon: Globe, text: 'Open Source & Free', color: 'text-primary' },
    { icon: Sparkles, text: 'AI-Powered Precision', color: 'text-accent' }
  ]

  const handleDownload = () => {
    const link = document.createElement('a')
    link.href = '/AutoQuill-installer.dmg'
    link.download = 'AutoQuill-installer.dmg'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
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
    <footer ref={ref} className="bg-gradient-subtle border-t border-border/50 relative overflow-hidden">
      {/* Subtle background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/3 rounded-full blur-3xl animate-float" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-accent/3 rounded-full blur-3xl animate-float" style={{ animationDelay: '3s' }} />
      </div>

      <motion.div 
        className="relative z-10"
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        {/* Newsletter/CTA Section */}
        <motion.div 
          className="border-b border-border/30 py-16"
          variants={itemVariants}
        >
          <div className="max-w-7xl mx-auto px-6">
            <Card className="glass-card p-12 shadow-luxury relative overflow-hidden">
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
                  backgroundSize: '300% 300%'
                }}
              />
              
              <div className="relative z-10 text-center">
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
                    Ready to Start Speaking?
                  </h3>
                </motion.div>
                
                <p className="text-luxury-body text-muted-foreground mb-8 max-w-3xl mx-auto">
                  Join the growing community of professionals who have revolutionized their workflow with AutoQuill AI.
                </p>
                
                <Button
                  size="lg"
                  onClick={handleDownload}
                  className="gradient-luxury text-white px-10 py-5 text-lg font-semibold shadow-luxury hover:shadow-elegant transition-all duration-300 group"
                >
                  <Download className="w-5 h-5 mr-3 group-hover:scale-110 transition-transform" />
                  Download Now - Free Forever
                  <motion.div
                    className="ml-2"
                    animate={{ rotate: [0, 360] }}
                    transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                  >
                    <Sparkles className="w-4 h-4" />
                  </motion.div>
                </Button>
              </div>
            </Card>
          </div>
        </motion.div>

        {/* Main Footer Content */}
        <div className="max-w-7xl mx-auto px-6 py-16">
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-12">
            {/* Brand Section */}
            <motion.div 
              className="lg:col-span-2"
              variants={itemVariants}
            >
              <motion.div 
                className="flex items-center space-x-3 mb-6"
                whileHover={{ scale: 1.02 }}
                transition={{ type: "spring", stiffness: 400, damping: 17 }}
              >
                <div className="relative w-12 h-12 rounded-2xl overflow-hidden shadow-subtle">
                  <Image
                    src="/autoquill-logo.png"
                    alt="AutoQuill AI"
                    width={48}
                    height={48}
                    className="object-contain"
                  />
                </div>
                <div className="flex flex-col">
                  <span className="text-xl font-bold text-foreground">
                    AutoQuill AI
                  </span>
                  <Badge variant="secondary" className="text-xs px-2 py-0 w-fit">
                    Open Source
                  </Badge>
                </div>
              </motion.div>
              
              <p className="text-muted-foreground mb-8 leading-relaxed max-w-md">
                The most sophisticated voice-to-text application for macOS. Transform your voice into perfect text with AI-powered precision, complete privacy, and elegant simplicity.
              </p>
              
              {/* Feature highlights */}
              <div className="space-y-3 mb-8">
                {features.map((feature, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-3 group"
                    initial={{ opacity: 0, x: -20 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 0.6, delay: 0.8 + index * 0.1 }}
                    whileHover={{ x: 4, transition: { duration: 0.2 } }}
                  >
                    <motion.div 
                      className={`w-6 h-6 rounded-lg bg-muted/50 flex items-center justify-center ${feature.color}`}
                      whileHover={{ scale: 1.1, rotate: 5 }}
                      transition={{ type: "spring", stiffness: 300 }}
                    >
                      <feature.icon className="w-4 h-4" strokeWidth={2} />
                    </motion.div>
                    <span className="text-sm text-muted-foreground font-medium group-hover:text-foreground transition-colors duration-300">
                      {feature.text}
                    </span>
                  </motion.div>
                ))}
              </div>

              {/* Social Links */}
              <div className="flex gap-4">
                {socialLinks.map((social, index) => (
                  <motion.a
                    key={social.name}
                    href={social.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`w-12 h-12 ${social.bgColor} rounded-2xl flex items-center justify-center ${social.color} hover-lift shadow-subtle`}
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    whileTap={{ scale: 0.95 }}
                    initial={{ opacity: 0, y: 20 }}
                    animate={isInView ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.6, delay: 1.2 + index * 0.1 }}
                  >
                    <social.icon className="w-5 h-5" strokeWidth={2} />
                  </motion.a>
                ))}
              </div>
            </motion.div>

            {/* Quick Links */}
            <motion.div variants={itemVariants}>
              <h4 className="text-lg font-semibold text-foreground mb-6">Quick Links</h4>
              <ul className="space-y-3">
                {quickLinks.map((link, index) => (
                  <motion.li 
                    key={link.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 0.6, delay: 0.6 + index * 0.1 }}
                  >
                    <Link
                      href={link.href}
                      target={link.external ? "_blank" : undefined}
                      rel={link.external ? "noopener noreferrer" : undefined}
                      className="text-muted-foreground hover:text-foreground transition-colors duration-300 flex items-center gap-2 group"
                    >
                      <span className="group-hover:translate-x-1 transition-transform duration-200">
                        {link.name}
                      </span>
                      {link.external && <ExternalLink className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity duration-200" />}
                    </Link>
                  </motion.li>
                ))}
              </ul>
            </motion.div>

            {/* Resources */}
            <motion.div variants={itemVariants}>
              <h4 className="text-lg font-semibold text-foreground mb-6">Resources</h4>
              <ul className="space-y-3">
                {resources.map((resource, index) => (
                  <motion.li 
                    key={resource.name}
                    initial={{ opacity: 0, x: -20 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 0.6, delay: 0.8 + index * 0.1 }}
                  >
                    <Link
                      href={resource.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-muted-foreground hover:text-foreground transition-colors duration-300 flex items-center gap-2 group"
                    >
                      <span className="group-hover:translate-x-1 transition-transform duration-200">
                        {resource.name}
                      </span>
                      <ExternalLink className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity duration-200" />
                    </Link>
                  </motion.li>
                ))}
              </ul>
            </motion.div>
          </div>
        </div>

        {/* Bottom Bar */}
        <motion.div 
          className="border-t border-border/30 py-8"
          variants={itemVariants}
        >
          <div className="max-w-7xl mx-auto px-6">
            <div className="flex flex-col md:flex-row justify-between items-center gap-6">
              <div className="flex flex-col md:flex-row items-center gap-4 text-sm text-muted-foreground">
                <span className="flex items-center gap-2">
                  Made with 
                  <motion.div
                    animate={{ scale: [1, 1.2, 1] }}
                    transition={{ duration: 1, repeat: Infinity }}
                  >
                    <Heart className="w-4 h-4 text-accent fill-current" />
                  </motion.div>
                  for macOS users
                </span>
                <span className="hidden md:block">•</span>
                <span>© 2024 AutoQuill AI. Open source under MIT License.</span>
              </div>
              
              <motion.button
                onClick={scrollToTop}
                className="w-12 h-12 bg-gradient-luxury rounded-2xl flex items-center justify-center text-white shadow-elegant hover:shadow-luxury transition-all duration-300 group"
                whileHover={{ scale: 1.1, y: -2 }}
                whileTap={{ scale: 0.95 }}
              >
                <ArrowUp className="w-5 h-5 group-hover:-translate-y-1 transition-transform duration-300" />
              </motion.button>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </footer>
  )
} 