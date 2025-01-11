import axios from 'axios';
import db from '../model/db.js';
import puppeteer from 'puppeteer';

class LyricsService {
  constructor() {
    this.geniusApi = axios.create({
      baseURL: 'https://api.genius.com',
      headers: {
        'Authorization': `Bearer pqzcNM_eJnPyA5ybjQLEF_gkGQqW4BttRonPlYuT0Lhckas1fN_k_P3aEy--pk_t`
      }
    });
  }

  // Tìm kiếm bài hát trên Genius
  async searchSong(title, artist) {
    try {
      const response = await this.geniusApi.get('/search', {
        params: { q: `${title} ${artist}` }
      });
      return response.data.response.hits[0]?.result || null;
    } catch (error) {
      console.error('Genius search error:', error);
      return null;
    }
  }

  // Lấy lời bài hát từ Genius
  async getLyrics(geniusId) {
    try {
      const response = await this.geniusApi.get(`/songs/${geniusId}`);
      return response.data.response.song.lyrics;
    } catch (error) {
      console.error('Genius lyrics error:', error);
      return null;
    }
  }

  // Cập nhật lời bài hát trong database
  async updateLyrics(musicId) {
    try {
      const [music] = await db.execute(
        'SELECT m.title, a.name as artist FROM Music m JOIN Artists a ON m.artist_id = a.id WHERE m.id = ?',
        [musicId]
      );

      if (!music) return null;

      // Thử scrape lyrics
      const lyrics = await this.scrapeLyrics(music.title, music.artist);
      
      if (lyrics) {
        await db.execute(
          'UPDATE Music SET lyrics = ?, lyrics_state = "FOUND" WHERE id = ?',
          [lyrics, musicId]
        );
        return lyrics;
      }

      await db.execute(
        'UPDATE Music SET lyrics_state = "NOT_FOUND" WHERE id = ?',
        [musicId]
      );
      return null;

    } catch (error) {
      console.error('Error updating lyrics:', error);
      return null;
    }
  }

  // Cập nhật hàng loạt
  async updateBatchLyrics(limit = 10) {
    try {
      const [songs] = await db.execute(`
        SELECT id FROM Music 
        WHERE lyrics IS NULL 
        AND lyrics_state = 'PENDING'
        LIMIT ?
      `, [limit]);

      for (const song of songs) {
        await this.updateLyrics(song.id);
        // Delay để tránh rate limit
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    } catch (error) {
      console.error('Batch update error:', error);
    }
  }

  async scrapeLyrics(title, artist) {
    try {
      // Danh sách các trang lyrics để scrape
      const lyricsSites = [
        {
          url: `https://www.azlyrics.com/lyrics/${artist}/${title}.html`,
          selector: '.ringtone ~ div'
        },
        {
          url: `https://www.lyrics.com/lyric/${artist}/${title}`, 
          selector: '#lyric-body-text'
        },
        {
          url: `https://www.musixmatch.com/lyrics/${artist}/${title}`,
          selector: '.mxm-lyrics__content'
        }
      ];

      // Thử scrape từng trang cho đến khi tìm được lyrics
      for (const site of lyricsSites) {
        const browser = await puppeteer.launch({headless: true});
        const page = await browser.newPage();
        
        await page.goto(site.url, {waitUntil: 'networkidle0'});
        
        const lyrics = await page.evaluate((selector) => {
          const element = document.querySelector(selector);
          return element ? element.innerText : null;
        }, site.selector);

        await browser.close();

        if (lyrics) {
          return lyrics;
        }
      }

      return null;
    } catch (error) {
      console.error('Error scraping lyrics:', error);
      return null; 
    }
  }

  async searchLocalDatabase(title, artist) {
    const [rows] = await db.execute(
      `SELECT lyrics FROM Lyrics_Database 
       WHERE MATCH(title, artist) AGAINST(? IN NATURAL LANGUAGE MODE)
       LIMIT 1`,
      [`${title} ${artist}`]
    );
    return rows[0]?.lyrics || null;
  }
}

export default new LyricsService();
