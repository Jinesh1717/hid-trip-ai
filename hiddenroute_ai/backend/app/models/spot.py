from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, JSON, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class Spot(Base):
    __tablename__ = "spots"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    category = Column(String, index=True, nullable=False)
    description = Column(String, nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    address = Column(String, nullable=True)
    opening_hours = Column(String, nullable=True)
    entry_fee = Column(String, nullable=True)
    parking_available = Column(Boolean, default=False)
    best_time_to_visit = Column(String, nullable=True)
    tags = Column(JSON, default=[])
    
    author_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    author = relationship("User", back_populates="spots")
    reviews = relationship("Review", back_populates="spot")
    images = relationship("SpotImage", back_populates="spot")

class SpotImage(Base):
    __tablename__ = "spot_images"
    
    id = Column(Integer, primary_key=True, index=True)
    spot_id = Column(Integer, ForeignKey("spots.id"))
    image_url = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    spot = relationship("Spot", back_populates="images")
