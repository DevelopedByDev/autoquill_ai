'use client'

import { motion } from 'framer-motion'
import { useInView } from 'framer-motion'
import { useRef } from 'react'
import { Zap, Shield, Globe, Lock } from 'lucide-react'

export default function SpeedSecurity() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  return (
    <section ref={ref} className="py-24 bg-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-br from-primary-red via-transparent to-blue-500 transform rotate-12 scale-150"></div>
      </div>

      <div className="max-w-6xl mx-auto px-6 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h2 className="text-5xl md:text-6xl font-bold font-display mb-6 text-accent-black">
            <span className="text-primary-red">Lightning Fast</span> & Secure
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Built on cutting-edge AI infrastructure with privacy as our foundation.
          </p>
        </motion.div>

        {/* Speed Section */}
        <motion.div
          initial={{ opacity: 0, x: -50 }}
          animate={isInView ? { opacity: 1, x: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="grid md:grid-cols-2 gap-12 items-center mb-20"
        >
          <div>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-2xl flex items-center justify-center">
                <Zap className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-4xl font-bold font-display text-accent-black">
                Groq Speed
              </h3>
            </div>
            <p className="text-xl text-gray-600 mb-6 leading-relaxed">
              Runs at <span className="font-bold text-primary-red">lightning speed</span> thanks to Groq's specialized AI hardware. 
              Experience near-instantaneous transcription that keeps up with your thoughts.
            </p>
            <ul className="space-y-3 text-gray-600">
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-primary-red rounded-full"></div>
                <span>Sub-second response times</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-primary-red rounded-full"></div>
                <span>Dedicated AI inference hardware</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-primary-red rounded-full"></div>
                <span>Real-time processing capabilities</span>
              </li>
            </ul>
          </div>
          <div className="bg-gradient-to-br from-yellow-100 to-orange-100 rounded-2xl p-8 text-center">
            <div className="text-6xl font-bold text-primary-red mb-4">
              &lt;1s
            </div>
            <p className="text-xl font-semibold text-gray-700">
              Average Response Time
            </p>
            <p className="text-gray-600 mt-2">
              From speech to clipboard
            </p>
          </div>
        </motion.div>

        {/* Whisper Section */}
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          animate={isInView ? { opacity: 1, x: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="grid md:grid-cols-2 gap-12 items-center mb-20"
        >
          <div className="bg-gradient-to-br from-blue-100 to-purple-100 rounded-2xl p-8 text-center order-2 md:order-1">
            <div className="text-6xl font-bold text-blue-600 mb-4">
              99%+
            </div>
            <p className="text-xl font-semibold text-gray-700">
              Accuracy Rate
            </p>
            <p className="text-gray-600 mt-2">
              Across 100+ languages
            </p>
          </div>
          <div className="order-1 md:order-2">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-500 rounded-2xl flex items-center justify-center">
                <Globe className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-4xl font-bold font-display text-accent-black">
                Whisper Accuracy
              </h3>
            </div>
            <p className="text-xl text-gray-600 mb-6 leading-relaxed">
              Powered by <span className="font-bold text-blue-600">OpenAI Whisper</span>, the world's most accurate 
              speech recognition model. Supporting over 100 languages with human-level transcription quality.
            </p>
            <ul className="space-y-3 text-gray-600">
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span>State-of-the-art AI model</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span>Multi-language support</span>
              </li>
              <li className="flex items-center gap-3">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <span>Noise-robust transcription</span>
              </li>
            </ul>
          </div>
        </motion.div>

        {/* Privacy Section */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="bg-gray-900 rounded-2xl p-8 md:p-12 text-white text-center"
        >
          <div className="flex justify-center mb-8">
            <div className="w-20 h-20 bg-primary-red rounded-2xl flex items-center justify-center">
              <Shield className="w-10 h-10 text-white" />
            </div>
          </div>
          <h3 className="text-4xl font-bold font-display mb-6">
            Privacy by Design
          </h3>
          <p className="text-xl text-gray-300 mb-8 max-w-3xl mx-auto leading-relaxed">
            Your data privacy is paramount. <span className="text-primary-red font-semibold">No accounts required</span>, 
            no cloud storage of your voice data, and output goes directly to your clipboard.
          </p>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <Lock className="w-8 h-8 text-primary-red mx-auto mb-4" />
              <h4 className="font-bold mb-2">No Storage</h4>
              <p className="text-gray-400 text-sm">Voice data is processed and immediately discarded</p>
            </div>
            <div className="text-center">
              <Shield className="w-8 h-8 text-primary-red mx-auto mb-4" />
              <h4 className="font-bold mb-2">No Accounts</h4>
              <p className="text-gray-400 text-sm">No registration, no tracking, no user profiles</p>
            </div>
            <div className="text-center">
              <Zap className="w-8 h-8 text-primary-red mx-auto mb-4" />
              <h4 className="font-bold mb-2">Clipboard Only</h4>
              <p className="text-gray-400 text-sm">Results go directly to your clipboard, nowhere else</p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
} 