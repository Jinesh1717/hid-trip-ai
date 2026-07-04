from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime

class SpotImageResponse(BaseModel):
    id: int
    image_url: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class SpotBase(BaseModel):
    name: str
    description: str
    category: str
    latitude: float
    longitude: float
    opening_hours: Optional[str] = None
    entry_fee: Optional[str] = None
    parking_available: bool = False
    best_time_to_visit: Optional[str] = None
    tags: Optional[str] = None

class SpotCreate(SpotBase):
    added_by_id: int
    image_urls: Optional[List[str]] = None

class SpotUpdate(SpotBase):
    is_verified: Optional[bool] = None

class SpotResponse(SpotBase):
    id: int
    added_by_id: int
    is_verified: bool
    created_at: datetime
    images: List[SpotImageResponse] = []
    
    model_config = ConfigDict(from_attributes=True)
