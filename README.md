# NATPAC Travel Data Collection App

A mobile application for collecting travel data for the National Transportation Planning and Research Centre (NATPAC). This MVP version includes a Flutter mobile app with GPS tracking and a FastAPI backend with SQLite storage.

## Features

### Mobile App (Flutter)
- **User Consent & Onboarding**: Consent screen with privacy information and optional profile setup
- **Trip Data Capture**: Manual trip entry with origin, destination, time, and mode of travel
- **GPS Integration**: Location services for automatic trip detection and address resolution
- **Local Storage**: SQLite database for offline data storage
- **Data Sync**: Automatic synchronization with backend when online
- **Notifications**: Trip reminders and confirmation prompts
- **Privacy-Focused**: Anonymized data collection with secure storage

### Backend (FastAPI + SQLite)
- **REST API**: Complete CRUD operations for users and trips
- **Authentication**: JWT-based authentication using device IDs
- **SQLite Database**: Local database with User and Trip models
- **Data Export**: CSV export functionality for researchers
- **Privacy & Security**: Encrypted data transmission and anonymized storage

## Project Structure

```
SIH_Paradigm/
├── Backend/                 # FastAPI backend
│   ├── app/
│   │   ├── models/         # Database models and schemas
│   │   ├── database_services/  # Database connection and services
│   │   ├── auth.py         # Authentication logic
│   │   └── main.py         # FastAPI application
│   ├── requirements.txt    # Python dependencies
│   └── test_api.http      # API testing file
├── Frontend/               # Flutter mobile app
│   ├── lib/
│   │   ├── models/        # Data models with JSON serialization
│   │   ├── services/      # API, database, location, and notification services
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml       # Flutter dependencies
└── README.md              # This file
```

## Setup Instructions

### Backend Setup

1. **Navigate to Backend directory**:
   ```bash
   cd Backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the FastAPI server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

5. **Test the API**:
   - Open `test_api.http` in your IDE or use the FastAPI docs at `http://127.0.0.1:8000/docs`

### Frontend Setup

1. **Navigate to Frontend directory**:
   ```bash
   cd Frontend
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Flutter app**:
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login with device ID

### User Management
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile

### Trip Management
- `GET /trips` - Get user trips
- `POST /trips` - Create new trip
- `GET /trips/{trip_id}` - Get specific trip
- `PUT /trips/{trip_id}` - Update trip
- `DELETE /trips/{trip_id}` - Delete trip

### Data Sync
- `GET /trips/sync/pending` - Get unsynced trips
- `POST /trips/sync/confirm` - Mark trips as synced

### Export
- `GET /export/trips.csv` - Export all trips as CSV

## Database Schema

### Users Table
- `id` (Primary Key)
- `device_id` (Unique identifier)
- `age_group` (Optional)
- `gender` (Optional)
- `household_size` (Optional)
- `consent_given` (Boolean)
- `created_at`, `updated_at` (Timestamps)

### Trips Table
- `id` (Primary Key)
- `user_id` (Foreign Key)
- `trip_number` (Sequential number)
- `origin_lat`, `origin_lng` (GPS coordinates)
- `origin_address` (Human-readable address)
- `destination_lat`, `destination_lng` (GPS coordinates)
- `destination_address` (Human-readable address)
- `start_time`, `end_time` (Trip timestamps)
- `mode_of_travel` (Transportation mode)
- `num_co_travellers` (Number of co-travellers)
- `co_traveller_relationships` (Relationship descriptions)
- `is_confirmed` (Confirmation status)
- `is_synced` (Sync status)
- `created_at`, `updated_at` (Timestamps)

## Privacy & Security Features

- **Anonymized Data**: No personal identifiers collected
- **Device-based Authentication**: Uses anonymous device IDs
- **Encrypted Transmission**: HTTPS for all API communications
- **Local Storage**: Data stored locally with SQLite encryption
- **Consent Management**: Explicit user consent required
- **Data Export**: Researchers can export anonymized data

## Development Notes

### Flutter Dependencies
- `sqflite` - Local SQLite database
- `geolocator` - GPS location services
- `geocoding` - Address resolution
- `flutter_local_notifications` - Push notifications
- `provider` - State management
- `dio` - HTTP client for API calls
- `json_annotation` - JSON serialization

### Backend Dependencies
- `fastapi` - Web framework
- `sqlalchemy` - ORM for database operations
- `python-jose` - JWT token handling
- `passlib` - Password hashing
- `uvicorn` - ASGI server

## Testing

### Backend Testing
Use the provided `test_api.http` file or visit the interactive API docs at `http://127.0.0.1:8000/docs`

### Flutter Testing
```bash
cd Frontend
flutter test
```

## Deployment

### Backend Deployment
1. Set up a production database (PostgreSQL recommended)
2. Update `config.py` with production settings
3. Deploy using Docker or cloud services
4. Set up HTTPS certificates

### Flutter Deployment
1. Build for production:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```
2. Deploy to app stores or distribute directly

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is developed for NATPAC research purposes. Please contact the organization for licensing information.

## Support

For technical support or questions about the NATPAC study, please contact the research team.