const path = require('path');
const WebpackAssetsManifest = require('webpack-assets-manifest');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const { NODE_ENV } = process.env;
const isProd = NODE_ENV === 'production';

module.exports = {
  mode: isProd ? 'production' : 'development',
  devtool: 'source-map',
  entry: {
    application: path.resolve(__dirname, 'app/javascript/packs/application.js'),
  },
  output: {
    path: path.resolve(__dirname, 'public/packs'),
    publicPath: process.env.USE_WEBPACK_DEV_SERVER === '1' ? '//localhost:3035/packs/' : '/packs/',
    filename: '[name]-[chunkhash].js',
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
        ],
      },
    ],
  },
  resolve: {
    extensions: ['.js', '.css'],
    alias: {
    },
  },
  devServer: {
    devMiddleware: {
      publicPath: '/packs/',
    },
    host: 'localhost',
    port: 3035,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
  plugins: [
    new WebpackAssetsManifest({
      publicPath: true,
      writeToDisk: true,
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    new MiniCssExtractPlugin({
      filename: '[name]-[contenthash].css',
    }),
  ],
};

