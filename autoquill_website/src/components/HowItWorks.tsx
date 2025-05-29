'use client'

import { motion } from 'framer-motion'
import { Keyboard, Mic, ClipboardCheck } from 'lucide-react'

export default function HowItWorks() {
  const steps = [
    {
      icon: <Keyboard className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "01",
      title: "Press Your Hotkey",
      description: "Simply press your configured keyboard shortcut from anywhere on your Mac. No need to open any apps or switch windows."
    },
    {
      icon: <Mic className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "02", 
      title: "Speak Naturally",
      description: "Talk normally in any language. Our AI understands context, punctuation, and even handles background noise gracefully."
    },
    {
      icon: <ClipboardCheck className="w-10 h-10 text-white" strokeWidth={2.5} />,
      number: "03",
      title: "Get Perfect Text",
      description: "Your words appear instantly in your clipboard, ready to paste anywhere. No editing required, just perfect transcription."
    }
  ]

  return (
    <section className="py-24 bg-slate-50">
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
            How It Works
          </h2>
          <p className="text-xl text-slate-700 max-w-3xl mx-auto font-medium leading-relaxed">
            Three simple steps to transform your voice into perfect text. 
            It's so intuitive, you'll wonder how you ever lived without it.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="grid md:grid-cols-3 gap-8 relative">
          {/* Connection lines */}
          <div className="hidden md:block absolute top-20 left-1/6 right-1/6 h-0.5 bg-gradient-to-r from-coral via-red-400 to-coral z-0"></div>

          {steps.map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: index * 0.2 }}
              className="relative z-10"
            >
              <div className="bg-white rounded-3xl p-8 text-center shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 hover:border-coral/30 group">
                {/* Step number */}
                <div className="absolute -top-6 left-1/2 transform -translate-x-1/2">
                  <div className="w-14 h-14 bg-gradient-to-r from-coral to-red-500 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg">
                    {step.number}
                  </div>
                </div>

                {/* Icon */}
                <motion.div
                  whileHover={{ scale: 1.05 }}
                  className="w-20 h-20 bg-gradient-to-r from-slate-700 to-slate-900 rounded-3xl flex items-center justify-center mx-auto mb-6 mt-6 group-hover:from-coral group-hover:to-red-500 transition-all duration-300"
                >
                  {step.icon}
                </motion.div>

                {/* Content */}
                <h3 className="text-2xl font-bold text-slate-900 mb-4">
                  {step.title}
                </h3>
                <p className="text-slate-700 leading-relaxed font-medium">
                  {step.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center mt-16"
        >
          <p className="text-xl text-slate-700 mb-8 font-medium">
            Ready to experience the future of text input?
          </p>
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="bg-gradient-to-r from-coral to-red-500 text-white px-10 py-5 rounded-2xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all duration-300"
          >
            Download AutoQuill AI
          </motion.button>
        </motion.div>
      </div>
    </section>
  )
} 