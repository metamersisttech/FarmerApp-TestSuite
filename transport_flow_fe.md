# Transport Flow - Frontend API Documentation

> Complete API reference with curl commands for implementing the transport feature in FarmerApp.

**Base URL**: `http://localhost` (Production: `https://your-domain.com`)

---

## Table of Contents

1. [Authentication Setup](#1-authentication-setup)
2. [Role Upgrade Flow (User → Transport Provider)](#2-role-upgrade-flow-user--transport-provider)
3. [Provider Profile Management](#3-provider-profile-management)
4. [Vehicle Management](#4-vehicle-management)
5. [Transport Request Flow (Requestor Side)](#5-transport-request-flow-requestor-side)
6. [Transport Request Flow (Provider Side)](#6-transport-request-flow-provider-side)
7. [Chat System](#7-chat-system)
8. [Admin Endpoints](#8-admin-endpoints)
9. [Public Endpoints](#9-public-endpoints)
10. [Status Codes & Errors](#10-status-codes--errors)
11. [Flow Diagrams](#11-flow-diagrams)
12. [FCM Notifications](#12-fcm-notifications)
13. [Test Data](#13-test-data)

---

## 1. Authentication Setup

### 1.1 Register a New User

```bash
curl -X POST http://localhost/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "farmer_john",
    "email": "farmer_john@example.com",
    "phone": "+919876543210",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

**Response (201 Created):**
```json
{
  "message": "User registered successfully.",
  "user": {
    "id": 1,
    "username": "farmer_john",
    "email": "farmer_john@example.com",
    "phone": "+919876543210",
    "first_name": "John",
    "last_name": "Doe",
    "is_verified": false,
    "kyc_status": "NOT_SUBMITTED",
    "onboarding_completed": false,
    "preferred_lang": null,
    "date_joined": "2025-03-20T10:00:00Z",
    "last_login": null,
    "roles": ["farmer"]
  },
  "tokens": {
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 1.2 Login with Email/Phone and Password

```bash
curl -X POST http://localhost/api/auth/login-email/ \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "farmer_john@example.com",
    "password": "SecurePass123!"
  }'
```

**Response (200 OK):**
```json
{
  "message": "Login successful.",
  "user": {
    "id": 1,
    "username": "farmer_john",
    "email": "farmer_john@example.com",
    "phone": "+919876543210",
    "first_name": "John",
    "last_name": "Doe",
    "is_verified": false,
    "kyc_status": "NOT_SUBMITTED",
    "onboarding_completed": false,
    "preferred_lang": null,
    "date_joined": "2025-03-20T10:00:00Z",
    "last_login": "2025-03-20T10:30:00Z",
    "roles": ["farmer"]
  },
  "tokens": {
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 1.3 Login with OTP (Phone)

**Step 1: Request OTP**
```bash
curl -X POST http://localhost/api/auth/send-login-otp/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210"
  }'
```

**Response (200 OK):**
```json
{
  "message": "OTP sent successfully.",
  "otp": "123456",
  "user_id": 1
}
```
> Note: In production, OTP is sent via SMS and NOT returned in the response.

**Step 2: Verify OTP**
```bash
curl -X POST http://localhost/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "otp": "123456"
  }'
```

**Response (200 OK):**
```json
{
  "message": "Login successful.",
  "user": { ... },
  "tokens": {
    "refresh": "...",
    "access": "..."
  }
}
```

### 1.4 Refresh Token

```bash
curl -X POST http://localhost/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

**Response (200 OK):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 1.5 Get Current User

```bash
curl -X GET http://localhost/api/auth/me/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "id": 1,
  "username": "farmer_john",
  "email": "farmer_john@example.com",
  "phone": "+919876543210",
  "first_name": "John",
  "last_name": "Doe",
  "is_verified": false,
  "kyc_status": "NOT_SUBMITTED",
  "onboarding_completed": false,
  "preferred_lang": "en",
  "date_joined": "2025-03-20T10:00:00Z",
  "last_login": "2025-03-20T10:30:00Z",
  "roles": ["farmer"],
  "profile": {
    "full_name": null,
    "display_name": null,
    "dob": null,
    "address": null,
    "state": null,
    "district": null,
    "village": null,
    "pincode": null,
    "latitude": null,
    "longitude": null,
    "profile_image_gcs": null,
    "about": null
  }
}
```

### 1.6 Logout

```bash
curl -X POST http://localhost/api/auth/logout/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

**Response (200 OK):**
```json
{
  "message": "Successfully logged out."
}
```

---

START FROM HERE

## 2. Role Upgrade Flow (User → Transport Provider)

### 2.1 Check Verification Status (Before Applying)

```bash
curl -X GET http://localhost/api/auth/transport/verification-status/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK) - Not Applied:**
```json
{
  "has_applied": false,
  "request_id": null,
  "status": null,
  "submitted_at": null,
  "documents": null,
  "rejected_documents": null,
  "admin_remarks": null,
  "rejection_reason": null,
  "reviewed_at": null
}
```

### 2.2 Apply for Transport Provider Role

```bash
curl -X POST http://localhost/api/auth/role/upgrade/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "transport",
    "business_name": "Swift Animal Transport",
    "registration_no": "TRN123456789",
    "years_of_experience": 5,
    "bio": "Professional animal transport service with 5 years of experience",
    "latitude": 18.5204,
    "longitude": 73.8567,
    "service_radius_km": 100,
    "driving_license": "uploads/licenses/dl_123.jpg",
    "driving_license_number": "MH1420190001234",
    "driving_license_expiry": "2028-05-15",
    "documents": [
      "uploads/documents/aadhar_front.jpg",
      "uploads/documents/aadhar_back.jpg",
      "uploads/documents/pan_card.jpg"
    ]
  }'
```

**Required Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `role` | string | Yes | Must be "transport" |
| `business_name` | string | No | Provider's business name |
| `registration_no` | string | No | Business registration number |
| `years_of_experience` | integer | No | Years in transport business |
| `bio` | string | No | Description/bio |
| `latitude` | decimal | No | Initial location latitude |
| `longitude` | decimal | No | Initial location longitude |
| `service_radius_km` | integer | No | Service area radius (default: 50km) |
| `driving_license` | string | No | GCS path to driving license image |
| `driving_license_number` | string | No | License number (max 50 chars) |
| `driving_license_expiry` | date | No | License expiry date (YYYY-MM-DD) |
| `documents` | array | **Yes** | List of KYC document GCS paths |

**Response (201 Created):**
```json
{
  "request_id": 1,
  "requested_role": 3,
  "requested_role_name": "transport",
  "status": "PENDING",
  "status_display": "Pending",
  "additional_info": {
    "business_name": "Swift Animal Transport",
    "registration_no": "TRN123456789",
    "years_of_experience": 5,
    "bio": "Professional animal transport service with 5 years of experience",
    "latitude": "18.5204000",
    "longitude": "73.8567000",
    "service_radius_km": 100,
    "driving_license": "uploads/licenses/dl_123.jpg",
    "driving_license_number": "MH1420190001234",
    "driving_license_expiry": "2028-05-15"
  },
  "documents": [
    "uploads/documents/aadhar_front.jpg",
    "uploads/documents/aadhar_back.jpg",
    "uploads/documents/pan_card.jpg"
  ],
  "rejection_reason": null,
  "rejected_documents": null,
  "admin_remarks": null,
  "created_at": "2025-03-20T11:00:00Z",
  "updated_at": "2025-03-20T11:00:00Z",
  "reviewed_at": null
}
```

**Error Cases:**

*Already has pending request (400):*
```json
{
  "error": "You already have a pending request for transport role."
}
```

*Already has role (400):*
```json
{
  "error": "You already have the transport role."
}
```

*Missing required documents (400):*
```json
{
  "documents": ["Documents are required for transport provider KYC verification."]
}
```

### 2.3 Check Verification Status (After Applying)

```bash
curl -X GET http://localhost/api/auth/transport/verification-status/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK) - Pending:**
```json
{
  "has_applied": true,
  "request_id": 1,
  "status": "PENDING",
  "submitted_at": "2025-03-20T11:00:00Z",
  "documents": {
    "business_name": "Swift Animal Transport",
    "registration_no": "TRN123456789",
    "years_of_experience": 5,
    "bio": "Professional animal transport service",
    "driving_license": "uploads/licenses/dl_123.jpg",
    "driving_license_number": "MH1420190001234",
    "driving_license_expiry": "2028-05-15",
    "latitude": "18.5204000",
    "longitude": "73.8567000",
    "service_radius_km": 100
  },
  "rejected_documents": null,
  "admin_remarks": null,
  "rejection_reason": null,
  "reviewed_at": null
}
```

**Response (200 OK) - Approved:**
```json
{
  "has_applied": true,
  "request_id": 1,
  "status": "APPROVED",
  "submitted_at": "2025-03-20T11:00:00Z",
  "documents": { ... },
  "rejected_documents": null,
  "admin_remarks": null,
  "rejection_reason": null,
  "reviewed_at": "2025-03-20T12:00:00Z"
}
```

**Response (200 OK) - Rejected:**
```json
{
  "has_applied": true,
  "request_id": 1,
  "status": "REJECTED",
  "submitted_at": "2025-03-20T11:00:00Z",
  "documents": { ... },
  "rejected_documents": {
    "driving_license": {
      "rejected": true,
      "reason": "License expired on 2024-01-15"
    }
  },
  "admin_remarks": "Please upload a valid driving license",
  "rejection_reason": "Driving license is expired. Please upload a valid license.",
  "reviewed_at": "2025-03-20T12:00:00Z"
}
```

### 2.4 List My Role Upgrade Requests

```bash
curl -X GET http://localhost/api/auth/role/upgrade/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
[
  {
    "request_id": 1,
    "requested_role": 3,
    "requested_role_name": "transport",
    "status": "PENDING",
    "status_display": "Pending",
    "additional_info": { ... },
    "documents": [...],
    "rejection_reason": null,
    "rejected_documents": null,
    "admin_remarks": null,
    "created_at": "2025-03-20T11:00:00Z",
    "updated_at": "2025-03-20T11:00:00Z",
    "reviewed_at": null
  }
]
```

### 2.5 Get Specific Role Upgrade Request

```bash
curl -X GET http://localhost/api/auth/role/upgrade/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "requested_role": 3,
  "requested_role_name": "transport",
  "status": "PENDING",
  ...
}
```

### 2.6 Cancel Role Upgrade Request

```bash
curl -X DELETE http://localhost/api/auth/role/upgrade/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "message": "Request cancelled successfully."
}
```

**Error - Not pending (400):**
```json
{
  "error": "Only pending requests can be cancelled."
}
```

### 2.7 Get My Roles

```bash
curl -X GET http://localhost/api/auth/me/roles/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK) - Before Approval:**
```json
{
  "roles": ["farmer"]
}
```

**Response (200 OK) - After Approval:**
```json
{
  "roles": ["farmer", "transport"]
}
```

---

## 3. Provider Profile Management

> **Note:** These endpoints require the user to have the `transport` role.

### 3.1 Get My Provider Profile

```bash
curl -X GET http://localhost/api/transport/me/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "provider_id": 1,
  "user_info": {
    "user_id": 1,
    "username": "farmer_john",
    "phone": "+919876543210",
    "is_verified": true,
    "user_rating": "4.5",
    "profile_image_url": "https://storage.googleapis.com/bucket/profile.jpg"
  },
  "business_name": "Swift Animal Transport",
  "registration_no": "TRN123456789",
  "bio": "Professional animal transport service with 5 years of experience",
  "years_of_experience": 5,
  "rating": "4.8",
  "total_trips": 25,
  "available": true,
  "latitude": "18.5204000",
  "longitude": "73.8567000",
  "service_radius_km": 100,
  "is_documents_verified": true,
  "driving_license": "uploads/licenses/dl_123.jpg",
  "driving_license_url": "https://storage.googleapis.com/bucket/uploads/licenses/dl_123.jpg",
  "driving_license_number": "MH1420190001234",
  "driving_license_expiry": "2028-05-15",
  "driving_license_verified": true,
  "vehicles": [
    {
      "vehicle_id": 1,
      "vehicle_type": "TRUCK",
      "vehicle_type_display": "Truck",
      "registration_number": "MH12AB1234",
      "make": "Tata",
      "model": "407",
      "year": 2020,
      "max_weight_kg": 3000,
      "max_length_cm": 400,
      "max_width_cm": 200,
      "max_height_cm": 180,
      "is_active": true
    }
  ],
  "active_vehicles_count": 1,
  "created_at": "2025-03-20T11:00:00Z",
  "updated_at": "2025-03-20T12:00:00Z"
}
```

**Error - Profile not found (404):**
```json
{
  "error": "Transport provider profile not found."
}
```

### 3.2 Update My Provider Profile

```bash
curl -X PATCH http://localhost/api/transport/me/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "business_name": "Swift Premium Transport",
    "bio": "Updated bio - Expert in livestock transport",
    "service_radius_km": 150,
    "years_of_experience": 6
  }'
```

**Updatable Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `business_name` | string | Provider's business name |
| `registration_no` | string | Business registration number |
| `bio` | string | Description/bio |
| `years_of_experience` | integer | Years in transport business |
| `latitude` | decimal | Location latitude |
| `longitude` | decimal | Location longitude |
| `service_radius_km` | integer | Service area radius |
| `driving_license` | string | GCS path to driving license image |
| `driving_license_number` | string | License number |
| `driving_license_expiry` | date | License expiry date |

**Response (200 OK):**
```json
{
  "provider_id": 1,
  "user_info": { ... },
  "business_name": "Swift Premium Transport",
  "bio": "Updated bio - Expert in livestock transport",
  "service_radius_km": 150,
  "years_of_experience": 6,
  ...
}
```

### 3.3 Toggle Availability

```bash
curl -X PATCH http://localhost/api/transport/me/availability/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "available": true
  }'
```

**Response (200 OK):**
```json
{
  "available": true,
  "message": "Available"
}
```

**Toggle Off:**
```bash
curl -X PATCH http://localhost/api/transport/me/availability/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "available": false
  }'
```

**Response (200 OK):**
```json
{
  "available": false,
  "message": "Not available"
}
```

### 3.4 Update Location

```bash
curl -X PATCH http://localhost/api/transport/me/location/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 19.0760,
    "longitude": 72.8777
  }'
```

**Response (200 OK):**
```json
{
  "latitude": "19.0760000",
  "longitude": "72.8777000",
  "message": "Location updated successfully"
}
```

---

## 4. Vehicle Management

### 4.1 List My Vehicles

```bash
curl -X GET http://localhost/api/transport/me/vehicles/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
[
  {
    "vehicle_id": 1,
    "vehicle_type": "TRUCK",
    "vehicle_type_display": "Truck",
    "registration_number": "MH12AB1234",
    "make": "Tata",
    "model": "407",
    "year": 2020,
    "max_weight_kg": 3000,
    "max_length_cm": 400,
    "max_width_cm": 200,
    "max_height_cm": 180,
    "rc_document": "uploads/vehicles/rc_1.jpg",
    "insurance_document": "uploads/vehicles/insurance_1.jpg",
    "vehicle_images": [
      "uploads/vehicles/truck_1_front.jpg",
      "uploads/vehicles/truck_1_side.jpg"
    ],
    "vehicle_images_urls": [
      "https://storage.googleapis.com/bucket/uploads/vehicles/truck_1_front.jpg",
      "https://storage.googleapis.com/bucket/uploads/vehicles/truck_1_side.jpg"
    ],
    "is_active": true,
    "created_at": "2025-03-20T12:00:00Z",
    "updated_at": "2025-03-20T12:00:00Z"
  }
]
```

### 4.2 Add a Vehicle

```bash
curl -X POST http://localhost/api/transport/me/vehicles/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_type": "TRUCK",
    "registration_number": "MH12AB1234",
    "make": "Tata",
    "model": "407",
    "year": 2020,
    "max_weight_kg": 3000,
    "max_length_cm": 400,
    "max_width_cm": 200,
    "max_height_cm": 180,
    "rc_document": "uploads/vehicles/rc_1.jpg",
    "insurance_document": "uploads/vehicles/insurance_1.jpg",
    "vehicle_images": [
      "uploads/vehicles/truck_1_front.jpg",
      "uploads/vehicles/truck_1_side.jpg"
    ]
  }'
```

**Vehicle Types:**
| Type | Description |
|------|-------------|
| `PICKUP` | Pickup truck |
| `MINI_TRUCK` | Mini truck |
| `TRUCK` | Standard truck |
| `TRAILER` | Trailer |
| `TEMPO` | Tempo |
| `OTHER` | Other vehicle type |

**Response (201 Created):**
```json
{
  "vehicle_id": 1,
  "vehicle_type": "TRUCK",
  "vehicle_type_display": "Truck",
  "registration_number": "MH12AB1234",
  "make": "Tata",
  "model": "407",
  "year": 2020,
  "max_weight_kg": 3000,
  "max_length_cm": 400,
  "max_width_cm": 200,
  "max_height_cm": 180,
  "rc_document": "uploads/vehicles/rc_1.jpg",
  "insurance_document": "uploads/vehicles/insurance_1.jpg",
  "vehicle_images": [
    "uploads/vehicles/truck_1_front.jpg",
    "uploads/vehicles/truck_1_side.jpg"
  ],
  "vehicle_images_urls": [
    "https://storage.googleapis.com/bucket/uploads/vehicles/truck_1_front.jpg",
    "https://storage.googleapis.com/bucket/uploads/vehicles/truck_1_side.jpg"
  ],
  "is_active": true,
  "created_at": "2025-03-20T12:00:00Z",
  "updated_at": "2025-03-20T12:00:00Z"
}
```

**Error - Duplicate Registration (400):**
```json
{
  "registration_number": ["A vehicle with this registration number already exists."]
}
```

### 4.3 Get Vehicle Details

```bash
curl -X GET http://localhost/api/transport/me/vehicles/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "vehicle_id": 1,
  "vehicle_type": "TRUCK",
  "vehicle_type_display": "Truck",
  "registration_number": "MH12AB1234",
  ...
}
```

### 4.4 Update Vehicle

```bash
curl -X PATCH http://localhost/api/transport/me/vehicles/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "max_weight_kg": 3500,
    "is_active": true
  }'
```

**Response (200 OK):**
```json
{
  "vehicle_id": 1,
  "max_weight_kg": 3500,
  "is_active": true,
  ...
}
```

### 4.5 Delete Vehicle

```bash
curl -X DELETE http://localhost/api/transport/me/vehicles/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (204 No Content):**
No response body.

---

## 5. Transport Request Flow (Requestor Side)

### 5.1 Estimate Fare

> Public endpoint - no authentication required.

```bash
curl -X POST http://localhost/api/transport/estimate/ \
  -H "Content-Type: application/json" \
  -d '{
    "source_latitude": 18.5204,
    "source_longitude": 73.8567,
    "destination_latitude": 19.0760,
    "destination_longitude": 72.8777,
    "cargo_animals": [
      {"animal_id": 1, "count": 2},
      {"animal_id": 5, "count": 1}
    ]
  }'
```

**Response (200 OK):**
```json
{
  "distance_km": 150.5,
  "estimated_weight_kg": 950.0,
  "min_fare": 2450.70,
  "max_fare": 3267.60,
  "base_fare": 2722.50,
  "cargo_breakdown": [
    {
      "animal_id": 1,
      "species": "Cow",
      "breed": "Gir",
      "count": 2,
      "weight_per_animal": 400.0,
      "subtotal_weight": 800.0
    },
    {
      "animal_id": 5,
      "species": "Goat",
      "breed": "Sirohi",
      "count": 1,
      "weight_per_animal": 50.0,
      "subtotal_weight": 50.0
    }
  ]
}
```

**Error - No animals (400):**
```json
{
  "cargo_animals": ["At least one animal is required."]
}
```

### 5.2 Create Transport Request

```bash
curl -X POST http://localhost/api/transport/requests/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "source_address": "123 Farm Road, Pune, Maharashtra 411001",
    "source_latitude": 18.5204,
    "source_longitude": 73.8567,
    "destination_address": "456 Market Street, Mumbai, Maharashtra 400001",
    "destination_latitude": 19.0760,
    "destination_longitude": 72.8777,
    "cargo_animals": [
      {"animal_id": 1, "count": 2},
      {"animal_id": 5, "count": 1}
    ],
    "pickup_date": "2025-03-25",
    "pickup_time": "08:00:00",
    "notes": "Handle with care - pregnant cow included"
  }'
```

**Required Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source_address` | string | Yes | Pickup location address |
| `source_latitude` | decimal | Yes | Pickup location latitude |
| `source_longitude` | decimal | Yes | Pickup location longitude |
| `destination_address` | string | Yes | Delivery location address |
| `destination_latitude` | decimal | Yes | Delivery location latitude |
| `destination_longitude` | decimal | Yes | Delivery location longitude |
| `cargo_animals` | array | Yes | Array of `{animal_id, count}` objects |
| `pickup_date` | date | Yes | Pickup date (YYYY-MM-DD) |
| `pickup_time` | time | Yes | Pickup time (HH:MM:SS) |
| `notes` | string | No | Additional notes for provider |

**Response (201 Created):**
```json
{
  "request_id": 1,
  "requestor_info": {
    "user_id": 1,
    "username": "farmer_john",
    "phone": "+919876543210",
    "is_verified": true,
    "user_rating": "4.5",
    "profile_image_url": null
  },
  "provider_info": null,
  "vehicle_info": null,
  "source_address": "123 Farm Road, Pune, Maharashtra 411001",
  "source_latitude": "18.5204000",
  "source_longitude": "73.8567000",
  "destination_address": "456 Market Street, Mumbai, Maharashtra 400001",
  "destination_latitude": "19.0760000",
  "destination_longitude": "72.8777000",
  "distance_km": "150.50",
  "cargo_animals": [
    {"animal_id": 1, "count": 2},
    {"animal_id": 5, "count": 1}
  ],
  "cargo_breakdown": [
    {
      "animal_id": 1,
      "species": "Cow",
      "breed": "Gir",
      "count": 2,
      "weight_per_animal": 400.0,
      "subtotal_weight": 800.0
    },
    {
      "animal_id": 5,
      "species": "Goat",
      "breed": "Sirohi",
      "count": 1,
      "weight_per_animal": 50.0,
      "subtotal_weight": 50.0
    }
  ],
  "estimated_weight_kg": "950.00",
  "notes": "Handle with care - pregnant cow included",
  "pickup_date": "2025-03-25",
  "pickup_time": "08:00:00",
  "estimated_fare_min": "2450.70",
  "estimated_fare_max": "3267.60",
  "proposed_fare": null,
  "final_fare": null,
  "fare_approved_by_requestor": false,
  "fare_approved_by_provider": false,
  "status": "PENDING",
  "status_display": "Pending",
  "current_notification_radius_km": 5,
  "expires_at": "2025-03-21T10:00:00Z",
  "accepted_at": null,
  "started_at": null,
  "completed_at": null,
  "cancelled_at": null,
  "cancellation_reason": null,
  "created_at": "2025-03-20T10:00:00Z",
  "updated_at": "2025-03-20T10:00:00Z"
}
```

**Error - Already has active request (400):**
```json
{
  "non_field_errors": [
    "You already have an active transport request. Please complete or cancel it before creating a new one."
  ]
}
```

**Error - Past pickup date (400):**
```json
{
  "pickup_date": ["Pickup date cannot be in the past."]
}
```

### 5.3 List My Transport Requests

```bash
curl -X GET http://localhost/api/transport/requests/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**With status filter:**
```bash
curl -X GET "http://localhost/api/transport/requests/?status=PENDING" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "request_id": 1,
      "requestor_info": { ... },
      "provider_info": null,
      "source_address": "123 Farm Road, Pune",
      "destination_address": "456 Market Street, Mumbai",
      "distance_km": "150.50",
      "estimated_weight_kg": "950.00",
      "pickup_date": "2025-03-25",
      "pickup_time": "08:00:00",
      "estimated_fare_min": "2450.70",
      "estimated_fare_max": "3267.60",
      "proposed_fare": null,
      "final_fare": null,
      "status": "PENDING",
      "status_display": "Pending",
      "created_at": "2025-03-20T10:00:00Z"
    }
  ]
}
```

### 5.4 Get Request Details

```bash
curl -X GET http://localhost/api/transport/requests/1/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "requestor_info": { ... },
  "provider_info": {
    "provider_id": 1,
    "user_id": 2,
    "username": "transporter_1",
    "phone": "+919876543211",
    "business_name": "Fast Transport",
    "registration_no": "TRN999888",
    "rating": 4.8,
    "total_trips": 50,
    "years_of_experience": 8,
    "is_verified": true,
    "profile_image_url": null
  },
  "vehicle_info": {
    "vehicle_id": 1,
    "vehicle_type": "TRUCK",
    "vehicle_type_display": "Truck",
    "registration_number": "MH12AB1234",
    ...
  },
  "source_address": "123 Farm Road, Pune",
  "source_latitude": "18.5204000",
  "source_longitude": "73.8567000",
  "destination_address": "456 Market Street, Mumbai",
  "destination_latitude": "19.0760000",
  "destination_longitude": "72.8777000",
  "distance_km": "150.50",
  "cargo_animals": [...],
  "cargo_breakdown": [...],
  "estimated_weight_kg": "950.00",
  "notes": "Handle with care",
  "pickup_date": "2025-03-25",
  "pickup_time": "08:00:00",
  "estimated_fare_min": "2450.70",
  "estimated_fare_max": "3267.60",
  "proposed_fare": "2800.00",
  "final_fare": null,
  "fare_approved_by_requestor": false,
  "fare_approved_by_provider": true,
  "status": "ACCEPTED",
  "status_display": "Accepted",
  "current_notification_radius_km": 10,
  "expires_at": "2025-03-21T10:00:00Z",
  "accepted_at": "2025-03-20T11:00:00Z",
  "started_at": null,
  "completed_at": null,
  "cancelled_at": null,
  "cancellation_reason": null,
  "created_at": "2025-03-20T10:00:00Z",
  "updated_at": "2025-03-20T11:30:00Z"
}
```

### 5.5 Cancel Request

```bash
curl -X POST http://localhost/api/transport/requests/1/cancel/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Plans changed, no longer need transport"
  }'
```

**Response (200 OK):**
```json
{
  "message": "Transport request cancelled successfully."
}
```

**Error - Cannot cancel (400):**
```json
{
  "error": "Cannot cancel request in COMPLETED status."
}
```

**Cancellable statuses:** `PENDING`, `ACCEPTED`, `IN_PROGRESS`

### 5.6 Approve Proposed Fare

```bash
curl -X POST http://localhost/api/transport/requests/1/approve-fare/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "status": "IN_PROGRESS",
  "status_display": "In Progress",
  "proposed_fare": "2800.00",
  "final_fare": "2800.00",
  "fare_approved_by_requestor": true,
  "fare_approved_by_provider": true,
  "started_at": "2025-03-20T12:00:00Z",
  ...
}
```

**Error - No fare proposed (400):**
```json
{
  "error": "No fare has been proposed yet."
}
```

**Error - Wrong status (400):**
```json
{
  "error": "Can only approve fare for accepted requests."
}
```

### 5.7 Confirm Delivery (with Feedback)

```bash
curl -X POST http://localhost/api/transport/requests/1/confirm-delivery/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "comment": "Excellent service! Animals delivered safely and on time."
  }'
```

**Request Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `rating` | integer | Yes | Rating 1-5 |
| `comment` | string | No | Feedback comment |

**Response (200 OK):**
```json
{
  "request_id": 1,
  "status": "COMPLETED",
  "status_display": "Completed",
  "completed_at": "2025-03-25T14:00:00Z",
  ...
}
```

**Error - Not in transit (400):**
```json
{
  "error": "Can only confirm delivery for requests in transit."
}
```

---

## 6. Transport Request Flow (Provider Side)

### 6.1 List Nearby Pending Requests

```bash
curl -X GET http://localhost/api/transport/provider/requests/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
[
  {
    "request_id": 1,
    "requestor_info": {
      "user_id": 1,
      "username": "farmer_john",
      "phone": "+919876543210",
      "is_verified": true,
      "user_rating": "4.5",
      "profile_image_url": null
    },
    "source_address": "123 Farm Road, Pune",
    "source_latitude": "18.5204000",
    "source_longitude": "73.8567000",
    "destination_address": "456 Market Street, Mumbai",
    "destination_latitude": "19.0760000",
    "destination_longitude": "72.8777000",
    "distance_km": "150.50",
    "cargo_animals": [
      {"animal_id": 1, "count": 2},
      {"animal_id": 5, "count": 1}
    ],
    "cargo_breakdown": [
      {
        "animal_id": 1,
        "species": "Cow",
        "breed": "Gir",
        "count": 2,
        "weight_per_animal": 400.0,
        "subtotal_weight": 800.0
      }
    ],
    "estimated_weight_kg": "950.00",
    "pickup_date": "2025-03-25",
    "pickup_time": "08:00:00",
    "estimated_fare_min": "2450.70",
    "estimated_fare_max": "3267.60",
    "notes": "Handle with care",
    "distance_from_provider": 5.2,
    "created_at": "2025-03-20T10:00:00Z",
    "expires_at": "2025-03-21T10:00:00Z"
  }
]
```

**Error - Location not set (400):**
```json
{
  "error": "Please update your location first."
}
```

**Error - Not verified (403):**
```json
{
  "error": "Your documents are not verified yet."
}
```

### 6.2 Accept a Request

```bash
curl -X POST http://localhost/api/transport/provider/requests/1/accept/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id": 1
  }'
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "requestor_info": { ... },
  "provider_info": {
    "provider_id": 1,
    "user_id": 2,
    "username": "transporter_1",
    ...
  },
  "vehicle_info": {
    "vehicle_id": 1,
    "vehicle_type": "TRUCK",
    ...
  },
  "status": "ACCEPTED",
  "status_display": "Accepted",
  "accepted_at": "2025-03-20T11:00:00Z",
  ...
}
```

**Error - Already accepted (404):**
```json
{
  "error": "Request not found or already accepted."
}
```

**Error - Vehicle not found (400):**
```json
{
  "vehicle_id": ["Vehicle not found or doesn't belong to you."]
}
```

**Error - Vehicle not active (400):**
```json
{
  "vehicle_id": ["This vehicle is not active."]
}
```

### 6.3 Propose Fare

```bash
curl -X POST http://localhost/api/transport/provider/requests/1/propose-fare/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "proposed_fare": 2800.00
  }'
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "proposed_fare": "2800.00",
  "fare_approved_by_provider": true,
  "fare_approved_by_requestor": false,
  "status": "ACCEPTED",
  "status_display": "Accepted",
  ...
}
```

**If requestor already approved (status changes to IN_PROGRESS):**
```json
{
  "request_id": 1,
  "proposed_fare": "2800.00",
  "final_fare": "2800.00",
  "fare_approved_by_provider": true,
  "fare_approved_by_requestor": true,
  "status": "IN_PROGRESS",
  "status_display": "In Progress",
  "started_at": "2025-03-20T12:00:00Z",
  ...
}
```

**Error - Invalid fare (400):**
```json
{
  "proposed_fare": ["Fare must be greater than 0."]
}
```

**Error - Wrong status (400):**
```json
{
  "error": "Can only propose fare for accepted requests."
}
```

### 6.4 Confirm Pickup (Start Transit)

```bash
curl -X POST http://localhost/api/transport/provider/requests/1/confirm-pickup/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response (200 OK):**
```json
{
  "request_id": 1,
  "status": "IN_TRANSIT",
  "status_display": "In Transit",
  ...
}
```

