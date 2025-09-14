import os


class Settings:
    # SQLite database configuration
    database_url: str = "sqlite:///./natpac_travel_data.db"
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30


settings = Settings()
