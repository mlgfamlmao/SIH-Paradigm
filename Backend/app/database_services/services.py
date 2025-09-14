from sqlalchemy.orm import Session
from app.models.schemas import UserCreate, UserUpdate, TripCreate, TripUpdate
from app.models.models import User, Trip
from typing import Optional, List
from datetime import datetime


# User services
def get_user_by_device_id(db: Session, device_id: str) -> Optional[User]:
    return db.query(User).filter(User.device_id == device_id).first()


def create_user(db: Session, user: UserCreate) -> User:
    db_user = User(
        device_id=user.device_id,
        age_group=user.age_group,
        gender=user.gender,
        household_size=user.household_size,
        consent_given=user.consent_given
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def update_user(db: Session, user_id: int, user_update: UserUpdate) -> Optional[User]:
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user:
        for field, value in user_update.dict(exclude_unset=True).items():
            setattr(db_user, field, value)
        db.commit()
        db.refresh(db_user)
    return db_user


def get_user_trips(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List[Trip]:
    return db.query(Trip).filter(Trip.user_id == user_id).offset(skip).limit(limit).all()


# Trip services
def get_trip_by_id(db: Session, trip_id: int) -> Optional[Trip]:
    return db.query(Trip).filter(Trip.id == trip_id).first()


def create_trip(db: Session, trip: TripCreate) -> Trip:
    db_trip = Trip(
        user_id=trip.user_id,
        trip_number=trip.trip_number,
        origin_lat=trip.origin_lat,
        origin_lng=trip.origin_lng,
        origin_address=trip.origin_address,
        destination_lat=trip.destination_lat,
        destination_lng=trip.destination_lng,
        destination_address=trip.destination_address,
        start_time=trip.start_time,
        end_time=trip.end_time,
        mode_of_travel=trip.mode_of_travel,
        num_co_travellers=trip.num_co_travellers,
        co_traveller_relationships=trip.co_traveller_relationships,
        is_confirmed=trip.is_confirmed
    )
    db.add(db_trip)
    db.commit()
    db.refresh(db_trip)
    return db_trip


def update_trip(db: Session, trip_id: int, trip_update: TripUpdate) -> Optional[Trip]:
    db_trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if db_trip:
        for field, value in trip_update.dict(exclude_unset=True).items():
            setattr(db_trip, field, value)
        db.commit()
        db.refresh(db_trip)
    return db_trip


def delete_trip(db: Session, trip_id: int) -> Optional[Trip]:
    db_trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if db_trip:
        db.delete(db_trip)
        db.commit()
    return db_trip


def get_unsynced_trips(db: Session, user_id: int) -> List[Trip]:
    return db.query(Trip).filter(
        Trip.user_id == user_id,
        Trip.is_synced == False
    ).all()


def mark_trips_as_synced(db: Session, trip_ids: List[int]) -> None:
    db.query(Trip).filter(Trip.id.in_(trip_ids)).update(
        {Trip.is_synced: True},
        synchronize_session=False
    )
    db.commit()


def get_all_trips_for_export(db: Session, skip: int = 0, limit: int = 1000) -> List[Trip]:
    return db.query(Trip).offset(skip).limit(limit).all()
