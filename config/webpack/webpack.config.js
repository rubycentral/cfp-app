const { webpackConfig, merge } = require('shakapacker')

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
  },
  ignoreWarnings: [
    {
      module: /tailwind\.js/
    },
  ]
}

module.exports = merge(webpackConfig, customConfig)
