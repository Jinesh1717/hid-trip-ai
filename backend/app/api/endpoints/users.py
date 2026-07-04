from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse

router = APIRouter()

@router.post("/", response_model=UserResponse)
def create_user(user_in: UserCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Verify the firebase uid matches the token payload
    if current_user.get("uid") != user_in.firebase_uid:
        raise HTTPException(status_code=403, detail="Not authorized to create this user profile")
        
    db_user = db.query(User).filter(User.firebase_uid == user_in.firebase_uid).first()
    if db_user:
        raise HTTPException(status_code=400, detail="User already exists")
    
    new_user = User(**user_in.model_dump())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get("/me", response_model=UserResponse)
def get_current_user_profile(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    db_user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User profile not found")
    return db_user

@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user
