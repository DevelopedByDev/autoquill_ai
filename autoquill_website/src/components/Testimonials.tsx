'use client'

import { motion } from 'framer-motion'
import { useInView } from 'framer-motion'
import { useRef } from 'react'
import { Quote } from 'lucide-react'

export default function Testimonials() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  const testimonials = [
    {
      quote: "AutoQuill AI has completely transformed my writing process. I can now capture ideas as fast as I think them. It's like having a superpower.",
      author: "Sarah Chen",
      role: "Content Creator & Blogger",
      avatar: "👩‍💻",
      color: "from-purple-400 to-pink-500"
    },
    {
      quote: "As a developer, I type all day. AutoQuill AI saves my hands and boosts my productivity. The clipboard integration is seamless—it just works.",
      author: "Marcus Rodriguez",
      role: "Senior Software Engineer",
      avatar: "👨‍💻",
      color: "from-blue-400 to-purple-500"
    },
    {
      quote: "The speed is incredible. I dictate emails, notes, even code comments. Being open source means I can trust it with my workflow completely.",
      author: "Dr. Emily Watson",
      role: "Research Scientist",
      avatar: "👩‍🔬",
      color: "from-green-400 to-teal-500"
    }
  ]

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
            What Users Are <span className="text-primary-red">Saying</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Real feedback from early adopters who've experienced the future of text input.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.8, delay: index * 0.2 }}
              className="group"
            >
              <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 h-full group-hover:-translate-y-2 relative overflow-hidden">
                {/* Background Gradient */}
                <div className={`absolute inset-0 bg-gradient-to-br ${testimonial.color} opacity-0 group-hover:opacity-5 transition-opacity duration-500`}></div>
                
                <div className="relative z-10">
                  {/* Quote Icon */}
                  <div className="flex justify-between items-start mb-6">
                    <Quote className="w-8 h-8 text-primary-red" />
                    <div className="text-2xl">{testimonial.avatar}</div>
                  </div>

                  {/* Quote */}
                  <blockquote className="text-lg text-gray-700 mb-6 leading-relaxed italic">
                    "{testimonial.quote}"
                  </blockquote>

                  {/* Author */}
                  <div className="border-t border-gray-100 pt-6">
                    <div className="flex items-center gap-4">
                      <div className={`w-12 h-12 bg-gradient-to-r ${testimonial.color} rounded-full flex items-center justify-center text-white text-xl`}>
                        {testimonial.avatar}
                      </div>
                      <div>
                        <div className="font-bold text-accent-black group-hover:text-primary-red transition-colors duration-300">
                          {testimonial.author}
                        </div>
                        <div className="text-sm text-gray-500">
                          {testimonial.role}
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Hover Effect */}
                  <motion.div
                    initial={{ width: 0 }}
                    whileHover={{ width: "100%" }}
                    className={`h-1 bg-gradient-to-r ${testimonial.color} rounded-full mt-6`}
                  />
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Call to Action */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.8 }}
          className="text-center mt-16"
        >
          <h3 className="text-3xl font-bold font-display mb-4 text-accent-black">
            Join Thousands of Happy Users
          </h3>
          <p className="text-xl text-gray-600 mb-8">
            Experience the future of text input today. <span className="font-semibold text-primary-red">It's free, forever.</span>
          </p>
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="bg-primary-red text-white px-10 py-5 rounded-2xl text-xl font-bold shadow-2xl hover:bg-red-600 transition-all duration-300"
          >
            Download AutoQuill AI
          </motion.button>
        </motion.div>

        {/* Stars Rating */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.8, delay: 1 }}
          className="text-center mt-8"
        >
          <div className="flex justify-center items-center gap-2 mb-2">
            {[...Array(5)].map((_, i) => (
              <span key={i} className="text-yellow-400 text-2xl">⭐</span>
            ))}
          </div>
          <p className="text-gray-500">4.9/5 stars from early adopters</p>
        </motion.div>
      </div>
    </section>
  )
} 