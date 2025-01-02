import requests
import json
import time
import mysql.connector
from datetime import datetime

class ZingMP3Crawler:
    def __init__(self):
        self.db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="cntt15723",
            database="app_music"
        )
        self.cursor = self.db.cursor()
        
    def get_zing_chart(self):
        try:
            # API endpoint của ZingMP3 chart
            url = "https://zingmp3.vn/api/v2/page/get/chart-home"
            
            # Headers giả lập trình duyệt
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Referer': 'https://zingmp3.vn/zing-chart'
            }
            
            response = requests.get(url, headers=headers)
            data = response.json()
            
            if data['err'] != 0:
                print("Lỗi khi lấy dữ liệu từ ZingMP3")
                return
                
            songs = data['data']['RTChart']['items']
            
            for song in songs:
                # Lấy thông tin bài hát
                title = song['title']
                artist_name = song['artistsNames']
                rank = song['position']
                
                # Thêm nghệ sĩ
                artist_id = self.add_artist(artist_name)
                if not artist_id:
                    continue
                
                # Thêm bài hát
                music_id = self.add_music(
                    title=title,
                    artist_id=artist_id,
                    s3_url=song['thumbnail']  # Tạm dùng thumbnail làm s3_url
                )
                if not music_id:
                    continue
                
                # Cập nhật xếp hạng
                self.update_rankings("ZingMP3", music_id, rank)
                
            print("Đã cập nhật xong BXH ZingMP3")
            
        except Exception as e:
            print(f"Lỗi khi crawl ZingMP3: {str(e)}")

    def add_artist(self, artist_name):
        try:
            # Kiểm tra xem nghệ sĩ đã tồn tại chưa
            query = "SELECT id FROM Artists WHERE name = %s"
            self.cursor.execute(query, (artist_name,))
            result = self.cursor.fetchone()

            if result:
                return result[0]

            # Thêm nghệ sĩ mới
            query = "INSERT INTO Artists (name) VALUES (%s)"
            self.cursor.execute(query, (artist_name,))
            self.db.commit()
            return self.cursor.lastrowid

        except Exception as e:
            print(f"Lỗi khi thêm nghệ sĩ: {str(e)}")
            return None

    def add_music(self, title, artist_id, s3_url):
        try:
            # Kiểm tra xem bài hát đã tồn tại chưa
            query = "SELECT id FROM Music WHERE title = %s AND artist_id = %s"
            self.cursor.execute(query, (title, artist_id))
            result = self.cursor.fetchone()

            if result:
                return result[0]

            # Thêm bài hát mới
            query = """
                INSERT INTO Music (title, artist_id, s3_url)
                VALUES (%s, %s, %s)
            """
            self.cursor.execute(query, (title, artist_id, s3_url))
            self.db.commit()
            return self.cursor.lastrowid

        except Exception as e:
            print(f"Lỗi khi thêm bài hát: {str(e)}")
            return None

    def update_rankings(self, platform, music_id, rank):
        try:
            # Cập nhật hoặc thêm mới xếp hạng
            query = """
                INSERT INTO Rankings (platform, music_id, rank)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE rank = VALUES(rank)
            """
            self.cursor.execute(query, (platform, music_id, rank))
            self.db.commit()

        except Exception as e:
            print(f"Lỗi khi cập nhật xếp hạng: {str(e)}")

    def close(self):
        self.cursor.close()
        self.db.close()

# Sử dụng
if __name__ == "__main__":
    crawler = ZingMP3Crawler()
    crawler.get_zing_chart()
    crawler.close()
