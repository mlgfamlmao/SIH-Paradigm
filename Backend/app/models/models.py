from app.database_services.database import Base
from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String, unique=True, index=True)  # Anonymous device identifier
    age_group = Column(String)  # e.g., "18-25", "26-35", etc.
    gender = Column(String)  # e.g., "Male", "Female", "Other", "Prefer not to say"
    household_size = Column(Integer)  # Number of people in household
    consent_given = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to trips
    trips = relationship("Trip", back_populates="user")


class Trip(Base):
    __tablename__ = "trips"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    trip_number = Column(Integer)  # Sequential trip number for the user
    origin_lat = Column(Float)
    origin_lng = Column(Float)
    origin_address = Column(String)
    destination_lat = Column(Float)
    destination_lng = Column(Float)
    destination_address = Column(String)
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    mode_of_travel = Column(String)  # e.g., "Walking", "Car", "Bus", "Train", "Bicycle"
    num_co_travellers = Column(Integer, default=0)
    co_traveller_relationships = Column(Text)  # JSON string of relationships
    is_confirmed = Column(Boolean, default=False)
    is_synced = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to user
    user = relationship("User", back_populates="trips")
