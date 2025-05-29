'use client'

import { motion } from 'framer-motion'
import { useInView } from 'framer-motion'
import { useRef } from 'react'
import { ExternalLink } from 'lucide-react'

export default function Acknowledgements() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  const partners = [
    {
      name: "Groq",
      description: "AI inference provider delivering lightning-fast processing",
      logo: "🚀",
      url: "https://groq.com",
      color: "from-yellow-400 to-orange-500"
    },
    {
      name: "OpenAI Whisper",
      description: "State-of-the-art speech recognition model",
      logo: "🧠",
      url: "https://openai.com/whisper",
      color: "from-blue-500 to-purple-500"
    },
    {
      name: "Zapsplat",
      description: "Audio UI sounds for enhanced user experience",
      logo: "🎵",
      url: "https://zapsplat.com",
      color: "from-green-500 to-teal-500"
    }
  ]

  return (
    <section ref={ref} className="py-24 bg-white">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
          className="text-center mb-16"
        >
          <h2 className="text-5xl md:text-6xl font-bold font-display mb-6 text-accent-black">
            Powered By <span className="text-primary-red">Pioneers</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            AutoQuill AI stands on the shoulders of giants. We're grateful to these 
            incredible companies and projects that make our vision possible.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8 mb-16">
          {partners.map((partner, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: index * 0.2 }}
              className="group"
            >
              <div className="bg-white border-2 border-gray-100 rounded-2xl p-8 text-center hover:border-primary-red transition-all duration-300 hover:shadow-xl group-hover:-translate-y-2">
                {/* Logo */}
                <div className={`w-20 h-20 bg-gradient-to-r ${partner.color} rounded-2xl flex items-center justify-center text-white mx-auto mb-6 group-hover:scale-110 transition-transform duration-300 text-3xl`}>
                  {partner.logo}
                </div>

                {/* Content */}
                <h3 className="text-2xl font-bold font-display mb-4 text-accent-black group-hover:text-primary-red transition-colors duration-300">
                  {partner.name}
                </h3>
                <p className="text-gray-600 mb-6 leading-relaxed">
                  {partner.description}
                </p>

                {/* Link */}
                <motion.a
                  href={partner.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="inline-flex items-center gap-2 text-primary-red font-semibold hover:text-red-600 transition-colors duration-300"
                >
                  Learn More
                  <ExternalLink className="w-4 h-4" />
                </motion.a>

                {/* Hover Effect */}
                <motion.div
                  initial={{ width: 0 }}
                  whileHover={{ width: "100%" }}
                  className={`h-1 bg-gradient-to-r ${partner.color} rounded-full mt-6 mx-auto`}
                />
              </div>
            </motion.div>
          ))}
        </div>

        {/* Thank You Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="bg-background-gray rounded-2xl p-8 md:p-12 text-center"
        >
          <h3 className="text-3xl font-bold font-display mb-6 text-accent-black">
            Thank You to Our Technology Partners
          </h3>
          <p className="text-xl text-gray-600 max-w-4xl mx-auto leading-relaxed">
            Innovation happens when great minds collaborate. We're honored to build upon 
            the groundbreaking work of these industry leaders, bringing together the best 
            in AI inference, speech recognition, and audio design to create something truly special.
          </p>
          
          <div className="mt-8 flex flex-wrap justify-center gap-6 text-sm text-gray-500">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-primary-red rounded-full"></div>
              <span>Groq LPU™ Inference Engine</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-primary-red rounded-full"></div>
              <span>OpenAI Whisper v3</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-primary-red rounded-full"></div>
              <span>Professional Audio Assets</span>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
} 