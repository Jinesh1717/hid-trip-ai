from fastapi import APIRouter
from app.api.endpoints import users, spots, reviews, upload, trips

api_router = APIRouter()
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(spots.router, prefix="/spots", tags=["spots"])
api_router.include_router(reviews.router, prefix="/reviews", tags=["reviews"])
api_router.include_router(upload.router, prefix="/upload", tags=["upload"])
api_router.include_router(trips.router, prefix="/trips", tags=["trips"])
