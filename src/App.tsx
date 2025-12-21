import React, { useState, useEffect, useRef } from 'react';
import { Mail, ArrowRight, Menu, X, Plus, Minus } from 'lucide-react';
import { Toaster, toast } from 'react-hot-toast';
import { TestimonialCard } from './components/TestimonialCard';
import { FeatureCard } from './components/FeatureCard';
import { StatCard } from './components/StatCard';
import { Link } from 'react-router-dom';

function App() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [showCalendarSection, setShowCalendarSection] = useState(false);
  const [expandedFaq, setExpandedFaq] = useState<string | null>(null);
  const calendarRef = useRef<HTMLDivElement>(null);

  const handleFaqClick = (id: string) => {
    setExpandedFaq(expandedFaq === id ? null : id);
  };

  const handleShowCalendarSection = (e?: React.MouseEvent) => {
    if (e) {
      e.preventDefault();
    }

    setShowCalendarSection(true);

    // Use a slightly longer timeout to ensure the section is fully rendered
    setTimeout(() => {
      if (calendarRef.current) {
        calendarRef.current.scrollIntoView({ 
          behavior: 'smooth',
          block: 'center'
        });
      }
    }, 150);
  };

  return (
    <div className="min-h-screen bg-black text-white">
      <Toaster 
        position="top-center"
        toastOptions={{
          duration: 3000,
          style: {
            background: '#1a1a1a',
            color: '#fff',
            border: '1px solid rgba(255, 255, 255, 0.1)'
          }
        }}
      />
      
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 px-2 py-2 sm:px-4 sm:py-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-white/10 backdrop-blur-xl border border-white/10 rounded-xl sm:rounded-2xl px-3 py-2.5 sm:px-6 sm:py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="relative group">
                  <div className="absolute -inset-2 bg-gradient-to-r from-blue-600 to-teal-600 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-200"></div>
                  <div className="relative bg-black rounded-lg p-3 sm:p-2.5 ring-1 ring-white/10 group-hover:ring-white/20 transition duration-200">
                    <Mail className="w-7 h-7 sm:w-7 sm:h-7 text-[#2B6CEE] group-hover:text-[#2B6CEE]/80 transition-colors" />
                  </div>
                </div>
                <div>
                  <span className="text-xl sm:text-xl font-bold text-white">
                    Expert.Email<sup className="text-[0.6em]">™</sup>
                  </span>
                  <span className="hidden sm:block text-xs text-gray-400 font-medium -mt-1">
                    Authentic Experts
                  </span>
                </div>
              </div>
              
              {/* Desktop Navigation */}
              <div className="hidden md:flex items-center gap-8">
                <nav>
                  <ul className="flex items-center gap-8">
                    <li>
                      <a href="#" className="text-gray-300 hover:text-white transition-colors">
                        Home
                      </a>
                    </li>
                    <li>
                      <a href="#services" className="text-gray-300 hover:text-white transition-colors">
                        Services
                      </a>
                    </li>
                    <li>
                      <a href="#faq" className="text-gray-300 hover:text-white transition-colors">
                        FAQ
                      </a>
                    </li>
                  </ul>
                </nav>
                <button
                  onClick={() => window.open('https://cal.com/chuck-mullaney-s0dslw/consultation', '_blank')}
                  className="text-blue-400 font-medium flex items-center gap-2 animate-pulse"
                >
                  <span>Free Audit</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>

              {/* Mobile Menu Button */}
              <button
                type="button"
                className="md:hidden inline-flex items-center justify-center p-1.5 text-blue-400 hover:text-blue-300 rounded-lg hover:bg-white/5 transition-colors"
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                aria-expanded={mobileMenuOpen}
                aria-label="Toggle menu"
              >
                <span className="sr-only">Open main menu</span>
                {mobileMenuOpen ? (
                  <X className="block h-6 w-6" aria-hidden="true" />
                ) : (
                  <Menu className="block h-6 w-6" aria-hidden="true" />
                )}
              </button>
            </div>

            {/* Mobile Navigation */}
            {mobileMenuOpen && (
              <nav className="md:hidden mt-3 pt-3 border-t border-white/10">
                <ul className="flex flex-col gap-2">
                  <li>
                    <a 
                      href="#" 
                      className="block px-2 py-2 text-sm text-gray-300 hover:text-white transition-colors rounded-lg hover:bg-white/5"
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      Home
                    </a>
                  </li>
                  <li>
                    <a 
                      href="#services" 
                      className="block px-2 py-2 text-sm text-gray-300 hover:text-white transition-colors rounded-lg hover:bg-white/5"
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      Services
                    </a>
                  </li>
                  <li>
                    <a
                      href="#faq"
                      className="block px-2 py-2 text-sm text-gray-300 hover:text-white transition-colors rounded-lg hover:bg-white/5"
                      onClick={() => setMobileMenuOpen(false)}
                    >
                      FAQ
                    </a>
                  </li>
                  <li>
                    <button
                      onClick={() => {
                        setMobileMenuOpen(false);
                        window.open('https://cal.com/chuck-mullaney-s0dslw/confidential-meeting-with-an-expert-consultant', '_blank');
                      }}
                      className="w-full text-left px-2 py-2 text-sm text-gray-300 hover:text-white transition-colors rounded-lg hover:bg-white/5"
                    >
                      Free Audit
                    </button>
                  </li>
                </ul>
              </nav>
            )}
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-28 pb-12">
        <div className="relative">
          {/* Gradient Orb */}
          <div className="absolute top-[-200px] left-1/2 transform -translate-x-1/2">
            <div className="w-[600px] h-[600px] rounded-full bg-gradient-to-r from-blue-600/20 via-teal-600/20 to-emerald-600/20 blur-3xl" />
          </div>

          <div className="relative">
            {/* Content */}
            <div className="text-center max-w-5xl mx-auto">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 backdrop-blur-xl border border-white/10 mb-6">
                <span className="text-blue-400">Limited Time</span>
                <span className="w-1 h-1 rounded-full bg-white/20"></span>
                <span className="text-gray-300">Private Strategy Session</span>
              </div>
              
              <div className="space-y-1">
                <h1 className="text-5xl sm:text-6xl lg:text-8xl font-bold bg-gradient-to-r from-white via-blue-200 to-white bg-clip-text text-transparent leading-[1.2] pb-1">
                  Ready to Transform
                </h1>
                <h1 className="text-5xl sm:text-6xl lg:text-8xl font-bold bg-gradient-to-r from-white via-blue-200 to-white bg-clip-text text-transparent leading-[1.2] pb-1">
                  Your Email Marketing?
                </h1>
              </div>
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 backdrop-blur-xl border border-white/10 mb-8 mt-6">
                <span className="text-gray-300">Experience the Power</span>
                <span className="w-1 h-1 rounded-full bg-white/20"></span>
                <span className="text-blue-400">Our Professional Email Audits</span>
              </div>
              
              {/* CTA Section */}
              <div className="flex flex-col items-center space-y-4">
                <div className="flex flex-col sm:flex-row gap-4">
                  <button
                    onClick={() => window.open('https://cal.com/chuck-mullaney-s0dslw/consultation', '_blank')}
                    className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-10 py-5 rounded-xl flex items-center justify-center gap-3 hover:from-blue-600 hover:to-blue-700 transition-all duration-300"
                  >
                    <span className="flex items-center gap-3 text-lg font-semibold tracking-wide">
                      Get Started Now →
                    </span>
                  </button>
                  <button
                    onClick={() => window.open('https://cal.com/chuck-mullaney-s0dslw/confidential-meeting-with-an-expert-consultant', '_blank')}
                    className="bg-white/10 backdrop-blur-xl border border-white/20 text-white px-10 py-5 rounded-xl flex items-center justify-center gap-3 hover:bg-white/20 transition-all duration-300"
                  >
                    <span className="flex items-center gap-3 text-lg font-semibold tracking-wide">
                      Talk to a Human →
                    </span>
                  </button>
                </div>
                <p className="text-blue-400 font-medium mt-3 animate-pulse">Limited spots available</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Process Section */}
      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center max-w-3xl mx-auto mb-8">
            <h2 className="text-4xl font-bold mb-2 text-[#296BED]">
              Struggling to Convert Your Email List Into Profits?
            </h2>
          </div>

          <div className="text-center max-w-3xl mx-auto mb-16">
            <p className="text-xl text-gray-400 leading-relaxed">
              Our proven framework optimizes your campaigns so you see higher open rates, consistent conversions, and a stronger relationship with your audience.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {/* Step 1 */}
            <div className="relative group">
              <div className="absolute inset-0 bg-gradient-to-r from-red-500/10 to-red-600/10 rounded-2xl blur-xl transition-all duration-300 group-hover:blur-2xl" />
              <div className="relative bg-white/5 backdrop-blur-xl border border-white/10 p-6 rounded-2xl hover:border-white/20 transition-all duration-300">
                <div className="text-red-500 mb-4">
                  <span className="text-4xl">🛑</span>
                </div>
                <h3 className="text-xl font-bold mb-3 text-white">Your Struggle</h3>
                <ul className="space-y-2 text-gray-400">
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-red-500 rounded-full" />
                    Poor open rates
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-red-500 rounded-full" />
                    Low conversions
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-red-500 rounded-full" />
                    Spam folder issues
                  </li>
                </ul>
              </div>
            </div>

            {/* Step 2 */}
            <button
              onClick={() => window.open('https://cal.com/chuck-mullaney-s0dslw/consultation', '_blank')}
              className="relative group w-full text-left cursor-pointer"
            >
              <div className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-blue-600/20 rounded-2xl blur-xl transition-all duration-300 group-hover:blur-2xl animate-pulse" />
              <div className="absolute -inset-1 bg-gradient-to-r from-blue-500 to-blue-600 rounded-2xl blur-lg opacity-30 group-hover:opacity-50 animate-pulse" />
              <div className="absolute -inset-0.5 bg-gradient-to-r from-blue-500 to-blue-600 rounded-2xl blur-sm opacity-20 group-hover:opacity-40 animate-pulse" />
              <div className="relative bg-white/5 backdrop-blur-xl border-2 border-blue-500/50 p-6 rounded-2xl transition-all duration-300">
                <div className="text-blue-500 mb-4 flex items-center justify-between">
                  <span className="text-4xl">🔍</span>
                  <span className="text-sm font-medium text-white bg-blue-500/30 px-3 py-1 rounded-full group-hover:bg-blue-500/40 transition-colors">Step 1 • Free</span>
                </div>
                <h3 className="text-xl font-bold mb-3 text-white">The Audit</h3>
                <ul className="space-y-2 text-gray-400">
                  <li className="flex items-center gap-2">
                    <span className="w-1.5 h-1.5 bg-blue-500 rounded-full" />
                    Identify gaps
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1.5 h-1.5 bg-blue-500 rounded-full" />
                    Technical analysis
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1.5 h-1.5 bg-blue-500 rounded-full" />
                    Find opportunities
                  </li>
                </ul>
              </div>
            </button>

            {/* Step 3 */}
            <div className="relative group">
              <div className="absolute inset-0 bg-gradient-to-r from-green-500/10 to-green-600/10 rounded-2xl blur-xl transition-all duration-300 group-hover:blur-2xl" />
              <div className="relative bg-white/5 backdrop-blur-xl border border-white/10 p-6 rounded-2xl hover:border-white/20 transition-all duration-300">
                <div className="text-[#F39C12] mb-4 flex items-center justify-between">
                  <span className="text-4xl">⚙️</span>
                  <span className="text-sm font-medium text-white">Step 2 • Optional</span>
                </div>
                <h3 className="text-xl font-bold mb-3 text-white">Implementation</h3>
                <ul className="space-y-2 text-gray-400">
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#F39C12] rounded-full" />
                    Revamp campaigns
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#F39C12] rounded-full" />
                    Fix technical issues
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#F39C12] rounded-full" />
                    Apply best practices
                  </li>
                </ul>
              </div>
            </div>

            {/* Step 4 */}
            <div className="relative group">
              <div className="absolute inset-0 bg-gradient-to-r from-purple-500/10 to-purple-600/10 rounded-2xl blur-xl transition-all duration-300 group-hover:blur-2xl" />
              <div className="relative bg-white/5 backdrop-blur-xl border border-white/10 p-6 rounded-2xl hover:border-white/20 transition-all duration-300">
                <div className="text-[#9B59B6] mb-4 flex items-center justify-between">
                  <span className="text-4xl">🚀</span>
                  <span className="text-sm font-medium text-white">Step 3 • Optional</span>
                </div>
                <h3 className="text-xl font-bold mb-3 text-white">Results</h3>
                <ul className="space-y-2 text-gray-400">
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#9B59B6] rounded-full" />
                    High engagement
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#9B59B6] rounded-full" />
                    Increased revenue
                  </li>
                  <li className="flex items-center gap-2">
                    <span className="w-1 h-1 bg-[#9B59B6] rounded-full" />
                    Sustainable growth
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <p className="text-center text-gray-400 text-lg mt-12 max-w-3xl mx-auto">
            *By letting us lead you through these steps, you're not just optimizing emails—you're laying the groundwork for scalable, profitable relationships with your audience, all while freeing up time and reducing stress.
          </p>
        </div>
      </div>

      {/* Testimonials Section */}
      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-4xl font-bold mb-2 text-[#296BED]">
              A Few Kind Words
            </h2>
            <p className="text-gray-400">
              Real Feedback From the People We Served
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <TestimonialCard
              image="/trevor_larsen.png"
              name=""
              role=""
              company=""
              stars={5}
              quote="Chuck's expertise is off the charts. I've never met anyone with the technical know-how that he has in terms of optimizing email performance, inboxing, and reputation.

Better yet, his unique copywriting strategy and philosophy is something you don't hear about anywhere else and it flat out works. 

Before working with Chuck, we weren't sure what was going to happen to thousands of our contacts that were previously disengaged, and if our email reputation would ever recover.

Now we're coming back with a vengeance and are confident this trend will continue into the future. I highly recommend working with him."
              signature={
                <svg width="300" height="60" className="mx-auto">
                  <defs>
                    <linearGradient id="signatureGradient1" x1="0%" y1="0%" x2="100%" y2="0%">
                      <stop offset="0%" style={{ stopColor: '#60A5FA', stopOpacity: 0.8 }} />
                      <stop offset="100%" style={{ stopColor: '#2DD4BF', stopOpacity: 0.8 }} />
                    </linearGradient>
                    <filter id="glow1">
                      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>
                  <text 
                    x="150" 
                    y="30" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#296BED',
                      fontFamily: 'cursive',
                      fontSize: '24px',
                      fontStyle: 'italic',
                      filter: 'url(#glow1)'
                    }}
                  >
                    ~ Trevor Larsen
                  </text>
                  <text 
                    x="150" 
                    y="50" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '14px',
                      letterSpacing: '0.05em'
                    }}
                  >
                    Clever Investor
                  </text>
                </svg>
              }
            />
            <TestimonialCard
              image="/Andy_Bouchie.png"
              name=""
              role=""
              company=""
              stars={5}
              quote={"We were in search of a company to come in and get our email marketing back on track after parting ways with an agency. We needed to get our open rates up, optimize our list, and get our deals in front of our customers again.\n\nChuck came on board for a 2-week project to clean up our list, and get us out of spam. I gave him the freedom to do whatever he needed to do to get us healthy again. And within days, he was delivering.\n\nThe biggest thing I respected about him and his work, is that it was not done with his mouth like so many marketers today, he delivered results. Incredibly humble and confident in his work.\n\nWe went from 2-3% open rates, to dramatically breaking down doors within as little as 2 weeks, as high as 25% with Chuck manning our campaigns.\n\nAlthough he was hired for a short two-week project, he has now been on board for 3 months and counting... Every current project I have, and any plans in the future will not go forward without Chuck.\n\nA great asset to anyone looking to take their company to the next level, Chuck has my full vote of confidence in whatever he's touching."}
              signature={
                <svg width="300" height="60" className="mx-auto">
                  <defs>
                    <linearGradient id="signatureGradient2" x1="0%" y1="0%" x2="100%" y2="0%">
                      <stop offset="0%" style={{ stopColor: '#60A5FA', stopOpacity: 0.8 }} />
                      <stop offset="100%" style={{ stopColor: '#2DD4BF', stopOpacity: 0.8 }} />
                    </linearGradient>
                    <filter id="glow2">
                      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>
                  <text 
                    x="150" 
                    y="30" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#296BED',
                      fontFamily: 'cursive',
                      fontSize: '24px',
                      fontStyle: 'italic',
                      filter: 'url(#glow2)'
                    }}
                  >
                    ~ Andy Bouchie
                  </text>
                  <text 
                    x="150" 
                    y="50" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '14px',
                      letterSpacing: '0.05em'
                    }}
                  >
                    Town Vapor
                  </text>
                </svg>
              }
            />
            <TestimonialCard
              image="/Keala Kanae.png"
              name=""
              role=""
              company=""
              stars={5}
              quote={"Chuck costs nothing to work with because he more than pays for himself by the value he brings to the team.\n\nWe were making millions per month with our email marketing and thought we \"knew it all\" until Chuck arrived.\n\nHis years of experience and genius poured fuel on the fire and had our team performing at levels that would have otherwise taken years to develop.\n\nIf you have the chance, grab him."}
              signature={
                <svg width="300" height="100" className="mx-auto">
                  <defs>
                    <linearGradient id="signatureGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                      <stop offset="0%" style={{ stopColor: '#60A5FA', stopOpacity: 0.8 }} />
                      <stop offset="100%" style={{ stopColor: '#2DD4BF', stopOpacity: 0.8 }} />
                    </linearGradient>
                    <filter id="glow">
                      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>
                  <text 
                    x="150" 
                    y="30" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#296BED',
                      fontFamily: 'cursive',
                      fontSize: '24px',
                      fontStyle: 'italic',
                      filter: 'url(#glow)'
                    }}
                  >
                    ~ Keala Kanae
                  </text>
                  <text 
                    x="150" 
                    y="55" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '12px',
                      letterSpacing: '0.05em'
                    }}
                  >
                    Founder and CEO | Fullstaq Marketer
                  </text>
                  <text 
                    x="150" 
                    y="75" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '12px',
                      letterSpacing: '0.05em'
                    }}
                  >
                    Previous Cofounder and CEO | AWOL
                  </text>
                  <text 
                    x="150" 
                    y="95" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '11px',
                      letterSpacing: '0.05em',
                      fontStyle: 'italic'
                    }}
                  >
                    $100M+ in Email Revenue
                  </text>
                </svg>
              }
            />
            <TestimonialCard
              image="/aidan_profile.png"
              name=""
              role=""
              company=""
              stars={5}
              quote={"Having personally worked with Chuck for several years, I can say that he has helped improve our email deliverability enormously, as well as all of the best practices we apply to our email marketing today.\n\nChuck has his finger on the pulse with all things email, from the technical side, to the strategic, and from legacy technology to cutting edge AI... he's all over it.\n\nWhether Chuck is meticulously pouring over email data, executing a deliverability plan for a specific campaign, or re-engaging subscribers, you can be 100% certain that he's going to deliver an A+\n\n\n\n\n"}
              signature={
                <svg width="300" height="60" className="mx-auto">
                  <defs>
                    <linearGradient id="signatureGradient4" x1="0%" y1="0%" x2="100%" y2="0%">
                      <stop offset="0%" style={{ stopColor: '#60A5FA', stopOpacity: 0.8 }} />
                      <stop offset="100%" style={{ stopColor: '#2DD4BF', stopOpacity: 0.8 }} />
                    </linearGradient>
                    <filter id="glow4">
                      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>
                  <text 
                    x="150" 
                    y="30" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#296BED',
                      fontFamily: 'cursive',
                      fontSize: '24px',
                      fontStyle: 'italic',
                      filter: 'url(#glow4)'
                    }}
                  >
                    ~ Aidan Booth
                  </text>
                  <text 
                    x="150" 
                    y="50" 
                    textAnchor="middle" 
                    style={{ 
                      fill: '#9CA3AF',
                      fontSize: '14px',
                      letterSpacing: '0.05em'
                    }}
                  >
                    Blueprint Information
                  </text>
                </svg>
              }
            />
          </div>
        </div>
      </div>

      {/* Services Grid */}
      <div className="relative" id="services">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-4xl font-bold mb-6 text-[#296BED]">
              Our Services
            </h2>
            <p className="text-gray-400 text-lg">Comprehensive email marketing solutions designed to drive business growth</p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard
              title="Strategy Development"
              description="Custom email marketing strategies aligned with your business goals and target audience."
            />
            <FeatureCard
              title="Inbox Deliverability"
              description="Advanced authentication setup, reputation monitoring, and infrastructure optimization to ensure your emails reach the inbox, not spam."
            />
            <FeatureCard
              title="List Management"
              description="Advanced segmentation and list hygiene practices to improve deliverability and engagement."
            />
            <FeatureCard
              title="Automation Setup"
              description="Design and implementation of automated email sequences that nurture leads and drive sales."
            />
            <FeatureCard
              title="Copy & Design"
              description="Compelling email copy and design that resonates with your audience and drives action."
            />
            <FeatureCard
              title="Training & Support"
              description="Comprehensive training and ongoing support for your internal marketing team."
            />
          </div>
        </div>

        {/* Background Elements */}
        <div className="absolute inset-0 -z-10 h-full w-full bg-black">
          <div className="absolute h-full w-full bg-[radial-gradient(#ffffff15_1px,transparent_1px)] [background-size:16px_16px]" />
        </div>
      </div>

      {/* Stats Section */}
      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center max-w-2xl mx-auto">
            <div className="text-4xl font-bold text-[#296BED] mb-2">More than 2B+</div>
            <div className="text-gray-400">Emails Optimized</div>
          </div>
        </div>
      </div>

      {/* FAQ Section */}
      <div className="border-t border-white/10 scroll-mt-32" id="faq">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-6 text-[#296BED]">
              Frequently Asked Questions
            </h2>
            <p className="text-gray-400">
              Everything you need to know about our email audit and optimization services
            </p>
          </div>
          
          <div className="space-y-6">
            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq1')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">What is an email audit, and how does it benefit my business?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq1' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq1' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  An email audit is a thorough, data-driven examination of every aspect of your email marketing—from deliverability and domain reputation to content strategy, list segmentation, and automation workflows. By digging into both the technical and creative elements of your campaigns, we uncover any hidden issues that could be harming your sender reputation or reducing engagement. Once these issues are identified, we provide concrete recommendations tailored to your business to boost open rates, click-throughs, and conversions. With more than 20 years of experience in email marketing and inbox deliverability, our team at Expert.Email ensures that every campaign you send not only lands in the right inbox but also drives measurable growth for your business.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq2')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">How long does it take to complete an email audit?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq2' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq2' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  24-48 hours after our meeting. Schedule now by clicking "Secure your Free Audit Now" above or below.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq3')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">What information do I need to provide for the email audit?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq3' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq3' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  This depends on your specific circumstances. This will all be discussed during our Audit meeting. Schedule now by clicking "Secure your Free Audit Now" above or below.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq4')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">How much does the email audit cost?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq4' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq4' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  The initial audit is completely free. Schedule now by clicking "Secure your Free Audit Now" above or below.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq5')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">What email platforms do you work with?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq5' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq5' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  We can work with any email marketing platform—ranging from popular providers like Mailchimp, Klaviyo, ActiveCampaign, Constant Contact, Kit, and HubSpot, to more specialized or custom enterprise solutions. With over 20 years of experience in email marketing and inbox deliverability, our team at Expert.Email has developed direct expertise with most platforms on the market. This means we can seamlessly integrate into your current setup or recommend the best fit for your unique business goals.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq6')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">Can you help with email deliverability issues?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq6' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq6' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  Absolutely! With over 20 years of specialized inbox deliverability experience, Expert.Email helps ensure your messages reach the right inbox by fixing technical issues (SPF, DKIM, DMARC), optimizing sender reputation, and monitoring potential blacklists. We also provide guidance on IP warming, email content best practices, and sending frequency—so you see higher open rates, stronger engagement, and ultimately, better ROI on every campaign.
                </div>
              )}
            </div>

            <div 
              className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl hover:border-white/20 transition-all duration-300"
              onClick={() => handleFaqClick('faq7')}
            >
              <div className="p-6 flex items-center justify-between cursor-pointer">
                <h3 className="text-xl font-semibold text-white pr-6">Can you help with email list management and segmentation?</h3>
                <div className="text-blue-400 flex-shrink-0">
                  {expandedFaq === 'faq7' ? (
                    <Minus className="w-6 h-6" />
                  ) : (
                    <Plus className="w-6 h-6" />
                  )}
                </div>
              </div>
              {expandedFaq === 'faq7' && (
                <div className="px-6 pb-6 text-gray-400 border-t border-white/10 pt-4">
                  Absolutely. Our team at Expert.Email draws on 20+ years of experience to optimize your subscriber data, ensuring each segment is accurately tailored to its audience's interests and engagement patterns. By refining your lists and creating personalized segments, we help boost open rates, click-throughs, and conversions—ultimately getting your message to the right people at the right time, every time.
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Contact Section */}
      <div className="border-t border-white/10" id="contact">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16 text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 backdrop-blur-xl border border-white/10 mb-8">
            <span className="text-blue-400">Limited Time</span>
            <span className="w-1 h-1 rounded-full bg-white/20"></span>
            <span className="text-gray-300">Private Strategy Session</span>
          </div>
          
          <h2 className="text-4xl font-bold mb-8">Ready to Transform Your Email Marketing?</h2>
          <p className="text-gray-400 mb-12">
            Schedule a free consultation to discuss how we can help you achieve your email marketing goals.
          </p>
          <button
            onClick={() => window.open('https://cal.com/chuck-mullaney-s0dslw/consultation', '_blank')}
            className="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-10 py-5 rounded-xl inline-flex items-center gap-3 hover:from-blue-600 hover:to-blue-700 transition-all duration-300 mx-auto"
          >
            <span className="flex items-center gap-3 text-lg font-semibold tracking-wide">
              Get Started Now
              <ArrowRight className="w-4 h-4" />
            </span>
          </button>
          <p className="text-blue-400 font-medium mt-3 animate-pulse">Limited spots available</p>
        </div>
      </div>

      {/* Calendar Section */}
      {showCalendarSection && (
        <div 
          ref={calendarRef}
          className="border-t border-white/10 bg-gradient-to-b from-black to-blue-950/50 overflow-x-hidden"
        >
          <div className="max-w-7xl mx-auto px-2 sm:px-6 lg:px-8 py-12 sm:py-24">
            <div className="text-center max-w-3xl mx-auto mb-8 sm:mb-12">
              <h2 className="text-4xl font-bold mb-4 text-[#296BED]">
                Schedule Your Free Strategy Session
              </h2>
              <p className="text-gray-400 text-sm sm:text-base px-4">
                Choose a time that works best for you. We'll discuss your email marketing goals and create a customized plan to help you achieve them.
              </p>
            </div>
            
            <div className="bg-black/50 backdrop-blur-sm border border-white/10 rounded-xl sm:rounded-2xl overflow-hidden shadow-xl">
              <iframe
                src="https://clinquant-wisp-caed10.netlify.app/"
                className="w-full h-[600px] sm:h-[800px] scale-[0.97] sm:scale-100"
                frameBorder="0"
                title="Scheduling Calendar"
                loading="lazy"
              />
            </div>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="border-t border-white/10 bg-black/50 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex flex-col items-center gap-4">
            <div className="flex items-center gap-3">
              <div className="relative group">
                <div className="absolute -inset-2 bg-gradient-to-r from-blue-600 to-teal-600 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-200"></div>
                <div className="relative bg-black rounded-lg p-2.5 ring-1 ring-white/10 group-hover:ring-white/20 transition duration-200">
                  <Mail className="w-6 h-6 text-[#2B6CEE] group-hover:text-[#2B6CEE]/80 transition-colors" />
                </div>
              </div>
              <span className="text-lg font-bold text-white">
                Expert.Email<sup className="text-[0.6em]">™</sup>
              </span>
            </div>
            <a 
              href="https://email-consultant-97.aura.build/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-sm text-gray-400 hover:text-white transition-colors"
            >
              by: Operational Advantages
            </a>
            <div className="text-sm text-gray-400">
              Copyright © 2025 All Rights Reserved
            </div>
            <Link 
              to="/terms" 
              className="text-sm text-gray-400 hover:text-white transition-colors"
            >
              Terms of Service
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;