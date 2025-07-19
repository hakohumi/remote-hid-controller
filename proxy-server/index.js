const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();

// すべてのパスのアクセスログを出力
app.use((req, res, next) => {
  if (req.path.startsWith('/')) {
    console.log(`[${new Date().toISOString()}] アクセス: ${req.method} ${req.originalUrl}`);
  }
  next();
});

// 静的ファイル（HTMLなど）
app.use(express.static(path.join(__dirname, 'public')));

// // / にアクセスされたら HTML を返す
app.get('/test', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/test.html'));
});

// APIリクエストをプロキシ（/a や /d などすべて許可）
app.use('/', createProxyMiddleware({
  target: 'http://192.168.1.31:8080/',
  changeOrigin: true,
}));



app.listen(23235, () => {
  console.log('✅ Server running at: http://filu.xyz:23235');
});