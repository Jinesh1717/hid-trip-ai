from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.trip import TripPlan
from app.schemas.trip import TripPlanCreate, TripPlanResponse, TripPlanRequest

router = APIRouter()

def get_current_db_user(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)) -> User:
    db_user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User profile not found")
    return db_user

@router.post("/", response_model=TripPlanResponse, status_code=status.HTTP_201_CREATED)
def create_trip_plan(
    trip_in: TripPlanRequest, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_db_user)
):
    # Dummy AI generated content for now
    dummy_ai_json = {
        "itinerary": [
            {
                "day": 1,
                "activities": [
                    {"time": "09:00", "description": f"Arrive in {trip_in.destination}"},
                    {"time": "12:00", "description": "Lunch at a local spot"},
                    {"time": "15:00", "description": "Check-in to hotel"}
                ]
            }
        ]
    }
    
    trip_data = TripPlanCreate(
        **trip_in.model_dump(),
        ai_generated_json=dummy_ai_json,
        user_id=current_user.id
    )
    
    new_trip = TripPlan(**trip_data.model_dump())
    db.add(new_trip)
    db.commit()
    db.refresh(new_trip)
    
    return new_trip

@router.get("/", response_model=List[TripPlanResponse])
def get_user_trips(
    skip: int = 0, 
    limit: int = 10, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_db_user)
):
    trips = db.query(TripPlan).filter(TripPlan.user_id == current_user.id).offset(skip).limit(limit).all()
    return trips

@router.get("/{trip_id}", response_model=TripPlanResponse)
def get_trip(
    trip_id: int, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_db_user)
):
    trip = db.query(TripPlan).filter(TripPlan.id == trip_id, TripPlan.user_id == current_user.id).first()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip plan not found")
    return trip

@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trip(
    trip_id: int, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_db_user)
):
    trip = db.query(TripPlan).filter(TripPlan.id == trip_id, TripPlan.user_id == current_user.id).first()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip plan not found")
        
    db.delete(trip)
    db.commit()
    return None
