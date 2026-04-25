const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'DevOps TP App', version: '1.0' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

module.exports = app;

if (require.main === module) {
  app.listen(PORT, () => console.log(`App running on port ${PORT}`));
}