**Error - Not in progress (400):**
```json
{
  "error": "Can only confirm pickup for requests in progress."
}
```

### 6.5 List My Active Jobs

```bash
curl -X GET http://localhost/api/transport/provider/my-jobs/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**With status filter:**
```bash
curl -X GET "http://localhost/api/transport/provider/my-jobs/?status=ACCEPTED" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "request_id": 1,
      "requestor_info": { ... },
      "provider_info": { ... },
      "source_address": "123 Farm Road, Pune",
      "destination_address": "456 Market Street, Mumbai",
      "distance_km": "150.50",
      "estimated_weight_kg": "950.00",
      "pickup_date": "2025-03-25",
      "pickup_time": "08:00:00",
      "estimated_fare_min": "2450.70",
      "estimated_fare_max": "3267.60",
      "proposed_fare": "2800.00",
      "final_fare": "2800.00",
      "status": "IN_PROGRESS",
      "status_display": "In Progress",
      "created_at": "2025-03-20T10:00:00Z"
    }
  ]
}
```

### 6.6 Cancel Job (Provider)

```bash
curl -X POST http://localhost/api/transport/provider/requests/1/cancel/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Vehicle breakdown, cannot fulfill request"
  }'
```

**Response (200 OK):**
```json
{
  "message": "Job cancelled. Request has been re-broadcast to other providers."
}
```

> **Note:** When provider cancels, the request is reset to PENDING and re-broadcast to nearby providers.

**Error - Cannot cancel (400):**
```json
{
  "error": "Cannot cancel job in IN_TRANSIT status."
}
```

**Cancellable statuses:** `ACCEPTED`, `IN_PROGRESS`

---

## 7. Chat System

> **Note:** Chat is only available after the request is accepted (status is not `PENDING`).

### 7.1 Get Chat Messages

```bash
curl -X GET http://localhost/api/transport/requests/1/messages/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
[
  {
    "message_id": 1,
    "sender_info": {
      "user_id": 1,
      "username": "farmer_john",
      "phone": "+919876543210",
      "is_verified": true,
      "user_rating": "4.5",
      "profile_image_url": null
    },
    "body": "Hello! Can you arrive by 7:30 AM instead of 8 AM?",
    "attachments": [],
    "is_read": true,
    "created_at": "2025-03-20T11:30:00Z"
  },
  {
    "message_id": 2,
    "sender_info": {
      "user_id": 2,
      "username": "transporter_1",
      "phone": "+919876543211",
      "is_verified": true,
      "user_rating": "4.8",
      "profile_image_url": null
    },
    "body": "Yes, I can be there by 7:30 AM. No problem!",
    "attachments": [],
    "is_read": false,
    "created_at": "2025-03-20T11:35:00Z"
  }
]
```

**Error - No access (403):**
```json
{
  "error": "You do not have access to this chat."
}
```

### 7.2 Send Message

```bash
curl -X POST http://localhost/api/transport/requests/1/messages/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Please bring extra padding for the pregnant cow.",
    "attachments": []
  }'
