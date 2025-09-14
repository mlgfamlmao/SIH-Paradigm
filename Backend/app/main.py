from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import csv
import io
from datetime import datetime, timedelta

from app.models.schemas import (
    User, UserCreate, UserUpdate, 
    Trip, TripCreate, TripUpdate, 
    Token
)
from app.database_services.database import Base, engine, SessionLocal
from app.database_services.services import (
    get_user_by_device_id, create_user, update_user, get_user_trips,
    get_trip_by_id, create_trip, update_trip, delete_trip,
    get_unsynced_trips, mark_trips_as_synced, get_all_trips_for_export
)
from app.auth import create_access_token, get_current_user, get_db

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="NATPAC Travel Data Collection API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


# Authentication endpoints
@app.post("/auth/register", response_model=Token)
async def register_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = get_user_by_device_id(db, user.device_id)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this device ID already exists"
        )
    
    # Create new user
    db_user = create_user(db, user)
    
    # Create access token
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": db_user.device_id}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


@app.post("/auth/login", response_model=Token)
async def login_user(device_id: str, db: Session = Depends(get_db)):
    user = get_user_by_device_id(db, device_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid device ID"
        )
    
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": user.device_id}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


# User endpoints
@app.get("/user/profile", response_model=User)
async def get_user_profile(current_user: User = Depends(get_current_user)):
    return current_user


@app.put("/user/profile", response_model=User)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    updated_user = update_user(db, current_user.id, user_update)
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return updated_user


# Trip endpoints
@app.get("/trips", response_model=List[Trip])
async def get_user_trips_list(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    trips = get_user_trips(db, current_user.id, skip, limit)
    return trips


@app.get("/trips/{trip_id}", response_model=Trip)
async def get_trip(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    trip = get_trip_by_id(db, trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    return trip


@app.post("/trips", response_model=Trip)
async def create_trip_endpoint(
    trip: TripCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Ensure the trip belongs to the current user
    trip.user_id = current_user.id
    return create_trip(db, trip)


@app.put("/trips/{trip_id}", response_model=Trip)
async def update_trip_endpoint(
    trip_id: int,
    trip_update: TripUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    trip = get_trip_by_id(db, trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    
    updated_trip = update_trip(db, trip_id, trip_update)
    return updated_trip


@app.delete("/trips/{trip_id}")
async def delete_trip_endpoint(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    trip = get_trip_by_id(db, trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found"
        )
    
    delete_trip(db, trip_id)
    return {"message": f"Trip {trip_id} deleted successfully"}


# Sync endpoints
@app.get("/trips/sync/pending", response_model=List[Trip])
async def get_pending_sync_trips(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return get_unsynced_trips(db, current_user.id)


@app.post("/trips/sync/confirm")
async def confirm_sync_trips(
    trip_ids: List[int],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Verify all trips belong to the current user
    for trip_id in trip_ids:
        trip = get_trip_by_id(db, trip_id)
        if not trip or trip.user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Trip {trip_id} not found or doesn't belong to user"
            )
    
    mark_trips_as_synced(db, trip_ids)
    return {"message": f"Marked {len(trip_ids)} trips as synced"}


# Export endpoint (for NATPAC scientists)
@app.get("/export/trips.csv")
async def export_trips_csv(
    skip: int = 0,
    limit: int = 10000,
    db: Session = Depends(get_db)
):
    trips = get_all_trips_for_export(db, skip, limit)
    
    # Create CSV content
    output = io.StringIO()
    writer = csv.writer(output)
    
    # Write header
    writer.writerow([
        'trip_id', 'user_id', 'device_id', 'trip_number',
        'origin_lat', 'origin_lng', 'origin_address',
        'destination_lat', 'destination_lng', 'destination_address',
        'start_time', 'end_time', 'mode_of_travel',
        'num_co_travellers', 'co_traveller_relationships',
        'is_confirmed', 'is_synced', 'created_at', 'updated_at'
    ])
    
    # Write data
    for trip in trips:
        writer.writerow([
            trip.id, trip.user_id, trip.user.device_id, trip.trip_number,
            trip.origin_lat, trip.origin_lng, trip.origin_address,
            trip.destination_lat, trip.destination_lng, trip.destination_address,
            trip.start_time, trip.end_time, trip.mode_of_travel,
            trip.num_co_travellers, trip.co_traveller_relationships,
            trip.is_confirmed, trip.is_synced, trip.created_at, trip.updated_at
        ])
    
    output.seek(0)
    
    return StreamingResponse(
        io.BytesIO(output.getvalue().encode('utf-8')),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename=trips_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"}
    )


# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}
