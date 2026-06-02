from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    spot_id = Column(Integer, ForeignKey("spots.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    
    rating_overall = Column(Float, nullable=False)
    cleanliness = Column(Float, nullable=True)
    safety = Column(Float, nullable=True)
    crowd_level = Column(Float, nullable=True)
    photography_value = Column(Float, nullable=True)
    food_quality = Column(Float, nullable=True)
    family_friendly = Column(Float, nullable=True)
    
    text = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    spot = relationship("Spot", back_populates="reviews")
    user = relationship("User", back_populates="reviews")
