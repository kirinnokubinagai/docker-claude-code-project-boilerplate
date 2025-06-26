const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3002;
const API_URL = process.env.API_URL || 'http://localhost:3003';

// APIプロキシ設定
app.use('/api', createProxyMiddleware({
  target: API_URL,
  changeOrigin: true,
  onError: (err, req, res) => {
    console.error('Proxy Error:', err);
    res.status(500).json({ error: 'Proxy Error', message: err.message });
  }
}));

// WebSocketプロキシ設定
app.use('/ws', createProxyMiddleware({
  target: API_URL,
  ws: true,
  changeOrigin: true
}));

// 静的ファイルの配信
app.use(express.static(path.join(__dirname, 'mcp-gateway/dist')));

// SPAのフォールバック
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'mcp-gateway/dist/index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`MCP Gateway Client running on port ${PORT}`);
  console.log(`Proxying API requests to ${API_URL}`);
});