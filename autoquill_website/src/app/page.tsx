import HeroSection from '@/components/HeroSection'
import HowItWorks from '@/components/HowItWorks'
import WhyVoice from '@/components/WhyVoice'
import KeyFeatures from '@/components/KeyFeatures'
import DownloadSection from '@/components/DownloadSection'
import Footer from '@/components/Footer'

export default function Home() {
  return (
    <main className="min-h-screen bg-white">
      <HeroSection />
      <HowItWorks />
      <WhyVoice />
      <KeyFeatures />
      <DownloadSection />
      <Footer />
    </main>
  )
}
