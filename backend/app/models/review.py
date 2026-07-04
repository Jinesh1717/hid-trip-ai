from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    spot_id = Column(Integer, ForeignKey("spots.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    
    rating_overall = Column(Float, nullable=False)
    rating_cleanliness = Column(Float, nullable=True)
    rating_safety = Column(Float, nullable=True)
    rating_crowd = Column(Float, nullable=True)
    rating_photo = Column(Float, nullable=True)
    rating_food = Column(Float, nullable=True)
    rating_family = Column(Float, nullable=True)
    
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    spot = relationship("Spot", back_populates="reviews")
    user = relationship("User")
