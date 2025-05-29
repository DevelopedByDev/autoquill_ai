'use client'

import { motion } from 'framer-motion'
import { useInView } from 'framer-motion'
import { useRef } from 'react'
import { Github, Star, Users, Code } from 'lucide-react'

export default function OpenSource() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  return (
    <section ref={ref} className="py-24 bg-background-gray">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h2 className="text-5xl md:text-6xl font-bold font-display mb-6 text-accent-black">
            Built in the <span className="text-primary-red">Open</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Open source, by and for the community. Transparent development, 
            collaborative improvement, and free forever.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-12 items-center mb-16">
          {/* Left side - Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 bg-accent-black rounded-2xl flex items-center justify-center">
                <Github className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-4xl font-bold font-display text-accent-black">
                Open Source
              </h3>
            </div>
            <p className="text-xl text-gray-600 mb-6 leading-relaxed">
              Every line of code is open for inspection, contribution, and improvement. 
              We believe that voice-to-text technology should belong to everyone.
            </p>
            <ul className="space-y-4 text-gray-600 mb-8">
              <li className="flex items-center gap-3">
                <Code className="w-5 h-5 text-primary-red" />
                <span>MIT License - truly free and open</span>
              </li>
              <li className="flex items-center gap-3">
                <Users className="w-5 h-5 text-primary-red" />
                <span>Community-driven development</span>
              </li>
              <li className="flex items-center gap-3">
                <Star className="w-5 h-5 text-primary-red" />
                <span>Transparent roadmap and issues</span>
              </li>
            </ul>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="bg-accent-black text-white px-8 py-4 rounded-xl font-bold text-lg hover:bg-gray-800 transition-colors duration-300 flex items-center gap-3"
            >
              <Github className="w-6 h-6" />
              View on GitHub
            </motion.button>
          </motion.div>

          {/* Right side - GitHub Preview */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.4 }}
            className="bg-white rounded-2xl p-8 shadow-xl"
          >
            <div className="bg-gray-100 rounded-xl p-6 mb-6">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-8 h-8 bg-accent-black rounded-full flex items-center justify-center">
                  <Github className="w-4 h-4 text-white" />
                </div>
                <div>
                  <div className="font-semibold text-accent-black">AutoQuill-AI/autoquill</div>
                  <div className="text-sm text-gray-500">Public repository</div>
                </div>
              </div>
              <div className="text-sm text-gray-600 mb-4">
                🎤 The blazing-fast, open-source voice-to-text desktop app for macOS. Free forever.
              </div>
              <div className="flex items-center gap-6 text-sm text-gray-500">
                <div className="flex items-center gap-1">
                  <Star className="w-4 h-4" />
                  <span>1.2k</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
                  <span>Swift</span>
                </div>
                <div>MIT License</div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center p-4 bg-background-gray rounded-xl">
                <div className="text-2xl font-bold text-primary-red">1.2k</div>
                <div className="text-sm text-gray-600">Stars</div>
              </div>
              <div className="text-center p-4 bg-background-gray rounded-xl">
                <div className="text-2xl font-bold text-primary-red">200+</div>
                <div className="text-sm text-gray-600">Forks</div>
              </div>
              <div className="text-center p-4 bg-background-gray rounded-xl">
                <div className="text-2xl font-bold text-primary-red">45</div>
                <div className="text-sm text-gray-600">Contributors</div>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Call to Action */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.6 }}
          className="bg-gradient-to-r from-primary-red to-pink-500 rounded-2xl p-8 md:p-12 text-white text-center"
        >
          <h3 className="text-4xl font-bold font-display mb-6">
            Join the Community
          </h3>
          <p className="text-xl mb-8 max-w-3xl mx-auto leading-relaxed">
            Help us build the future of voice computing. Whether you're a developer, 
            designer, or just passionate about open source, there's a place for you.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="bg-white text-primary-red px-8 py-4 rounded-xl font-bold text-lg hover:bg-gray-100 transition-colors duration-300 flex items-center gap-3 justify-center"
            >
              <Star className="w-6 h-6" />
              ⭐ Star us on GitHub
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="border-2 border-white text-white px-8 py-4 rounded-xl font-bold text-lg hover:bg-white hover:text-primary-red transition-all duration-300 flex items-center gap-3 justify-center"
            >
              <Code className="w-6 h-6" />
              Contribute Code
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  )
} 