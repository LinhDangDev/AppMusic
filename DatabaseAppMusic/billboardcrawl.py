import requests
from bs4 import BeautifulSoup
import mysql.connector
from datetime import datetime

class BillboardCrawler:
    def __init__(self):
        try:
            self.db = mysql.connector.connect(
                host="localhost",
                user="root",
                password="cntt15723",
                database="app_music"
            )
            self.cursor = self.db.cursor()
            print("Database connection established.")  # Added confirmation
        except mysql.connector.Error as err:
            print(f"Error connecting to database: {err}")  # Added error logging

    def get_billboard_charts(self):
        try:
            url = "https://www.billboard.com/charts/hot-100/"
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }

            response = requests.get(url, headers=headers)
            soup = BeautifulSoup(response.content, 'html.parser')

            # Tìm tất cả các phần tử chứa thông tin bài hát
            song_items = soup.select('div.o-chart-results-list-row')

            for rank, item in enumerate(song_items, 1):
                try:
                    # Lấy thông tin cơ bản
                    title_element = item.select_one('h3#title-of-a-story')
                    artist_element = item.select_one('span.c-label')
                    image_element = item.select_one('img.c-lazy-image__img')

                    title = title_element.text.strip() if title_element else "Unknown Title"
                    artist = artist_element.text.strip() if artist_element else "Unknown Artist"

                    # Lấy URL hình ảnh
                    image_url = ""
                    if image_element:
                        image_url = image_element.get('data-lazy-src') or image_element.get('src', '')

                    print(f"Processing: {rank}. {title} - {artist}")

                    # Thêm nghệ sĩ với hình ảnh
                    artist_id = self.add_artist(artist, image_url)
                    if not artist_id:
                        continue

                    # Thêm bài hát với hình ảnh
                    music_id = self.add_music(title, artist_id, image_url)
                    if not music_id:
                        continue

                    # Cập nhật xếp hạng
                    self.update_rankings("Billboard", music_id, rank)

                except Exception as e:
                    print(f"Error processing song: {str(e)}")
                    continue

            print("Billboard Hot 100 chart updated successfully")

        except Exception as e:
            print(f"Error crawling Billboard: {str(e)}")

    def add_artist(self, name, image_url=""):
        try:
            query = """
                INSERT INTO Artists (name, image_url)
                VALUES (%s, %s)
                ON DUPLICATE KEY UPDATE
                    id=LAST_INSERT_ID(id),
                    image_url=COALESCE(NULLIF(%s, ''), image_url)
            """
            self.cursor.execute(query, (name, image_url, image_url))
            self.db.commit()
            print(f"Artist inserted with ID: {self.cursor.lastrowid}")  # Existing confirmation
            return self.cursor.lastrowid
        except mysql.connector.Error as err:
            print(f"Database error adding artist: {err}")  # Enhanced error logging
            return None
        except Exception as e:
            print(f"Error adding artist: {str(e)}")
            return None

    def add_music(self, title, artist_id, image_url=""):
        try:
            # Giả lập s3_url với image_url tạm thời
            s3_url = image_url or "https://placeholder.com/music.mp3"

            query = """
                INSERT INTO Music (title, artist_id, image_url, s3_url)
                VALUES (%s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                    id=LAST_INSERT_ID(id),
                    image_url=COALESCE(NULLIF(%s, ''), image_url)
            """
            self.cursor.execute(query, (title, artist_id, image_url, s3_url, image_url))
            self.db.commit()
            print(f"Music inserted with ID: {self.cursor.lastrowid}")  # Existing confirmation
            return self.cursor.lastrowid
        except mysql.connector.Error as err:
            print(f"Database error adding music: {err}")  # Enhanced error logging
            return None
        except Exception as e:
            print(f"Error adding music: {str(e)}")
            return None

    def update_rankings(self, platform, music_id, rank):
        try:
            query = """
                INSERT INTO Rankings (platform, music_id, rank, date)
                VALUES (%s, %s, %s, CURRENT_DATE)
                ON DUPLICATE KEY UPDATE rank = VALUES(rank)
            """
            self.cursor.execute(query, (platform, music_id, rank))
            self.db.commit()
            print(f"Ranking updated for Music ID: {music_id} with Rank: {rank}")  # Existing confirmation
        except mysql.connector.Error as err:
            print(f"Database error updating ranking: {err}")  # Enhanced error logging
        except Exception as e:
            print(f"Error updating ranking: {str(e)}")

    def close(self):
        self.cursor.close()
        self.db.close()

if __name__ == "__main__":
    crawler = BillboardCrawler()
    crawler.get_billboard_charts()
    crawler.close()