```

**With attachments:**
```bash
curl -X POST http://localhost/api/transport/requests/1/messages/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Here is a photo of the loading dock.",
    "attachments": [
      {"type": "image", "url": "uploads/chat/dock_photo.jpg"}
    ]
  }'
```

**Response (201 Created):**
```json
{
  "message_id": 3,
  "sender_info": {
    "user_id": 1,
    "username": "farmer_john",
    ...
  },
  "body": "Please bring extra padding for the pregnant cow.",
  "attachments": [],
  "is_read": false,
  "created_at": "2025-03-20T12:00:00Z"
}
```

**Error - Request not accepted (400):**
```json
{
  "error": "Chat is available after request is accepted."
}
```

### 7.3 Get Unread Count

```bash
curl -X GET http://localhost/api/transport/requests/1/messages/unread-count/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (200 OK):**
```json
{
  "unread_count": 3
}
```

### 7.4 Mark Messages as Read

```bash
curl -X POST http://localhost/api/transport/requests/1/messages/read/ \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Response (200 OK):**
```json
{
  "marked_count": 3
}
```

---

## 8. Admin Endpoints

### 8.1 List All Role Upgrade Requests

```bash
curl -X GET http://localhost/api/auth/admin/role-requests/ \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
```

**With status filter:**
```bash
curl -X GET "http://localhost/api/auth/admin/role-requests/?status=PENDING" \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
```

**Response (200 OK):**
```json
[
  {
    "request_id": 1,
    "user_id": 1,
    "user_email": "farmer_john@example.com",
    "user_phone": "+919876543210",
    "user_username": "farmer_john",
    "requested_role": 3,
    "requested_role_name": "transport",
    "status": "PENDING",
    "additional_info": {
      "business_name": "Swift Animal Transport",
      "registration_no": "TRN123456789",
      "years_of_experience": 5,
      "bio": "Professional animal transport service",
      "driving_license": "uploads/licenses/dl_123.jpg",
      "driving_license_number": "MH1420190001234",
      "driving_license_expiry": "2028-05-15",
      "latitude": "18.5204000",
      "longitude": "73.8567000",
      "service_radius_km": 100
    },
    "documents": [
      "uploads/documents/aadhar_front.jpg",
      "uploads/documents/aadhar_back.jpg"
    ],
    "rejection_reason": null,
    "reviewed_by": null,
    "reviewed_by_username": null,
    "reviewed_at": null,
    "created_at": "2025-03-20T11:00:00Z",
    "updated_at": "2025-03-20T11:00:00Z"
  }
]
```

### 8.2 Approve Role Upgrade Request

```bash
curl -X POST http://localhost/api/auth/admin/role-requests/1/approve/ \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_notes": "All documents verified, approved."
  }'
