const { webpackConfig, merge } = require('shakapacker')

// Remove babel-loader - modern browsers support ES6+ natively
webpackConfig.module.rules = webpackConfig.module.rules.map(rule => {
  if (rule.use && Array.isArray(rule.use)) {
    rule.use = rule.use.filter(loader => {
      const loaderName = typeof loader === 'string' ? loader : loader.loader
      return !loaderName || !loaderName.includes('babel-loader')
    })
  }
  return rule
}).filter(rule => {
  // Remove rules that only had babel-loader
  if (rule.use && Array.isArray(rule.use) && rule.use.length === 0) {
    return false
  }
  return true
})

const customConfig = {
  resolve: {
    extensions: [
      '.mjs',
      '.js',
      '.css',
      '.module.css',
      '.png',
      '.svg',
      '.gif',
      '.jpeg',
      '.jpg'
    ]
  },
  externals: {
    // Use jQuery from Sprockets (loaded via node_modules) as external
    jquery: 'jQuery'
  }
}

module.exports = merge(webpackConfig, customConfig)
