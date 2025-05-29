'use client'

import { motion } from 'framer-motion'
import { Clock, Brain, Heart, TrendingUp, Zap, Shield } from 'lucide-react'

export default function WhyVoice() {
  const benefits = [
    {
      icon: <Clock className="w-7 h-7" strokeWidth={2.5} />,
      title: "3x Faster",
      description: "Average speaking speed is 150+ WPM vs 40-70 WPM typing"
    },
    {
      icon: <Brain className="w-7 h-7" strokeWidth={2.5} />,
      title: "Natural Flow",
      description: "Maintain your thought process without finger coordination"
    },
    {
      icon: <Heart className="w-7 h-7" strokeWidth={2.5} />,
      title: "Ergonomic",
      description: "Reduce hand strain and repetitive stress injuries"
    },
    {
      icon: <TrendingUp className="w-7 h-7" strokeWidth={2.5} />,
      title: "More Productive",
      description: "Focus on ideas instead of mechanical typing skills"
    },
    {
      icon: <Zap className="w-7 h-7" strokeWidth={2.5} />,
      title: "Instant",
      description: "No typing delays, just immediate text output"
    },
    {
      icon: <Shield className="w-7 h-7" strokeWidth={2.5} />,
      title: "Accessible",
      description: "Perfect for those with mobility or dexterity challenges"
    }
  ]

  return (
    <section className="py-24 bg-white">
      <div className="max-w-6xl mx-auto px-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold text-slate-900 mb-6">
            Why Choose Voice Over Typing?
          </h2>
          <p className="text-xl text-slate-700 max-w-3xl mx-auto font-medium leading-relaxed">
            Your voice is your most natural interface. It's faster, more intuitive, 
            and allows you to express yourself at the speed of thought.
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
          <div className="bg-slate-50 rounded-3xl p-8 border-2 border-slate-200 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-slate-100 to-slate-200 opacity-50"></div>
            <div className="relative z-10">
              <div className="text-center mb-6">
                <div className="text-5xl mb-4">⌨️</div>
                <h3 className="text-2xl font-bold text-slate-900 mb-2">Traditional Typing</h3>
                <div className="text-slate-600 font-medium">The old way</div>
              </div>
              <ul className="space-y-4">
                <li className="flex items-start gap-3 text-slate-700">
                  <div className="w-3 h-3 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">40-70 words per minute maximum</span>
                </li>
                <li className="flex items-start gap-3 text-slate-700">
                  <div className="w-3 h-3 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Requires hand-eye coordination</span>
                </li>
                <li className="flex items-start gap-3 text-slate-700">
                  <div className="w-3 h-3 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Interrupts creative flow</span>
                </li>
                <li className="flex items-start gap-3 text-slate-700">
                  <div className="w-3 h-3 bg-slate-500 rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Can cause repetitive strain</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Voice */}
          <div className="bg-gradient-to-br from-coral to-red-500 rounded-3xl p-8 text-white relative overflow-hidden border-2 border-coral">
            <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-black/10"></div>
            <div className="relative z-10">
              <div className="text-center mb-6">
                <div className="text-5xl mb-4">🎤</div>
                <h3 className="text-2xl font-bold mb-2">Voice Input</h3>
                <div className="text-white/90 font-medium">The future is here</div>
              </div>
              <ul className="space-y-4">
                <li className="flex items-start gap-3">
                  <div className="w-3 h-3 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">150+ words per minute naturally</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-3 h-3 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Completely natural and intuitive</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-3 h-3 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Maintains creative momentum</span>
                </li>
                <li className="flex items-start gap-3">
                  <div className="w-3 h-3 bg-white rounded-full mt-2 flex-shrink-0"></div>
                  <span className="font-medium">Ergonomic and healthy</span>
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
              className="bg-slate-50 rounded-2xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 hover:border-coral/30 group"
            >
              <div className="flex items-start gap-4">
                <div className="w-14 h-14 bg-gradient-to-r from-coral to-red-500 rounded-2xl flex items-center justify-center text-white flex-shrink-0 group-hover:scale-110 transition-transform duration-300">
                  {benefit.icon}
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 mb-2 text-lg">{benefit.title}</h3>
                  <p className="text-slate-700 leading-relaxed font-medium">{benefit.description}</p>
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
          className="text-center bg-slate-50 rounded-3xl p-12 shadow-lg border border-slate-200"
        >
          <blockquote className="text-2xl md:text-3xl font-bold text-slate-900 mb-6 italic">
            "We weren't born to type. We were born to speak."
          </blockquote>
          <p className="text-lg text-slate-700 max-w-2xl mx-auto leading-relaxed font-medium">
            Voice is humanity's most natural form of communication. 
            AutoQuill AI simply bridges the gap between speaking and writing, 
            letting you work at the speed of thought.
          </p>
        </motion.div>
      </div>
    </section>
  )
} 