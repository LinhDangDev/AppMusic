import pool from '../config/database';

/**
 * Initialization Service - handles application startup tasks
 */
class InitService {
    /**
     * Initialize application data
     */
    public async initializeData(): Promise<void> {
        try {
            console.log('Initializing application data...');
            // Add initialization logic here (seeds, migrations, etc.)
            console.log('Application data initialized successfully');
        } catch (error) {
            console.error('Failed to initialize application data:', error);
            throw error;
        }
    }

    /**
     * Check database health
     */
    public async checkDatabaseHealth(): Promise<boolean> {
        try {
            const result = await (pool as any).query('SELECT NOW()');
            return result.rowCount === 1;
        } catch (error) {
            console.error('Database health check failed:', error);
            return false;
        }
    }
}

export default new InitService();
