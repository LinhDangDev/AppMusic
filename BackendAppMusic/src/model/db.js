import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'appmusic',
  password: process.env.DB_PASSWORD || 'appmusic123',
  database: process.env.DB_NAME || 'app_music',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Unexpected PostgreSQL pool error:', err);
});

const connectWithRetry = async (retries = 5, delay = 5000) => {
  for (let i = 0; i < retries; i++) {
    try {
      const client = await pool.connect();
      console.log('✅ PostgreSQL Database connected successfully');
      client.release();
      return pool;
    } catch (err) {
      console.error(`❌ Database connection attempt ${i + 1} failed:`, err.message);
      if (i === retries - 1) throw err;
      console.log(`Retrying in ${delay/1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
};

// Adapter methods for MySQL-like interface
pool.execute = async (text, params) => {
  const result = await pool.query(text, params);
  return [result.rows, result.fields];
};

export { pool as default, connectWithRetry };
