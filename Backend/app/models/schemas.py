from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List


# User schemas
class UserBase(BaseModel):
    device_id: str
    age_group: Optional[str] = None
    gender: Optional[str] = None
    household_size: Optional[int] = None
    consent_given: bool = False


class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    age_group: Optional[str] = None
    gender: Optional[str] = None
    household_size: Optional[int] = None
    consent_given: Optional[bool] = None


class User(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Trip schemas
class TripBase(BaseModel):
    trip_number: int
    origin_lat: Optional[float] = None
    origin_lng: Optional[float] = None
    origin_address: Optional[str] = None
    destination_lat: Optional[float] = None
    destination_lng: Optional[float] = None
    destination_address: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    mode_of_travel: Optional[str] = None
    num_co_travellers: int = 0
    co_traveller_relationships: Optional[str] = None
    is_confirmed: bool = False


class TripCreate(TripBase):
    user_id: int


class TripUpdate(BaseModel):
    origin_lat: Optional[float] = None
    origin_lng: Optional[float] = None
    origin_address: Optional[str] = None
    destination_lat: Optional[float] = None
    destination_lng: Optional[float] = None
    destination_address: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    mode_of_travel: Optional[str] = None
    num_co_travellers: Optional[int] = None
    co_traveller_relationships: Optional[str] = None
    is_confirmed: Optional[bool] = None


class Trip(TripBase):
    id: int
    user_id: int
    is_synced: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Authentication schemas
class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    device_id: Optional[str] = None
