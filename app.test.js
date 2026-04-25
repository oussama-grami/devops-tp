const request = require('supertest');
const app = require('./app');

describe('GET /', () => {
  it('responds with status ok', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /health', () => {
  it('returns healthy', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
  });
});
