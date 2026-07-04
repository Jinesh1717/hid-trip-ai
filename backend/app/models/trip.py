from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class TripPlan(Base):
    __tablename__ = "trip_plans"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String, nullable=False)
    destination = Column(String, nullable=False)
    budget = Column(Float, nullable=True)
    duration_days = Column(Integer, nullable=True)
    
    # Store the AI generated structured itinerary as JSON
    ai_generated_json = Column(JSON, nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")