```

**Response (200 OK):**
```json
{
  "message": "Role upgrade to transport approved successfully.",
  "user_id": 1,
  "new_role": "transport"
}
```

**Error - Already processed (400):**
```json
{
  "error": "This request has already been processed."
}
```

### 8.3 Reject Role Upgrade Request

```bash
curl -X POST http://localhost/api/auth/admin/role-requests/1/reject/ \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "rejection_reason": "Driving license is expired. Please upload a valid license.",
    "admin_remarks": "License expired on 2024-01-15",
    "rejected_documents": {
      "driving_license": {
        "rejected": true,
        "reason": "License expired on 2024-01-15"
      }
    }
  }'
```

**Response (200 OK):**
```json
{
  "message": "Role upgrade request rejected.",
  "request_id": 1
}
```

### 8.4 List All Transport Providers (Admin)

```bash
curl -X GET http://localhost/api/transport/admin/ \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
```

**With verified filter:**
```bash
curl -X GET "http://localhost/api/transport/admin/?verified=true" \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
```

**Response (200 OK):**
```json
{
  "count": 10,
  "next": null,
  "previous": null,
  "results": [
    {
      "provider_id": 1,
      "user_info": { ... },
      "business_name": "Swift Animal Transport",
      "registration_no": "TRN123456789",
      "bio": "Professional animal transport service",
      "years_of_experience": 5,
      "rating": "4.8",
      "total_trips": 25,
      "available": true,
      "is_documents_verified": true,
      "driving_license_verified": true,
      "vehicles": [...],
      "active_vehicles_count": 2,
      "created_at": "2025-03-20T11:00:00Z",
      "updated_at": "2025-03-20T12:00:00Z"
    }
  ]
}
```

---

## 9. Public Endpoints

### 9.1 List All Transport Providers (Public)

```bash
curl -X GET http://localhost/api/transport/providers/
```

**Response (200 OK):**
```json
{
  "count": 5,
  "next": null,
  "previous": null,
  "results": [
    {
      "provider_id": 1,
      "user_info": {
        "user_id": 1,
        "username": "transporter_1",
        "phone": "+919876543210",
        "is_verified": true,
        "user_rating": "4.5",
        "profile_image_url": null
      },
      "business_name": "Swift Animal Transport",
      "rating": "4.8",
      "total_trips": 25,
      "available": true,
      "years_of_experience": 5,
      "is_documents_verified": true,
      "active_vehicles_count": 2
    }
  ]
}
```

### 9.2 Get Provider Details (Public)

```bash
curl -X GET http://localhost/api/transport/providers/1/
```

**Response (200 OK):**
```json
{
  "provider_id": 1,
  "user_info": { ... },
  "business_name": "Swift Animal Transport",
  "registration_no": "TRN123456789",
  "bio": "Professional animal transport service",
  "years_of_experience": 5,
  "rating": "4.8",
  "total_trips": 25,
  "available": true,
  "latitude": "18.5204000",
  "longitude": "73.8567000",
  "service_radius_km": 100,
  "is_documents_verified": true,
  "driving_license": "uploads/licenses/dl_123.jpg",
  "driving_license_url": "https://storage.googleapis.com/bucket/uploads/licenses/dl_123.jpg",
  "driving_license_number": "MH1420190001234",
  "driving_license_expiry": "2028-05-15",
  "driving_license_verified": true,
  "vehicles": [
    {
      "vehicle_id": 1,
      "vehicle_type": "TRUCK",
      "vehicle_type_display": "Truck",
      ...
    }
  ],
  "active_vehicles_count": 2,
  "created_at": "2025-03-20T11:00:00Z",
  "updated_at": "2025-03-20T12:00:00Z"
}
```

---

## 10. Status Codes & Errors

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful deletion) |
| 400 | Bad Request - validation error |
| 401 | Unauthorized - invalid/missing token |
| 403 | Forbidden - insufficient permissions |
| 404 | Not Found |
| 500 | Server Error |

### Transport Request Status Values

| Status | Display | Description |
|--------|---------|-------------|
| `PENDING` | Pending | Waiting for provider acceptance |
| `ACCEPTED` | Accepted | Provider accepted, awaiting fare approval |
| `IN_PROGRESS` | In Progress | Fare approved, awaiting pickup |
| `IN_TRANSIT` | In Transit | Animals picked up, in transit |
| `COMPLETED` | Completed | Delivery confirmed |
| `CANCELLED` | Cancelled | Cancelled by user or provider |
| `EXPIRED` | Expired | Auto-expired after 24 hours |

### Role Upgrade Request Status Values

| Status | Description |
|--------|-------------|
| `PENDING` | Awaiting admin review |
| `APPROVED` | Role granted |
| `REJECTED` | Documents rejected |
| `CANCELLED` | User cancelled request |

### Common Error Responses

**Validation Error (400):**
```json
{
  "field_name": ["Error message for this field."]
}
```

**Unauthorized (401):**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**Forbidden (403):**
```json
{
  "error": "You do not have access to this request."
}
```

**Not Found (404):**
```json
{
  "error": "Transport request not found."
}
```

---

## 11. Flow Diagrams

### 11.1 User → Transport Provider Role Upgrade Flow

```
User (farmer role)
        │
        ▼
