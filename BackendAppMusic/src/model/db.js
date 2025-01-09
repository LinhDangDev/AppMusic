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
  keepAliveInitialDelay: 0
});

const maxRetries = 5;
const retryDelay = 5000; // 5 seconds

const connectWithRetry = async () => {
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const connection = await pool.getConnection();
      console.log('Database connected successfully');
      connection.release();
      return true;
    } catch (err) {
      retries++;
      console.log(`Failed to connect to database (${retries}/${maxRetries}). Retrying in ${retryDelay/1000}s...`);
      await new Promise(resolve => setTimeout(resolve, retryDelay));
    }
  }
  
  console.error('Failed to connect to database after maximum retries');
  return false;
};

// Khởi tạo kết nối
connectWithRetry().catch(console.error);

export { pool as default, connectWithRetry };