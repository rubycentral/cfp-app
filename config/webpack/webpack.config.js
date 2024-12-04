const { webpackConfig, merge } = require('shakapacker')

const customConfig = {
  resolve: {
    extensions: [
      '.mjs',
      '.js',
      '.sass',
      '.scss',
      '.css',
      '.module.sass',
      '.module.scss',
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