┌───────────────────────────────┐
│ POST /api/auth/role/upgrade/  │
│ role: "transport"             │
│ + documents, business_name,   │
│   driving_license, etc.       │
└───────────────────────────────┘
        │
        ▼
┌───────────────────────────────┐
│ Status: PENDING               │
│ kyc_status: PENDING           │
│ TransportProvider created     │
│ (is_documents_verified=false) │
└───────────────────────────────┘
        │
        ▼ (Admin reviews)
        │
   ┌────┴────┐
   │         │
   ▼         ▼
APPROVE    REJECT
   │         │
   ▼         ▼
┌──────────┐ ┌──────────────────┐
│ User has │ │ User can re-apply│
│ transport│ │ with new docs    │
│ role     │ │ PATCH /api/auth/ │
│          │ │ role/upgrade/{id}│
└──────────┘ └──────────────────┘
```

### 11.2 Transport Request Status Flow

```
                    ┌─────────┐
                    │ PENDING │
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌─────────┐    ┌───────────┐    ┌─────────┐
   │ EXPIRED │    │ CANCELLED │    │ ACCEPTED│
   │(24h auto)│   │(user/prov)│    │         │
   └─────────┘    └───────────┘    └────┬────┘
                                        │
                         ┌──────────────┼──────────────┐
                         │              │              │
                         ▼              ▼              ▼
                  ┌───────────┐ ┌───────────┐  ┌────────────┐
                  │ CANCELLED │ │  PENDING  │  │IN_PROGRESS │
                  │(user/prov)│ │(prov.cancel)│  │(fare OK)  │
                  └───────────┘ └───────────┘  └─────┬──────┘
                                                     │
                                        ┌────────────┼────────────┐
                                        │            │            │
                                        ▼            ▼            ▼
                                 ┌───────────┐ ┌──────────┐ ┌───────────┐
                                 │ CANCELLED │ │IN_TRANSIT│ │  PENDING  │
                                 │(user/prov)│ │(pickup OK)│ │(prov.cancel)│
                                 └───────────┘ └─────┬────┘ └───────────┘
                                                     │
                                                     ▼
                                               ┌───────────┐
                                               │ COMPLETED │
                                               │(delivery) │
                                               └───────────┘
