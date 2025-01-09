import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'mysql',
  user: process.env.DB_USER || 'appmusic',
  password: process.env.DB_PASSWORD || 'appmusic123',
  database: process.env.DB_NAME || 'app_music',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  acquireTimeout: 60000
});

// Thêm retry logic
const maxRetries = 5;
let retries = 0;

const connectWithRetry = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('Database connected successfully');
    connection.release();
  } catch (err) {
    if (retries < maxRetries) {
      retries++;
      console.log(`Retrying database connection (${retries}/${maxRetries})...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
      await connectWithRetry();
    } else {
      console.error('Failed to connect to database after retries:', err);
      process.exit(1);
    }
  }
};

connectWithRetry();

export default pool;