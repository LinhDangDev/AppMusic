import requests
import mysql.connector
from datetime import date
from bs4 import BeautifulSoup
import os
from urllib.parse import quote
from spotdl import Spotdl
from s3_handler import S3Handler
from pytube import YouTube
from pytube import Search
import re

def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",  # Replace with your MySQL username
        password="cntt15723",  # Replace with your MySQL password
        database="App_music"
    )

def get_lyrics(artist, title):
    # Using Genius API
    genius_access_token = "x6XNvEVqapdOwYpKeqTE0Yh5hmUevrYzXtV5BX91z2Hi_DiVxyF6iTQ5Qp4GDEqs"  # Get this from genius.com/api-clients
    base_url = "https://api.genius.com"
    headers = {'Authorization': f'Bearer {genius_access_token}'}

    # Clean up artist and title
    search_term = f"{artist} {title}".replace('&', 'and')

    try:
        # Search for the song
        search_url = f"{base_url}/search"
        response = requests.get(
            search_url,
            params={'q': search_term},
            headers=headers
        )

        if response.status_code == 200:
            data = response.json()
            if data['response']['hits']:
                # Get the first hit
                song_url = data['response']['hits'][0]['result']['url']

                # Scrape lyrics from Genius webpage
                page = requests.get(song_url)
                soup = BeautifulSoup(page.content, 'html.parser')
                lyrics_div = soup.find('div', class_='Lyrics__Container-sc-1ynbvzw-6')
                if lyrics_div:
                    lyrics = lyrics_div.get_text()
                    return lyrics.strip()
    except Exception as e:
        print(f"Error fetching lyrics: {str(e)}")

    return ''

def download_song(artist, title):
    try:
        if not os.path.exists('downloads'):
            os.makedirs('downloads')

        # Tạo search query
        search_query = f"{artist} {title} official audio"

        # Sử dụng youtube_dl để tải nhạc
        ydl_opts = {
            'format': 'bestaudio/best',
            'outtmpl': os.path.join('downloads', '%(title)s.%(ext)s'),
            'quiet': True,
        }

        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(search_query, download=False)
            if info:
                # Lấy URL của video đầu tiên
                video_url = info['entries'][0]['webpage_url']
                ydl.download([video_url])
                # Tìm file nhạc vừa tải về
                for file in os.listdir('downloads'):
                    if file.endswith('.mp3'):
                        return os.path.join('downloads', file)
        return None

    except Exception as e:
        print(f"Error downloading {artist} - {title}: {str(e)}")
        return None

def insert_song_data(db, artist_name, song_title, image_url, lyrics, s3_url):
    cursor = db.cursor()

    # Insert or get artist
    cursor.execute(
        "INSERT IGNORE INTO Artists (name) VALUES (%s)",
        (artist_name,)
    )
    db.commit()

    cursor.execute("SELECT id FROM Artists WHERE name = %s", (artist_name,))
    artist_id = cursor.fetchone()[0]

    # Insert song with s3_url
    cursor.execute("""
        INSERT IGNORE INTO Music (title, artist_id, image_url, lyrics, s3_url)
        VALUES (%s, %s, %s, %s, %s)
    """, (song_title, artist_id, image_url, lyrics, s3_url))
    db.commit()

    cursor.execute("""
        SELECT id FROM Music
        WHERE title = %s AND artist_id = %s
    """, (song_title, artist_id))
    music_id = cursor.fetchone()[0]

    return music_id

def insert_ranking(db, music_id, platform, rank):
    cursor = db.cursor()
    cursor.execute("""
        INSERT IGNORE INTO Rankings (platform, music_id, rank_position, ranking_date)
        VALUES (%s, %s, %s, %s)
    """, (platform, music_id, rank, date.today()))
    db.commit()

def cleanup_downloads():
    if os.path.exists('downloads'):
        for file in os.listdir('downloads'):
            try:
                os.remove(os.path.join('downloads', file))
            except:
                pass

def main():
    s3_handler = S3Handler()
    # Create downloads directory if it doesn't exist
    if not os.path.exists('downloads'):
        os.makedirs('downloads')

    db = connect_db()

    urls = [
        'https://itunes.apple.com/us/rss/topsongs/limit=100/json',
        'https://itunes.apple.com/vn/rss/topsongs/limit=100/json'
    ]

    for url in urls:
        try:
            response = requests.get(url)
            if not response.ok:
                print(f"Failed to fetch data from {url}. Status code: {response.status_code}")
                continue

            data = response.json()
            if not data or 'feed' not in data or 'entry' not in data['feed']:
                print(f"Invalid data structure from {url}")
                continue

            platform = 'itunes_us' if 'us' in url else 'itunes_vn'

            for rank, entry in enumerate(data['feed']['entry'], 1):
                try:
                    artist_name = entry['im:artist'].get('label')
                    song_title = entry['im:name'].get('label')
                    image_url = entry['im:image'][-1].get('label') if entry['im:image'] else None

                    # Get lyrics
                    lyrics = get_lyrics(artist_name, song_title)

                    # Download song
                    file_path = download_song(artist_name, song_title)
                    if file_path and os.path.exists(file_path):
                        # Upload to S3
                        s3_url = s3_handler.upload_file(file_path, artist_name, song_title)
                        if s3_url:
                            # Insert into database
                            music_id = insert_song_data(db, artist_name, song_title, image_url, lyrics, s3_url)
                            insert_ranking(db, music_id, platform, rank)
                            print(f"Successfully processed: {artist_name} - {song_title}")
                        else:
                            print(f"Failed to upload to S3: {artist_name} - {song_title}")
                    else:
                        print(f"Failed to download: {artist_name} - {song_title}")
                        # Vẫn insert vào database nhưng không có s3_url
                        music_id = insert_song_data(db, artist_name, song_title, image_url, lyrics, None)
                        insert_ranking(db, music_id, platform, rank)

                except Exception as e:
                    print(f"Error processing {artist_name} - {song_title}: {str(e)}")
                    continue

        except Exception as e:
            print(f"Error processing {url}: {str(e)}")

    db.close()

if __name__ == "__main__":
    main()
