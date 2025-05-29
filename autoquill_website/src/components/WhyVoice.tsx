'use client'

import React from 'react'
import { motion } from 'framer-motion'
import { Clock, Brain, Heart, TrendingUp, Zap, Shield } from 'lucide-react'

export default function WhyVoice() {
  const benefits = [
    {
      icon: <Clock className="w-7 h-7" strokeWidth={2.5} />,
      title: "3x Faster",
      description: "Speak at 150+ WPM vs 40-70 WPM typing"
    },
    {
      icon: <Brain className="w-7 h-7" strokeWidth={2.5} />,
      title: "Natural Flow",
      description: "Think and speak without interruption"
    },
    {
      icon: <Heart className="w-7 h-7" strokeWidth={2.5} />,
      title: "Ergonomic",
      description: "Reduce hand strain and fatigue"
    },
    {
      icon: <TrendingUp className="w-7 h-7" strokeWidth={2.5} />,
      title: "More Creative",
      description: "Focus on ideas, not mechanics"
    },
    {
      icon: <Zap className="w-7 h-7" strokeWidth={2.5} />,
      title: "Instant Output",
      description: "No typing delays or mistakes"
    },
    {
      icon: <Shield className="w-7 h-7" strokeWidth={2.5} />,
      title: "Accessible",
      description: "Perfect for all abilities"
    }
  ]

  return (
    <section className="py-24 bg-slate-800 relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden opacity-30">
        <motion.div 
          className="absolute top-1/4 left-0 w-96 h-96 bg-gradient-to-r from-primary-500/30 to-accent-500/30 rounded-full blur-3xl"
          animate={{ x: [0, 100, 0], y: [0, -50, 0] }}
          transition={{ duration: 25, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div 
          className="absolute bottom-1/4 right-0 w-80 h-80 bg-gradient-to-r from-accent-500/30 to-coral/30 rounded-full blur-3xl"
          animate={{ x: [0, -80, 0], y: [0, 40, 0] }}
          transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
        />
      </div>

      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6 bg-gradient-to-r from-white via-primary-300 to-accent-300 bg-clip-text text-transparent">
            Why Voice Beats Typing
          </h2>
          <p className="text-xl text-slate-300 max-w-2xl mx-auto font-medium leading-relaxed">
            Your voice is faster, more natural, and lets you work at the speed of thought.
          </p>
        </motion.div>

        {/* Comparison */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="grid md:grid-cols-2 gap-8 mb-16"
        >
          {/* Typing */}
          <div className="bg-gradient-to-br from-slate-700 to-slate-800 rounded-3xl p-8 border border-slate-600 relative overflow-hidden">
            <div className="relative z-10">
              <div className="text-center mb-6">
                <div className="text-4xl mb-4">⌨️</div>
                <h3 className="text-2xl font-bold text-white mb-2">Traditional Typing</h3>
                <div className="text-slate-400 font-medium">The old way</div>
              </div>
              <ul className="space-y-3">
                <li className="flex items-start gap-3 text-slate-300">
                  <div className="w-2 h-2 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">40-70 words per minute</span>
                </li>
                <li className="flex items-start gap-3 text-slate-300">
                  <div className="w-2 h-2 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Requires coordination</span>
                </li>
                <li className="flex items-start gap-3 text-slate-300">
                  <div className="w-2 h-2 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Interrupts flow</span>
                </li>
                <li className="flex items-start gap-3 text-slate-300">
                  <div className="w-2 h-2 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Can cause strain</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Voice */}
          <div className="bg-gradient-to-br from-primary-600 via-accent-600 to-coral rounded-3xl p-8 text-white relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-black/10"></div>
            <div className="relative z-10">
              <div className="text-center mb-6">
                <div className="text-4xl mb-4">🎤</div>
                <h3 className="text-2xl font-bold mb-2">Voice Input</h3>
                <div className="text-white/90 font-medium">The future</div>
              </div>
              <ul className="space-y-3">
                <li className="flex items-start gap-3">
                  <div className="w-2 h-2 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">150+ words per minute</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-2 h-2 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Completely natural</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-2 h-2 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Maintains momentum</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-2 h-2 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Ergonomic & healthy</span>
                </li>
              </ul>
            </div>
          </div>
        </motion.div>

        {/* Benefits Grid */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16"
        >
          {benefits.map((benefit, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.6 + index * 0.1 }}
              className="bg-slate-700/80 backdrop-blur-sm rounded-2xl p-6 shadow-medium hover:shadow-large transition-all duration-300 border border-slate-600/50 hover:border-primary-400/50 group"
              whileHover={{ y: -5 }}
            >
              <div className="flex items-start gap-4">
                <div className="w-14 h-14 bg-gradient-to-r from-primary-500 to-accent-500 rounded-2xl flex items-center justify-center text-white flex-shrink-0 group-hover:scale-110 transition-transform duration-300">
                  {benefit.icon}
                </div>
                <div>
                  <h3 className="font-bold text-white mb-2 text-lg">{benefit.title}</h3>
                  <p className="text-slate-300 leading-relaxed font-medium">{benefit.description}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Quote */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center bg-gradient-to-r from-slate-700 via-slate-800 to-slate-700 rounded-3xl p-12 shadow-large border border-slate-600"
        >
          <blockquote className="text-2xl md:text-3xl font-bold text-white mb-6 italic bg-gradient-to-r from-primary-400 to-accent-400 bg-clip-text text-transparent">
            "We weren't born to type. We were born to speak."
          </blockquote>
          <p className="text-lg text-slate-300 max-w-2xl mx-auto leading-relaxed font-medium">
            AutoQuill AI bridges the gap between speaking and writing, 
            letting you work at the speed of thought.
          </p>
        </motion.div>
      </div>
    </section>
  )
} 