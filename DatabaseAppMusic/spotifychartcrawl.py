import requests
import base64
import mysql.connector
from datetime import datetime

class SpotifyChartCrawler:
    def __init__(self):
        # Thông tin xác thực Spotify API
        self.client_id = '5e0249af0635420cb532f354e281db61'
        self.client_secret = '1f8527808d6b4b0ea2258ce65efe2b47'
        self.token = self.get_spotify_token()

        # Kết nối database
        self.db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="cntt15723",
            database="app_music"
        )
        self.cursor = self.db.cursor()

    def get_spotify_token(self):
        auth_string = f"{self.client_id}:{self.client_secret}"
        auth_bytes = auth_string.encode("utf-8")
        auth_base64 = str(base64.b64encode(auth_bytes), "utf-8")

        url = "https://accounts.spotify.com/api/token"
        headers = {
            "Authorization": f"Basic {auth_base64}",
            "Content-Type": "application/x-www-form-urlencoded"
        }
        data = {"grant_type": "client_credentials"}

        result = requests.post(url, headers=headers, data=data)
        json_result = result.json()

        # Thêm dòng debug
        print("Token response:", json_result)

        return json_result["access_token"]

    def get_spotify_charts(self):
        try:
            # Sử dụng Featured Playlists API endpoint
            url = "https://api.spotify.com/v1/browse/featured-playlists"

            headers = {
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json"
            }

            # Lấy Global Top 50 playlist
            response = requests.get(
                "https://api.spotify.com/v1/playlists/37i9dQZEVXbNG2KDcFcKOF/tracks",
                headers=headers
            )

            if response.status_code != 200:
                print(f"Lỗi API: {response.status_code}")
                print(f"Response: {response.text}")
                return

            data = response.json()

            for rank, item in enumerate(data['items'], 1):
                track = item['track']

                # Lấy thông tin bài hát
                title = track['name']
                artist_name = track['artists'][0]['name']
                preview_url = track['preview_url'] or track['external_urls']['spotify']

                print(f"Đang xử lý: {rank}. {title} - {artist_name}")

                # Thêm nghệ sĩ vào database
                artist_id = self.add_artist(artist_name)
                if not artist_id:
                    continue

                # Thêm bài hát vào database
                music_id = self.add_music(
                    title=title,
                    artist_id=artist_id,
                    s3_url=preview_url
                )
                if not music_id:
                    continue

                # Cập nhật xếp hạng
                self.update_rankings("Spotify", music_id, rank)

            print("Đã cập nhật xong BXH Spotify")

        except Exception as e:
            print(f"Lỗi khi crawl Spotify: {str(e)}")

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

if __name__ == "__main__":
    crawler = SpotifyChartCrawler()
    crawler.get_spotify_charts()
    crawler.close()
