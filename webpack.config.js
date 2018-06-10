const path = require("path");
const webpack = require("webpack");
const bundlePath = path.resolve(__dirname, "./Public/js/dist/");

module.exports = {
    entry: "./Public/js/index.js",
    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel-loader',
                options: { presets: ['env'] }
            },
            {
                test: /\.css$/,
                use: [ 'style-loader', 'css-loader' ]
            }
        ]
    },
    resolve: { extensions: ['*', '.js', '.jsx'] },
    output: {
        publicPath: "js/dist/",
        path: bundlePath,
        filename: "bundle.js"
    },
    devServer: {
        contentBase: path.join(__dirname,'public'),
        port: 3000,
        publicPath: "http://localhost:3000/js/dist"
    },
    plugins: [ new webpack.HotModuleReplacementPlugin() ]
};
