const request = require('supertest');
const app = require('../src/app');

// Helper function to generate random credentials
const generateCredentials = () => {
    const random = Math.random().toString(36).substring(7);
    return {
        email: `test_${random}@example.com`,
        password: `password_${random}`,
        name: `Test User ${random}`
    };
};

let token;
let credentials;
let playlistId;
let musicId;

describe('Auth API', () => {
    beforeAll(() => {
        credentials = generateCredentials();
    });

    it('should register a new user', async () => {
        const res = await request(app)
            .post('/api/auth/register')
            .send(credentials);
        expect(res.statusCode).toBe(201);
        expect(res.body).toHaveProperty('message', 'User registered successfully');
    });

    it('should not register duplicate user', async () => {
        const res = await request(app)
            .post('/api/auth/register')
            .send(credentials);
        expect(res.statusCode).toBe(400);
    });

    it('should login user', async () => {
        const res = await request(app)
            .post('/api/auth/login')
            .send({
                email: credentials.email,
                password: credentials.password
            });
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('token');
        token = res.body.token;
    });

    it('should not login with wrong password', async () => {
        const res = await request(app)
            .post('/api/auth/login')
            .send({
                email: credentials.email,
                password: 'wrongpassword'
            });
        expect(res.statusCode).toBe(401);
    });
});

describe('Music API', () => {
    it('should search music', async () => {
        const res = await request(app)
            .get('/api/music/search?q=test')
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body)).toBeTruthy();
        if (res.body.length > 0) {
            musicId = res.body[0].id;
        }
    });

    it('should get music by id', async () => {
        if (!musicId) {
            console.log('Skipping test: No music found');
            return;
        }
        const res = await request(app)
            .get(`/api/music/${musicId}`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });

    it('should get music stream', async () => {
        if (!musicId) {
            console.log('Skipping test: No music found');
            return;
        }
        const res = await request(app)
            .get(`/api/music/${musicId}/stream`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });

    it('should record play count', async () => {
        if (!musicId) {
            console.log('Skipping test: No music found');
            return;
        }
        const res = await request(app)
            .post(`/api/music/${musicId}/play`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });
});

describe('Playlist API', () => {
    it('should create playlist', async () => {
        const res = await request(app)
            .post('/api/playlists')
            .set('Authorization', `Bearer ${token}`)
            .send({
                name: 'My Test Playlist',
                description: 'Created during testing'
            });
        expect(res.statusCode).toBe(201);
        expect(res.body).toHaveProperty('id');
        playlistId = res.body.id;
    });

    it('should get all playlists', async () => {
        const res = await request(app)
            .get('/api/playlists')
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body)).toBeTruthy();
    });

    it('should get playlist by id', async () => {
        const res = await request(app)
            .get(`/api/playlists/${playlistId}`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });

    it('should add song to playlist', async () => {
        if (!musicId) {
            console.log('Skipping test: No music found');
            return;
        }
        const res = await request(app)
            .post(`/api/playlists/${playlistId}/songs`)
            .set('Authorization', `Bearer ${token}`)
            .send({ musicId });
        expect(res.statusCode).toBe(200);
    });

    it('should update playlist', async () => {
        const res = await request(app)
            .put(`/api/playlists/${playlistId}`)
            .set('Authorization', `Bearer ${token}`)
            .send({
                name: 'Updated Playlist Name',
                description: 'Updated description'
            });
        expect(res.statusCode).toBe(200);
    });

    it('should remove song from playlist', async () => {
        if (!musicId) {
            console.log('Skipping test: No music found');
            return;
        }
        const res = await request(app)
            .delete(`/api/playlists/${playlistId}/songs/${musicId}`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });

    it('should delete playlist', async () => {
        const res = await request(app)
            .delete(`/api/playlists/${playlistId}`)
            .set('Authorization', `Bearer ${token}`);
        expect(res.statusCode).toBe(200);
    });
});
