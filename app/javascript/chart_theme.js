import Chartkick from "chartkick"
import Chart from "chart.js/auto"

// Chart.js paints on a canvas and takes its colours from options, not CSS, so it
// doesn't follow data-bs-theme on its own. Read the theme's variables, set them as
// Chart.js defaults and redraw every chart on the page; repeat whenever the theme
// toggle fires `theme:changed`.

// Resolve a custom property to a plain #rrggbb string. getComputedStyle(...).getPropertyValue
// would return the unevaluated token stream, and the computed colour of an element may
// come back in a modern notation like hsl(none 0% 20%) that Chart.js's parser doesn't
// read, so the value is normalised through a canvas context.
const canvas = document.createElement('canvas').getContext('2d')

function cssColor(variable) {
  const probe = document.createElement('span')
  probe.style.color = `var(${variable})`
  document.body.appendChild(probe)
  canvas.fillStyle = getComputedStyle(probe).color
  probe.remove()
  return canvas.fillStyle
}

// Light mode keeps Chart.js's own defaults, so nothing changes there.
const lightDefaults = {color: Chart.defaults.color, borderColor: Chart.defaults.borderColor}

function applyChartTheme() {
  const dark = document.documentElement.dataset.bsTheme === 'dark'
  Chart.defaults.color = dark ? cssColor('--text-color') : lightDefaults.color
  Chart.defaults.borderColor = dark ? cssColor('--border-color') : lightDefaults.borderColor
  return dark
}

// Charts are created on chartkick:load, which fires while chartkick itself is imported,
// i.e. before this module runs with the light defaults; redraw only when dark changed them.
if (applyChartTheme()) Chartkick.eachChart(chart => chart.redraw())

window.addEventListener('theme:changed', () => {
  applyChartTheme()
  Chartkick.eachChart(chart => chart.redraw())
})
