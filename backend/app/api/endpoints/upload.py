from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
import cloudinary
import cloudinary.uploader
from app.core.config import settings
from app.core.security import get_current_user
import uuid

router = APIRouter()

# Initialize Cloudinary globally if CLOUDINARY_URL is set in environment
# The Cloudinary SDK automatically picks up the CLOUDINARY_URL environment variable.
if settings.CLOUDINARY_URL:
    cloudinary.config(
        # The url is parsed automatically, but we ensure secure=True
        secure=True
    )

@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user)
):
    """
    Uploads an image to Cloudinary and returns the secure URL.
    """
    if not settings.CLOUDINARY_URL:
        raise HTTPException(status_code=500, detail="Cloudinary is not configured on the server")
        
    # Validate content type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
        
    try:
        # Read the file content
        contents = await file.read()
        
        # Upload to cloudinary
        result = cloudinary.uploader.upload(
            contents,
            folder="hiddenroute_spots",
            public_id=f"spot_{uuid.uuid4()}",
            resource_type="image"
        )
        
        return {
            "url": result.get("secure_url"),
            "public_id": result.get("public_id"),
            "format": result.get("format")
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image upload failed: {str(e)}")
