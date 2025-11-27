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
  ignoreWarnings: [
    {
      module: /tailwind\.js/
    },
  ]
}

module.exports = merge(webpackConfig, customConfig)
