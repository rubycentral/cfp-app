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
  }
}

module.exports = merge(webpackConfig, customConfig)
