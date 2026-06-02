import enum
from sqlalchemy import Column, Integer, String, Enum, DateTime, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class UserRole(str, enum.Enum):
    TRAVELER = "TRAVELER"
    LOCAL_GUIDE = "LOCAL_GUIDE"
    ADMIN = "ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String)
    profile_image = Column(String, nullable=True)
    role = Column(Enum(UserRole), default=UserRole.TRAVELER)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    spots = relationship("Spot", back_populates="author")
    reviews = relationship("Review", back_populates="user")
