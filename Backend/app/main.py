from fastapi import FastAPI

from app.routers import sos


app = FastAPI(
    title="ASTRA Backend",
    description="Backend API for ASTRA - One Step Ahead",
    version="1.0.0",
)


app.include_router(sos.router)


@app.get("/")
async def root():
    return {
        "message": "ASTRA Backend is running!"
    }