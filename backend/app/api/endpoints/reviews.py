from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.review import Review
from app.models.user import User
from app.models.spot import Spot
from app.schemas.review import ReviewCreate, ReviewResponse

router = APIRouter()

@router.post("/", response_model=ReviewResponse)
def create_review(review_in: ReviewCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")
        
    spot = db.query(Spot).filter(Spot.id == review_in.spot_id).first()
    if not spot:
        raise HTTPException(status_code=404, detail="Spot not found")
        
    review_data = review_in.model_dump()
    review_data["user_id"] = user.id
    
    new_review = Review(**review_data)
    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    return new_review

@router.get("/spot/{spot_id}", response_model=List[ReviewResponse])
def get_reviews_for_spot(spot_id: int, db: Session = Depends(get_db)):
    reviews = db.query(Review).filter(Review.spot_id == spot_id).all()
    return reviews

@router.delete("/{review_id}")
def delete_review(review_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")
        
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
        
    if review.user_id != user.id and user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized to delete this review")
        
    db.delete(review)
    db.commit()
    return {"message": "Review deleted successfully"}
