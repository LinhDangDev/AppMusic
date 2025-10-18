import pkg from 'pg';
import { QueryResult } from 'pg';

const { Pool } = pkg;

export interface PoolWithExecute extends pkg.Pool {
    execute: (text: string, params?: any[]) => Promise<[any[], any]>;
}

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    user: process.env.DB_USER || 'appmusic',
    password: process.env.DB_PASSWORD || 'appmusic123',
    database: process.env.DB_NAME || 'app_music',
    max: 10, // maximum number of clients in the pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
}) as PoolWithExecute;

// PostgreSQL error handling
pool.on('error', (err: Error) => {
    console.error('Unexpected PostgreSQL pool error:', err.message);
});

const connectWithRetry = async (retries: number = 5, delay: number = 5000): Promise<PoolWithExecute> => {
    for (let i = 0; i < retries; i++) {
        try {
            const client = await pool.connect();
            console.log('✅ PostgreSQL Database connected successfully');
            client.release();
            return pool;
        } catch (err: any) {
            console.error(`❌ Database connection attempt ${i + 1} failed:`, err.message);
            if (i === retries - 1) throw err;
            console.log(`Retrying in ${delay / 1000} seconds...`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
    throw new Error('Failed to connect to database after all retries');
};

// Adapter for query execution to match MySQL-like interface
pool.execute = async (text: string, params?: any[]): Promise<[any[], any]> => {
    const result: QueryResult<any> = await pool.query(text, params);
    return [result.rows, result.fields];
};

export { pool as default, connectWithRetry };
