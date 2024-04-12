const Dotenv = require('dotenv-webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const path = require('path');

module.exports = (env) => {

  console.log('env: ', env)
  console.log('process.env: ', process.env)

  return {
    entry: './src/index.js',
    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: 'bundle.js'
    },
    stats: 'verbose',
    devServer: {
      static: {
        directory: path.join(__dirname, 'dist'),
      },
      compress: true,
      port: 3000,
      allowedHosts: 'all',
      client: {
        logging: 'verbose',
        overlay: true,
      },
      proxy: [
        {
          context: ['/api'],
          target: process.env.BACKEND_URL || 'http://localhost:7071',
        },
      ],
    },
    module: {
      rules: [
        {
          test: /\.css$/i,
          use: ['style-loader', 'css-loader'],
        },
        {
          "test": /\.js$/,
          "exclude": /node_modules/,
          "use": {
            "loader": "babel-loader",
            "options": {
              "presets": [
                "@babel/preset-env",
              ]
            }
          }
        }
      ]
    },
    plugins: [
      new Dotenv({
        systemvars: true
      }),
      new CopyWebpackPlugin({
        patterns: [
          { from: './src/favicon.ico', to: './' },
          { from: './index.html', to: './' }
        ],
      })
    ]
  }
}
