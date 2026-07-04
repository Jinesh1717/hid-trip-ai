from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True)
    profile_image_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    role = Column(String, default="Traveler") # Traveler, Local Guide, Admin
    reputation_points = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