```

### 11.3 Complete Transport Flow Timeline

```
USER                          SYSTEM                       PROVIDER
 │                               │                            │
 ├──── Create Request ──────────►│                            │
 │                               │                            │
 │                               ├──── Broadcast (5km) ──────►│
 │                               │                            │
 │                               │    ┌────15min────┐         │
 │                               │    │             │         │
 │                               │    │ Expand to   │         │
 │                               │    │ 10km        │         │
 │                               │    └─────────────┘         │
 │                               │                            │
 │                               │◄────── Accept ─────────────┤
 │                               │         + vehicle_id       │
 │◄──── FCM: Accepted ───────────│                            │
 │                               │                            │
 │                               │◄────── Propose Fare ───────┤
 │◄──── FCM: Fare Proposed ──────│                            │
 │                               │                            │
 ├──── Approve Fare ─────────────►│                           │
 │                               │──── FCM: Fare Approved ───►│
 │                               │                            │
 │                               │  Status: IN_PROGRESS       │
 │                               │                            │
 │     ┌─────── CHAT ENABLED ────┼───────────────────────────►│
 │     │                         │                            │
 │◄────┼── Messages ◄───────────►│◄──────── Messages ────────►│
 │     │                         │                            │
 │     └─────────────────────────┼────────────────────────────┘
 │                               │                            │
 │                               │◄────── Confirm Pickup ─────┤
 │◄──── FCM: Pickup OK ──────────│                            │
 │                               │                            │
 │                               │  Status: IN_TRANSIT        │
 │                               │                            │
 ├──── Confirm Delivery ─────────►│                           │
 │     + rating, comment         │──── FCM: Delivery OK ─────►│
 │                               │                            │
 │                               │  Status: COMPLETED         │
 │                               │                            │
 └───────────────────────────────┴────────────────────────────┘
