from pydantic import BaseModel, ConfigDict
from typing import Optional, Dict, Any
from datetime import datetime

class TripPlanRequest(BaseModel):
    title: str
    destination: str
    budget: Optional[float] = None
    duration_days: Optional[int] = None

class TripPlanBase(BaseModel):
    title: str
    destination: str
    budget: Optional[float] = None
    duration_days: Optional[int] = None
    ai_generated_json: Dict[str, Any]

class TripPlanCreate(TripPlanBase):
    user_id: int

class TripPlanResponse(TripPlanBase):
    id: int
    user_id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
