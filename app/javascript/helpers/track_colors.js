// Paul Tol's qualitative "rainbow" scheme, as popularised by the google-palette
// package ('tol-rainbow'). Returns `count` evenly spaced colours as '#rrggbb'.
// See https://personal.sron.nl/~pault/ (Figure 13 polynomial fit).

const poly = (x, ...coefficients) => coefficients.reduceRight((acc, c) => acc * x + c, 0)

const channel = v => Math.round(Math.min(Math.max(v, 0), 1) * 255).toString(16).padStart(2, '0')

const tolRainbow = x => {
  const r = poly(x, 0.472, -0.567, 4.05) / poly(x, 1, 8.72, -19.17, 14.1)
  const g = poly(x, 0.108932, -1.22635, 27.284, -98.577, 163.3, -131.395, 40.634)
  const b = 1 / poly(x, 1.97, 3.54, -68.5, 243, -297, 125)
  return '#' + channel(r) + channel(g) + channel(b)
}

export function trackColors(count) {
  if (count < 1) return []
  if (count < 2) return [tolRainbow(0)]

  return Array.from({length: count}, (_, i) => tolRainbow(i / (count - 1)))
}