```

### 11.4 Fare Calculation Formula

```
BASE_FARE = 100 INR
PER_KM_RATE = 15 INR/km
WEIGHT_RATE = 0.02 INR/kg

base_fare = BASE_FARE + (distance_km × PER_KM_RATE) + (weight_kg × WEIGHT_RATE)

min_fare = base_fare × 0.9  (10% lower buffer)
max_fare = base_fare × 1.2  (20% upper buffer)

Example:
  Distance: 150 km
  Weight: 950 kg

  base = 100 + (150 × 15) + (950 × 0.02)
       = 100 + 2250 + 19
       = 2369 INR

  min_fare = 2369 × 0.9 = 2132.10 INR
  max_fare = 2369 × 1.2 = 2842.80 INR
```

### 11.5 Radius Expansion Schedule

| Time Since Creation | Notification Radius |
|---------------------|---------------------|
| 0 min               | 5 km                |
| 15 min              | 10 km               |
| 30 min              | 20 km               |
| 60 min              | 50 km (max)         |
| 24 hours            | EXPIRED             |

---

## 12. FCM Notifications

### Notification Types

| # | Type | Recipient | Trigger |
|---|------|-----------|---------|
| 1 | `new_transport_request` | Nearby Providers | New request created |
| 2 | `transport_request_accepted` | Requestor | Provider accepts |
| 3 | `transport_fare_proposed` | Requestor | Provider proposes fare |
| 4 | `transport_fare_approved` | Provider/Requestor | Other party approves fare |
| 5 | `transport_pickup_confirmed` | Requestor | Provider confirms pickup |
| 6 | `transport_delivery_confirmed` | Provider | User confirms delivery |
| 7 | `transport_request_cancelled` | Provider/Requestor | Other party cancels |
| 8 | `transport_request_expired` | Requestor | 24hr timeout |
| 9 | `transport_message` | Provider/Requestor | New chat message |

### Sample FCM Payloads

**new_transport_request:**
```json
{
  "notification": {
    "title": "New Transport Request",
    "body": "A new transport request is available nearby."
  },
  "data": {
    "type": "new_transport_request",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "source_address": "Nashik, Maharashtra",
    "destination_address": "Mumbai, Maharashtra",
    "pickup_date": "2025-03-25",
    "estimated_fare_min": "3500.00",
    "estimated_fare_max": "4500.00"
  }
}
```

**transport_request_accepted:**
```json
{
  "notification": {
    "title": "Request Accepted",
    "body": "Swift Transport has accepted your transport request."
  },
  "data": {
    "type": "transport_request_accepted",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "provider_name": "Swift Transport"
  }
}
```

**transport_fare_proposed:**
```json
{
  "notification": {
    "title": "Fare Proposed",
    "body": "A fare of ₹4000 has been proposed."
  },
  "data": {
    "type": "transport_fare_proposed",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "proposed_fare": "4000.00"
  }
}
```

**transport_message:**
```json
{
  "notification": {
    "title": "New Message",
    "body": "New message from Ramesh Patil"
  },
  "data": {
    "type": "transport_message",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "sender_name": "Ramesh Patil"
  }
}
```

---

## 13. Test Data

### Sample Animal IDs for Testing

| animal_id | Species | Breed | Avg Weight (kg) |
|-----------|---------|-------|-----------------|
| 1 | Cow | Gir | 400 |
| 2 | Cow | Sahiwal | 350 |
| 3 | Buffalo | Murrah | 450 |
| 4 | Buffalo | Surti | 400 |
| 5 | Goat | Sirohi | 50 |
| 6 | Goat | Beetal | 45 |
| 7 | Sheep | Patanwadi | 35 |
| 8 | Horse | Marwari | 400 |

### Sample Coordinates for Testing

| Location | Latitude | Longitude |
|----------|----------|-----------|
| Pune | 18.5204 | 73.8567 |
| Mumbai | 19.0760 | 72.8777 |
| Nashik | 19.9975 | 73.7898 |
| Aurangabad | 19.8762 | 75.3433 |
| Kolhapur | 16.7050 | 74.2433 |

### Test User Credentials (Development Only)

**Regular User:**
```
username: farmer_john
email: farmer_john@example.com
password: SecurePass123!
```

**Admin User:**
```
username: admin
email: admin@example.com
password: AdminPass123!
```

---

## Endpoint Summary

### Auth App Endpoints (`/api/auth/`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/register/` | No | Register new user |
| POST | `/send-login-otp/` | No | Request login OTP |
| POST | `/login/` | No | Login with OTP |
| POST | `/login-email/` | No | Login with password |
| POST | `/logout/` | Yes | Logout user |
| POST | `/token/refresh/` | No | Refresh access token |
| GET | `/me/` | Yes | Get current user |
| PATCH | `/me/` | Yes | Update current user |
| GET | `/me/roles/` | Yes | Get user's roles |
| GET/POST | `/role/upgrade/` | Yes | List/apply for role upgrade |
| GET/DELETE/PATCH | `/role/upgrade/{id}/` | Yes | Manage role upgrade request |
| GET | `/transport/verification-status/` | Yes | Check transport verification status |
| GET | `/admin/role-requests/` | Admin | List all role requests |
| POST | `/admin/role-requests/{id}/approve/` | Admin | Approve request |
| POST | `/admin/role-requests/{id}/reject/` | Admin | Reject request |

