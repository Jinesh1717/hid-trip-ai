from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class ReviewBase(BaseModel):
    rating_overall: float
    rating_cleanliness: Optional[float] = None
    rating_safety: Optional[float] = None
    rating_crowd: Optional[float] = None
    rating_photo: Optional[float] = None
    rating_food: Optional[float] = None
    rating_family: Optional[float] = None
    comment: Optional[str] = None

class ReviewCreate(ReviewBase):
    spot_id: int
    user_id: int

class ReviewResponse(ReviewBase):
    id: int
    spot_id: int
    user_id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
