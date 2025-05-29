import Navigation from '@/components/Navigation'
import HeroSection from '@/components/HeroSection'
import HowItWorks from '@/components/HowItWorks'
import KeyFeatures from '@/components/KeyFeatures'
import DownloadSection from '@/components/DownloadSection'
import Footer from '@/components/Footer'

export default function Home() {
  return (
    <main className="min-h-screen bg-background">
      <Navigation />
      <HeroSection />
      <section id="features">
        <KeyFeatures />
      </section>
      <section id="how-it-works">
        <HowItWorks />
      </section>
      <section id="download">
        <DownloadSection />
      </section>
      <section id="about">
        <Footer />
      </section>
    </main>
  )
}
