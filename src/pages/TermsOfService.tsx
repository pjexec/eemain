import React, { useEffect } from 'react';
import { ArrowLeft, Mail } from 'lucide-react';
import { Link } from 'react-router-dom';

export function TermsOfService() {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div className="min-h-screen bg-black text-white">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 px-2 py-2 sm:px-4 sm:py-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-white/10 backdrop-blur-xl border border-white/10 rounded-xl sm:rounded-2xl px-3 py-2.5 sm:px-6 sm:py-4">
            <div className="flex items-center justify-between">
              <Link 
                to="/" 
                className="flex items-center gap-3"
              >
                <div className="relative group">
                  <div className="absolute -inset-2 bg-gradient-to-r from-blue-600 to-teal-600 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-200"></div>
                  <div className="relative bg-black/50 backdrop-blur-xl rounded-lg p-3 sm:p-2.5 ring-1 ring-white/10 group-hover:ring-white/20 transition duration-200">
                    <Mail className="w-7 h-7 sm:w-7 sm:h-7 text-blue-400 group-hover:text-blue-300 transition-colors" />
                  </div>
                </div>
                <div>
                  <span className="text-xl sm:text-xl font-bold bg-gradient-to-r from-blue-400 via-blue-200 to-teal-400 bg-clip-text text-transparent">
                    Expert.Email
                  </span>
                  <span className="hidden sm:block text-xs text-gray-400 font-medium">
                    Deliverability Experts
                  </span>
                </div>
              </Link>

              <Link 
                to="/" 
                className="inline-flex items-center gap-2 text-gray-400 hover:text-white transition-colors"
              >
                <ArrowLeft className="w-4 h-4" />
                Back to Home
              </Link>
            </div>
          </div>
        </div>
      </header>

      {/* Content - Added padding-top to account for fixed header */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 pt-32">
        <h1 className="text-4xl font-bold mb-8 bg-gradient-to-r from-blue-400 to-teal-400 bg-clip-text text-transparent">
          Terms of Service
        </h1>

        <div className="prose prose-invert prose-blue max-w-none">
          <p className="text-gray-400 mb-8">
            Last updated: February 6, 2025
          </p>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">1. Introduction</h2>
            <p className="text-gray-300 mb-4">
              Welcome to Expert.Email. By accessing our website and using our services, you agree to these terms of service. Please read them carefully.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">2. Services</h2>
            <p className="text-gray-300 mb-4">
              Expert.Email provides email marketing and deliverability consulting services. Our services include but are not limited to strategy development, inbox deliverability optimization, list management, automation setup, and training.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">3. User Responsibilities</h2>
            <p className="text-gray-300 mb-4">
              Users of our services agree to:
            </p>
            <ul className="list-disc pl-6 text-gray-300 space-y-2 mb-4">
              <li>Provide accurate and complete information</li>
              <li>Maintain the confidentiality of any account credentials</li>
              <li>Comply with all applicable laws and regulations</li>
              <li>Use our services in an ethical and responsible manner</li>
            </ul>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">4. Privacy and Data Protection</h2>
            <p className="text-gray-300 mb-4">
              We take your privacy seriously. Our handling of your personal data is governed by our Privacy Policy, which is incorporated into these Terms of Service by reference.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">5. Intellectual Property</h2>
            <p className="text-gray-300 mb-4">
              All content, features, and functionality of our services, including but not limited to text, graphics, logos, and software, are owned by Expert.Email and are protected by intellectual property laws.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">6. Limitation of Liability</h2>
            <p className="text-gray-300 mb-4">
              Expert.Email shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of our services.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-2xl font-semibold mb-4">7. Changes to Terms</h2>
            <p className="text-gray-300 mb-4">
              We reserve the right to modify these terms at any time. We will notify users of any material changes via email or through our website.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4">8. Contact Information</h2>
            <p className="text-gray-300">
              For questions about these Terms of Service, please contact us through our website.
            </p>
          </section>
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-white/10 bg-black/50 backdrop-blur-xl mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <p className="text-center text-sm text-gray-400">
            © 2025 Expert.Email. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}