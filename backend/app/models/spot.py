from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Spot(Base):
    __tablename__ = "spots"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    description = Column(String, nullable=False)
    category = Column(String, index=True, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    opening_hours = Column(String, nullable=True)
    entry_fee = Column(String, nullable=True)
    parking_available = Column(Boolean, default=False)
    best_time_to_visit = Column(String, nullable=True)
    tags = Column(String, nullable=True) # Could be JSON or ARRAY(String) in postgres, using String for simplicity initially or ARRAY if DB supports it. Let's use string comma separated for now.
    
    added_by_id = Column(Integer, ForeignKey("users.id"))
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    added_by = relationship("User")
    reviews = relationship("Review", back_populates="spot")
    images = relationship("SpotImage", back_populates="spot")

class SpotImage(Base):
    __tablename__ = "spot_images"

    id = Column(Integer, primary_key=True, index=True)
    spot_id = Column(Integer, ForeignKey("spots.id"))
    image_url = Column(String, nullable=False)
    uploaded_by_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    spot = relationship("Spot", back_populates="images")
    uploaded_by = relationship("User")
