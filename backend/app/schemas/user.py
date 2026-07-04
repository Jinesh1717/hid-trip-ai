from pydantic import BaseModel, ConfigDict, EmailStr
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    firebase_uid: str
    email: EmailStr
    username: Optional[str] = None
    profile_image_url: Optional[str] = None
    bio: Optional[str] = None

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int
    role: str
    reputation_points: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
