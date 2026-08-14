from fastapi import APIRouter
from pydantic import BaseModel

from app.services.sos_service import SOSService


router = APIRouter(
    prefix="/sos",
    tags=["SOS"],
)


class Guardian(BaseModel):
    name: str
    phone: str
    is_primary: bool = False


class SOSRequest(BaseModel):
    latitude: float
    longitude: float
    guardians: list[Guardian]


@router.post("/activate")
async def activate_sos(request: SOSRequest):

    sos_service = SOSService()

    guardians = [
        guardian.model_dump()
        for guardian in request.guardians
    ]

    result = await sos_service.activate_sos(
        latitude=request.latitude,
        longitude=request.longitude,
        guardians=guardians,
    )

    return result