### Transport App Endpoints (`/api/transport/`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/providers/` | No | List verified providers (public) |
| GET | `/providers/{id}/` | No | Get provider details (public) |
| GET/PATCH | `/me/` | Transport | Manage own profile |
| PATCH | `/me/availability/` | Transport | Toggle availability |
| PATCH | `/me/location/` | Transport | Update location |
| GET/POST | `/me/vehicles/` | Transport | List/add vehicles |
| GET/PATCH/DELETE | `/me/vehicles/{id}/` | Transport | Manage vehicle |
| POST | `/estimate/` | No | Estimate fare (public) |
| GET/POST | `/requests/` | Yes | List/create requests |
| GET | `/requests/{id}/` | Yes | Get request details |
| POST | `/requests/{id}/cancel/` | Yes | Cancel request |
| POST | `/requests/{id}/approve-fare/` | Yes | Approve fare |
| POST | `/requests/{id}/confirm-delivery/` | Yes | Confirm delivery |
| GET | `/provider/requests/` | Transport | List nearby requests |
| GET | `/provider/my-jobs/` | Transport | List my jobs |
| POST | `/provider/requests/{id}/accept/` | Transport | Accept request |
| POST | `/provider/requests/{id}/propose-fare/` | Transport | Propose fare |
| POST | `/provider/requests/{id}/confirm-pickup/` | Transport | Confirm pickup |
| POST | `/provider/requests/{id}/cancel/` | Transport | Cancel job |
| GET/POST | `/requests/{id}/messages/` | Yes | List/send messages |
| GET | `/requests/{id}/messages/unread-count/` | Yes | Get unread count |
| POST | `/requests/{id}/messages/read/` | Yes | Mark as read |
| GET | `/admin/` | Admin | List all providers (admin) |

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2025-03-20 | 1.0 | Comprehensive documentation with all curl commands |
