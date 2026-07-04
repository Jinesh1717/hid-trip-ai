from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
import logging

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.search import get_es
from app.models.spot import Spot, SpotImage
from app.models.user import User
from app.schemas.spot import SpotCreate, SpotResponse

router = APIRouter()

@router.post("/", response_model=SpotResponse)
def create_spot(spot_in: SpotCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")
        
    spot_data = spot_in.model_dump()
    image_urls = spot_data.pop("image_urls", []) or []
    spot_data["added_by_id"] = user.id
    
    new_spot = Spot(**spot_data)
    db.add(new_spot)
    db.commit()
    db.refresh(new_spot)

    # Create spot images
    for url in image_urls:
        spot_image = SpotImage(spot_id=new_spot.id, image_url=url, uploaded_by_id=user.id)
        db.add(spot_image)
    if image_urls:
        db.commit()
        db.refresh(new_spot)

    # Sync to Elasticsearch
    try:
        es = get_es()
        es.index(
            index="spots",
            id=str(new_spot.id),
            document={
                "name": new_spot.name,
                "description": new_spot.description,
                "category": new_spot.category,
                "tags": new_spot.tags,
                "location": {
                    "lat": new_spot.latitude,
                    "lon": new_spot.longitude
                }
            }
        )
    except Exception as e:
        logging.error(f"Failed to sync spot to Elasticsearch: {e}")
        # Note: We don't fail the API request if search sync fails, but we log it

    return new_spot

@router.get("/search", response_model=List[SpotResponse])
def search_spots(
    q: str = Query(..., description="Search term for name, description, or tags"),
    db: Session = Depends(get_db)
):
    try:
        es = get_es()
        response = es.search(
            index="spots",
            body={
                "query": {
                    "multi_match": {
                        "query": q,
                        "fields": ["name^3", "category^2", "tags", "description"],
                        "fuzziness": "AUTO"
                    }
                }
            },
            size=50
        )
        
        hit_ids = [int(hit["_id"]) for hit in response["hits"]["hits"]]
        if not hit_ids:
            return []
            
        # Fetch actual records from DB maintaining ES order
        spots = db.query(Spot).options(joinedload(Spot.images)).filter(Spot.id.in_(hit_ids)).all()
        # Create a mapping to sort them properly
        spots_dict = {spot.id: spot for spot in spots}
        ordered_spots = [spots_dict[hid] for hid in hit_ids if hid in spots_dict]
        
        return ordered_spots
    except Exception as e:
        logging.error(f"Elasticsearch query failed: {e}")
        raise HTTPException(status_code=500, detail="Search service unavailable")

@router.get("/", response_model=List[SpotResponse])
def get_spots(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    spots = db.query(Spot).options(joinedload(Spot.images)).offset(skip).limit(limit).all()
    return spots

@router.get("/{spot_id}", response_model=SpotResponse)
def get_spot(spot_id: int, db: Session = Depends(get_db)):
    spot = db.query(Spot).options(joinedload(Spot.images)).filter(Spot.id == spot_id).first()
    if not spot:
        raise HTTPException(status_code=404, detail="Spot not found")
    return spot

@router.delete("/{spot_id}")
def delete_spot(spot_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    user = db.query(User).filter(User.firebase_uid == current_user.get("uid")).first()
    if not user:
        raise HTTPException(status_code=404, detail="User profile not found")
        
    spot = db.query(Spot).filter(Spot.id == spot_id).first()
    if not spot:
        raise HTTPException(status_code=404, detail="Spot not found")
        
    if spot.added_by_id != user.id and user.role != "Admin":
        raise HTTPException(status_code=403, detail="Not authorized to delete this spot")
        
    db.delete(spot)
    db.commit()

    # Sync delete to Elasticsearch
    try:
        es = get_es()
        es.delete(index="spots", id=str(spot_id), ignore=[404])
    except Exception as e:
        logging.error(f"Failed to delete spot from Elasticsearch: {e}")

    return {"message": "Spot deleted successfully"}
