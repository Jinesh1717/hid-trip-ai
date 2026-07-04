import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "HiddenRoute AI API"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/hiddenroute")
    ELASTICSEARCH_URL: str = os.getenv("ELASTICSEARCH_URL", "http://localhost:9200")
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    CLOUDINARY_URL: str = os.getenv("CLOUDINARY_URL", "")
    FIREBASE_CREDENTIALS_PATH: str = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-adminsdk.json")

    class Config:
        env_file = ".env"

settings = Settings()
