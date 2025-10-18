import Redis from 'ioredis';

interface CacheServiceType {
    redis: Redis;
    get: (key: string) => Promise<any>;
    set: (key: string, value: any, ttl?: number) => Promise<void>;
    del: (key: string) => Promise<void>;
}

class CacheService implements CacheServiceType {
    redis: Redis;

    constructor() {
        this.redis = new Redis({
            host: process.env.REDIS_HOST || 'localhost',
            port: parseInt(process.env.REDIS_PORT || '6379'),
            password: process.env.REDIS_PASSWORD || undefined,
            retryStrategy: (times: number) => {
                const delay = Math.min(times * 50, 2000);
                return delay;
            },
            maxRetriesPerRequest: 1
        });

        this.redis.on('error', (err: Error) => {
            console.error('Redis error:', err.message);
        });

        this.redis.on('connect', () => {
            console.log('✅ Redis connected successfully');
        });
    }

    async get(key: string): Promise<any> {
        try {
            const value = await this.redis.get(key);
            return value ? JSON.parse(value) : null;
        } catch (error) {
            console.error(`Error getting cache key ${key}:`, error);
            return null;
        }
    }

    async set(key: string, value: any, ttl: number = 3600): Promise<void> {
        try {
            await this.redis.set(key, JSON.stringify(value), 'EX', ttl);
        } catch (error) {
            console.error(`Error setting cache key ${key}:`, error);
        }
    }

    async del(key: string): Promise<void> {
        try {
            await this.redis.del(key);
        } catch (error) {
            console.error(`Error deleting cache key ${key}:`, error);
        }
    }
}

export default new CacheService();
