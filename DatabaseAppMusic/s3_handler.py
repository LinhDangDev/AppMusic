import boto3
import os
from config import S3_CONFIG

class S3Handler:
    def __init__(self):
        self.s3 = boto3.client('s3',
            aws_access_key_id=S3_CONFIG['aws_access_key_id'],
            aws_secret_access_key=S3_CONFIG['aws_secret_access_key'],
            region_name=S3_CONFIG['region_name']
        )
        self.bucket_name = S3_CONFIG['bucket_name']

    def upload_file(self, file_path, artist, title):
        try:
            # Tạo key cho file trên S3
            s3_key = f"music/{artist}/{title}.mp3"
            
            # Upload file
            self.s3.upload_file(
                file_path,
                self.bucket_name,
                s3_key,
                ExtraArgs={'ACL': 'public-read'}  # Cho phép public access
            )
            
            # Tạo URL public
            s3_url = f"https://{self.bucket_name}.s3.amazonaws.com/{s3_key}"
            
            # Xóa file local sau khi upload
            os.remove(file_path)
            
            return s3_url
            
        except Exception as e:
            print(f"Error uploading to S3: {str(e)}")
            return None

    def delete_file(self, s3_url):
        try:
            # Lấy key từ URL
            s3_key = s3_url.split('.com/')[1]
            
            # Xóa file từ S3
            self.s3.delete_object(
                Bucket=self.bucket_name,
                Key=s3_key
            )
            return True
        except Exception as e:
            print(f"Error deleting from S3: {str(e)}")
            return False 