import React, { useState } from 'react';
import { Star, ChevronDown, ChevronUp } from 'lucide-react';

export interface TestimonialCardProps {
  image: string;
  name: string;
  role: string;
  company: string;
  stars: number;
  quote: string;
  signature?: React.ReactNode;
}

export function TestimonialCard({ image, name, role, company, stars, quote, signature }: TestimonialCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className="group relative bg-white/5 backdrop-blur-xl border border-white/10 p-4 rounded-2xl hover:border-white/20 transition-all duration-300">
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-500/10 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
      <div className="relative flex flex-col items-center text-center">
        <div className="relative mb-3">
          <div className="absolute inset-0 rounded-full bg-[#296BED] blur-lg opacity-50 group-hover:opacity-75 transition-opacity" />
          <img
            src={image}
            alt={name || 'Testimonial author'}
            className="relative w-16 h-16 rounded-full object-cover border-2 border-white/20"
          />
        </div>
        <div className="flex gap-1 text-yellow-400 mb-2">
          {[...Array(stars)].map((_, i) => (
            <Star key={i} className="w-4 h-4 fill-current" />
          ))}
        </div>
        <div className="relative">
          <p className={`text-gray-300 mb-3 italic whitespace-pre-line text-sm leading-relaxed ${isExpanded ? '' : 'line-clamp-6'}`}>
            "{quote}"
          </p>
          {quote.split('\n').length > 6 && (
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="inline-flex items-center gap-1 text-white hover:text-gray-300 transition-colors text-sm font-medium mt-1"
            >
              {isExpanded ? (
                <>
                  Show Less
                  <ChevronUp className="w-4 h-4" />
                </>
              ) : (
                <>
                  Read More
                  <ChevronDown className="w-4 h-4" />
                </>
              )}
            </button>
          )}
        </div>
        <div className="mt-auto">
          {name && <h4 className="font-semibold text-white">{name}</h4>}
          {role && <p className="text-sm text-gray-400">{role}</p>}
          {company && <p className="text-sm text-blue-400">{company}</p>}
          {signature && <div className="mt-2 scale-75 origin-top">{signature}</div>}
        </div>
      </div>
    </div>
  );
}