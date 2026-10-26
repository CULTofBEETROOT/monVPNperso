<svg xmlns="http://www.w3.org/2000/svg" width="700" height="120" viewBox="0 0 700 120">
  <defs>
    <linearGradient id="neon" x1="0" x2="1">
      <stop offset="0%" stop-color="#ff00cc"/>
      <stop offset="50%" stop-color="#00eaff"/>
      <stop offset="100%" stop-color="#b6ff00"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="4" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <rect width="100%" height="100%" fill="#101018"/>
  <text x="50%" y="58%" text-anchor="middle"
        font-family="Arial, sans-serif" font-size="54" font-weight="bold"
        fill="url(#neon)" stroke="url(#neon)" stroke-width="1"
        filter="url(#glow)">TitleExtravagant.com</text>
</svg>
