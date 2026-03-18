# Transport Flow - Frontend Integration Document

> Complete guide for Flutter frontend implementation of the Transport Owner flow.

## Table of Contents

1. [Overview](#overview)
2. [Actor Definitions](#actor-definitions)
3. [Complete Screen Flow](#complete-screen-flow)
4. [API Reference by Screen](#api-reference-by-screen)
5. [System Events (FCM)](#system-events-fcm)
6. [Request Lifecycle State Diagram](#request-lifecycle-state-diagram)
7. [Edge Cases & Error Handling](#edge-cases--error-handling)

---

## Overview

The Transport module enables livestock transport services within the FarmerApp ecosystem. Transport Owners can register as providers, manage vehicles, receive transport requests from farmers, negotiate fares, and complete deliveries.

### Key Features
- **Role-based access** - Users must upgrade to `transport` role
- **Vehicle management** - Multiple vehicles per provider
- **Real-time notifications** - FCM push for all lifecycle events
- **Fare negotiation** - Two-way approval system
- **In-app chat** - Communication between requestor and provider
- **Radius-based broadcasting** - Expanding notifications (5km → 10km → 25km → 50km)

---

## Actor Definitions

| Actor | Description | Primary Actions |
|-------|-------------|-----------------|
| **Transport Owner** | User with `transport` role | Accept requests, propose fares, manage vehicles, complete trips |
| **Farmer/User** | Any authenticated user | Create transport requests, approve fares, confirm delivery |
| **Admin** | User with `admin` role | Approve/reject role upgrade requests, verify documents |

---

## Complete Screen Flow

### Phase 1: Onboarding & Verification (Screens 1-5)

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  1. Role Request │────▶│ 2. Onboarding    │────▶│ 3. Pending        │
│     Screen       │     │    Form          │     │    Approval       │
└─────────────────┘     └──────────────────┘     └───────────────────┘
                                                          │
                        ┌──────────────────┐              │
                        │ 5. Admin Review  │◀─────────────┘
                        │    Screen        │
                        └──────────────────┘
                                │
                                ▼ (Approved)
                        ┌──────────────────┐
                        │ 4. Driving       │
                        │    License Upload│
                        └──────────────────┘
```

### Phase 2: Provider Setup (Screens 6-8)

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  6. Profile     │────▶│ 7. Vehicle       │────▶│ 8. Home/Dashboard │
│     Setup       │     │    Registration  │     │                   │
└─────────────────┘     └──────────────────┘     └───────────────────┘
```

### Phase 3: Active Operations (Screens 9-14)

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  9. Nearby      │────▶│ 10. Request      │────▶│ 11. Accept        │
│     Requests    │     │     Detail       │     │     Request       │
└─────────────────┘     └──────────────────┘     └───────────────────┘
                                                          │
┌─────────────────┐     ┌──────────────────┐              │
│ 14. Completion  │◀────│ 13. Trip         │◀─────────────┘
│                 │     │     Progress     │
└─────────────────┘     └──────────────────┘
        │                       │
        │               ┌──────────────────┐
        └──────────────▶│ 12. Chat Screen  │
                        └──────────────────┘
```

---

## API Reference by Screen

### Base URL
```
https://api.farmerapp.com/api
```

### Authentication Header
```
Authorization: Bearer <access_token>
```

---

### Screen 1: Role Request

**Purpose:** User applies for transport role

#### API: Apply for Transport Role
```bash
curl -X POST "${BASE_URL}/auth/role/upgrade/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "requested_role": "transport",
    "additional_info": {
      "business_name": "Sharma Transport Services",
      "years_of_experience": 5,
      "service_radius_km": 50
    },
    "documents": {
      "driving_license": "gs://bucket/users/123/driving_license.jpg",
      "vehicle_rc": "gs://bucket/users/123/vehicle_rc.jpg"
    }
  }'
```

**Response:**
```json
{
  "request_id": 45,
  "user": 123,
  "requested_role": "transport",
  "status": "PENDING",
  "additional_info": {
    "business_name": "Sharma Transport Services",
    "years_of_experience": 5,
    "service_radius_km": 50
  },
  "documents": {
    "driving_license": "gs://bucket/users/123/driving_license.jpg",
    "vehicle_rc": "gs://bucket/users/123/vehicle_rc.jpg"
  },
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### Screen 2: Onboarding Form

**Purpose:** Capture detailed profile information and documents

Uses the same `POST /api/auth/role/upgrade/` endpoint with complete data.

**Required Fields for Transport Role:**
| Field | Type | Required |
|-------|------|----------|
| `business_name` | string | Yes |
| `years_of_experience` | integer | No |
| `service_radius_km` | integer | No (default: 50) |
| `driving_license` | GCS path | Yes |
| `driving_license_number` | string | Yes |
| `driving_license_expiry` | date | Yes |

---

### Screen 3: Pending Approval

**Purpose:** Check application status

#### API: Check Upgrade Status
```bash
curl -X GET "${BASE_URL}/auth/role/upgrade/${REQUEST_ID}/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
{
  "request_id": 45,
  "status": "PENDING",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "reviewed_by": null,
  "reviewed_at": null,
  "rejection_reason": null,
  "rejected_documents": null,
  "admin_remarks": null
}
```

**Possible Status Values:**
- `PENDING` - Awaiting admin review
- `APPROVED` - Role granted
- `REJECTED` - Documents rejected (check `rejection_reason`)
- `CANCELLED` - User cancelled request

---

### Screen 4: Driving License Upload

**Purpose:** Upload/update driving license details (part of role upgrade)

*This is typically part of the onboarding form. If documents were rejected, user can resubmit.*

---

### Screen 5: Admin Review Screen (Admin Only)

**Purpose:** Admin approves/rejects role upgrade requests

#### API: List Pending Requests (Admin)
```bash
curl -X GET "${BASE_URL}/auth/admin/role-requests/?status=PENDING" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}"
```

#### API: Approve Request (Admin)
```bash
curl -X POST "${BASE_URL}/auth/admin/role-requests/${REQUEST_ID}/approve/" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_remarks": "Documents verified. Approved."
  }'
```

#### API: Reject Request (Admin)
```bash
curl -X POST "${BASE_URL}/auth/admin/role-requests/${REQUEST_ID}/reject/" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "rejection_reason": "Driving license expired",
    "rejected_documents": {
      "driving_license": {
        "rejected": true,
        "reason": "License expired on 2023-12-31"
      }
    }
  }'
```

---

### Screen 6: Profile Setup

**Purpose:** Transport provider sets up/updates their profile

#### API: Get My Provider Profile
```bash
curl -X GET "${BASE_URL}/transport/me/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
{
  "provider_id": 12,
  "user": {
    "id": 123,
    "phone": "+919876543210",
    "email": "provider@example.com"
  },
  "business_name": "Sharma Transport Services",
  "registration_no": "MH-12345",
  "bio": "5+ years experience in livestock transport",
  "years_of_experience": 5,
  "rating": "4.50",
  "total_trips": 42,
  "available": true,
  "latitude": "19.0760",
  "longitude": "72.8777",
  "service_radius_km": 50,
  "is_documents_verified": true,
  "driving_license_number": "MH1234567890",
  "driving_license_expiry": "2026-12-31",
  "driving_license_verified": true,
  "vehicles": [
    {
      "vehicle_id": 5,
      "vehicle_type": "TRUCK",
      "registration_number": "MH-12-AB-1234",
      "make": "Tata",
      "model": "407",
      "max_weight_kg": "2000.00"
    }
  ],
  "created_at": "2024-01-15T10:30:00Z"
}
```

#### API: Update My Provider Profile
```bash
curl -X PATCH "${BASE_URL}/transport/me/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "business_name": "Sharma Premium Transport",
    "bio": "Specialized in cattle and buffalo transport",
    "service_radius_km": 75
  }'
```

---

### Screen 7: Vehicle Registration

**Purpose:** Add/manage vehicles

#### API: List My Vehicles
```bash
curl -X GET "${BASE_URL}/transport/me/vehicles/" \
  -H "Authorization: Bearer ${TOKEN}"
```

#### API: Add Vehicle
```bash
curl -X POST "${BASE_URL}/transport/me/vehicles/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_type": "TRUCK",
    "registration_number": "MH-12-AB-1234",
    "make": "Tata",
    "model": "407",
    "year": 2020,
    "max_weight_kg": 2000,
    "max_length_cm": 450,
    "max_width_cm": 180,
    "max_height_cm": 200,
    "rc_document": "gs://bucket/vehicles/rc_doc.jpg",
    "insurance_document": "gs://bucket/vehicles/insurance.jpg",
    "vehicle_images": [
      "gs://bucket/vehicles/img1.jpg",
      "gs://bucket/vehicles/img2.jpg"
    ]
  }'
```

**Response:**
```json
{
  "vehicle_id": 5,
  "vehicle_type": "TRUCK",
  "registration_number": "MH-12-AB-1234",
  "make": "Tata",
  "model": "407",
  "year": 2020,
  "max_weight_kg": "2000.00",
  "max_length_cm": "450.00",
  "max_width_cm": "180.00",
  "max_height_cm": "200.00",
  "rc_document": "gs://bucket/vehicles/rc_doc.jpg",
  "insurance_document": "gs://bucket/vehicles/insurance.jpg",
  "vehicle_images": ["gs://bucket/vehicles/img1.jpg", "gs://bucket/vehicles/img2.jpg"],
  "is_active": true,
  "created_at": "2024-01-16T09:00:00Z"
}
```

**Vehicle Types:**
- `PICKUP`
- `MINI_TRUCK`
- `TRUCK`
- `TRAILER`
- `TEMPO`
- `OTHER`

#### API: Update Vehicle
```bash
curl -X PATCH "${BASE_URL}/transport/me/vehicles/${VEHICLE_ID}/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "is_active": true,
    "max_weight_kg": 2500
  }'
```

#### API: Delete Vehicle
```bash
curl -X DELETE "${BASE_URL}/transport/me/vehicles/${VEHICLE_ID}/" \
  -H "Authorization: Bearer ${TOKEN}"
```

---

### Screen 8: Home/Dashboard

**Purpose:** Main provider dashboard with availability toggle

#### API: Toggle Availability
```bash
curl -X PATCH "${BASE_URL}/transport/me/availability/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "available": true
  }'
```

**Response:**
```json
{
  "available": true,
  "message": "Available"
}
```

#### API: Update Location (GPS)
```bash
curl -X PATCH "${BASE_URL}/transport/me/location/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 19.0760,
    "longitude": 72.8777
  }'
```

**Response:**
```json
{
  "latitude": "19.0760000",
  "longitude": "72.8777000",
  "message": "Location updated successfully"
}
```

#### API: Get My Active Jobs
```bash
curl -X GET "${BASE_URL}/transport/provider/my-jobs/?status=ACCEPTED" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Query Parameters:**
- `status` - Filter by status (ACCEPTED, IN_PROGRESS, IN_TRANSIT, COMPLETED)

---

### Screen 9: Nearby Requests

**Purpose:** View pending transport requests in provider's area

#### API: Get Nearby Pending Requests
```bash
curl -X GET "${BASE_URL}/transport/provider/requests/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
[
  {
    "request_id": 101,
    "requestor": {
      "id": 456,
      "phone": "+919876543210",
      "full_name": "Ramesh Patil"
    },
    "source_address": "Nashik, Maharashtra",
    "source_latitude": "19.9975",
    "source_longitude": "73.7898",
    "destination_address": "Mumbai, Maharashtra",
    "destination_latitude": "19.0760",
    "destination_longitude": "72.8777",
    "distance_km": "167.50",
    "cargo_animals": [
      {"animal_id": 5, "count": 2},
      {"animal_id": 3, "count": 1}
    ],
    "estimated_weight_kg": "1200.00",
    "pickup_date": "2024-01-20",
    "pickup_time": "08:00:00",
    "estimated_fare_min": "3500.00",
    "estimated_fare_max": "4500.00",
    "notes": "Handle with care, pregnant cow",
    "distance_from_provider": 12.5,
    "expires_at": "2024-01-19T10:30:00Z",
    "created_at": "2024-01-18T10:30:00Z"
  }
]
```

**Important Notes:**
- Only returns requests within provider's `service_radius_km`
- Only returns requests where provider's location is within request's `current_notification_radius_km`
- Provider must have updated location (`latitude`, `longitude` set)
- Provider must be document-verified

---

### Screen 10: Request Detail

**Purpose:** View detailed request information

Uses the same data from the nearby requests list. No separate API needed.

**Display Fields:**
- Source & Destination addresses with map
- Cargo breakdown (animal species/breeds with counts)
- Estimated weight
- Pickup date/time
- Estimated fare range
- Requestor info & rating
- Notes

---

### Screen 11: Accept Request

**Purpose:** Accept a transport request with vehicle selection

#### API: Accept Request
```bash
curl -X POST "${BASE_URL}/transport/provider/requests/${REQUEST_ID}/accept/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "vehicle_id": 5
  }'
```

**Response:**
```json
{
  "request_id": 101,
  "status": "ACCEPTED",
  "transport_provider": {
    "provider_id": 12,
    "business_name": "Sharma Transport Services"
  },
  "vehicle": {
    "vehicle_id": 5,
    "vehicle_type": "TRUCK",
    "registration_number": "MH-12-AB-1234"
  },
  "accepted_at": "2024-01-18T11:00:00Z",
  "proposed_fare": null,
  "fare_approved_by_requestor": false,
  "fare_approved_by_provider": false
}
```

**Error Cases:**
- `404` - Request not found or already accepted by another provider
- `403` - Documents not verified
- `400` - Vehicle doesn't belong to provider

---

### Screen 12: Chat Screen

**Purpose:** In-app messaging between provider and requestor

#### API: Get Messages
```bash
curl -X GET "${BASE_URL}/transport/requests/${REQUEST_ID}/messages/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
[
  {
    "message_id": 501,
    "from_user": {
      "id": 456,
      "full_name": "Ramesh Patil"
    },
    "body": "Hello, will you be on time?",
    "attachments": [],
    "is_read": true,
    "created_at": "2024-01-18T11:30:00Z"
  },
  {
    "message_id": 502,
    "from_user": {
      "id": 123,
      "full_name": "Sharma Transport"
    },
    "body": "Yes, I will reach by 8 AM",
    "attachments": [],
    "is_read": false,
    "created_at": "2024-01-18T11:32:00Z"
  }
]
```

#### API: Send Message
```bash
curl -X POST "${BASE_URL}/transport/requests/${REQUEST_ID}/messages/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "I will reach in 30 minutes",
    "attachments": []
  }'
```

#### API: Get Unread Count
```bash
curl -X GET "${BASE_URL}/transport/requests/${REQUEST_ID}/messages/unread-count/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
{
  "unread_count": 3
}
```

#### API: Mark Messages as Read
```bash
curl -X POST "${BASE_URL}/transport/requests/${REQUEST_ID}/messages/read/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
{
  "marked_count": 3
}
```

**Note:** Chat is only available after request status is `ACCEPTED` or later.

---

### Screen 13: Trip Progress

**Purpose:** Manage trip lifecycle - propose fare, confirm pickup

#### API: Propose Fare
```bash
curl -X POST "${BASE_URL}/transport/provider/requests/${REQUEST_ID}/propose-fare/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "proposed_fare": 4000
  }'
```

**Response:**
```json
{
  "request_id": 101,
  "status": "ACCEPTED",
  "proposed_fare": "4000.00",
  "fare_approved_by_provider": true,
  "fare_approved_by_requestor": false,
  "final_fare": null
}
```

**Note:** When both `fare_approved_by_provider` AND `fare_approved_by_requestor` are true, status automatically changes to `IN_PROGRESS`.

#### API: Confirm Pickup (Start Transit)
```bash
curl -X POST "${BASE_URL}/transport/provider/requests/${REQUEST_ID}/confirm-pickup/" \
  -H "Authorization: Bearer ${TOKEN}"
```

**Response:**
```json
{
  "request_id": 101,
  "status": "IN_TRANSIT",
  "started_at": "2024-01-20T08:15:00Z"
}
```

**Pre-condition:** Status must be `IN_PROGRESS` (fare approved by both parties)

#### API: Cancel Job (Provider)
```bash
curl -X POST "${BASE_URL}/transport/provider/requests/${REQUEST_ID}/cancel/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Vehicle breakdown"
  }'
```

**Response:**
```json
{
  "message": "Job cancelled. Request has been re-broadcast to other providers."
}
```

**Note:** When provider cancels, the request returns to `PENDING` status and is re-broadcast to nearby providers.

---

### Screen 14: Completion

**Purpose:** User confirms delivery (called by requestor, not provider)

#### API: Confirm Delivery (User/Requestor)
```bash
curl -X POST "${BASE_URL}/transport/requests/${REQUEST_ID}/confirm-delivery/" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "comment": "Excellent service, very careful with animals"
  }'
```

**Response:**
```json
{
  "request_id": 101,
  "status": "COMPLETED",
  "completed_at": "2024-01-20T14:30:00Z",
  "feedback": {
    "user_rating": 5,
    "user_comment": "Excellent service, very careful with animals"
  }
}
```

---

## System Events (FCM)

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

### FCM Payload Structures

#### 1. new_transport_request
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
    "pickup_date": "2024-01-20",
    "estimated_fare_min": "3500.00",
    "estimated_fare_max": "4500.00"
  }
}
```

#### 2. transport_request_accepted
```json
{
  "notification": {
    "title": "Request Accepted",
    "body": "Sharma Transport Services has accepted your transport request."
  },
  "data": {
    "type": "transport_request_accepted",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "provider_name": "Sharma Transport Services",
    "custom_body": "Sharma Transport Services has accepted your transport request."
  }
}
```

#### 3. transport_fare_proposed
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
    "proposed_fare": "4000.00",
    "custom_body": "A fare of ₹4000 has been proposed."
  }
}
```

#### 4. transport_fare_approved
```json
{
  "notification": {
    "title": "Fare Approved",
    "body": "The fare of ₹4000 has been approved."
  },
  "data": {
    "type": "transport_fare_approved",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "final_fare": "4000.00",
    "custom_body": "The fare of ₹4000 has been approved."
  }
}
```

#### 5. transport_pickup_confirmed
```json
{
  "notification": {
    "title": "Pickup Confirmed",
    "body": "Your animals have been picked up and are now in transit."
  },
  "data": {
    "type": "transport_pickup_confirmed",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "custom_body": "Your animals have been picked up and are now in transit."
  }
}
```

#### 6. transport_delivery_confirmed
```json
{
  "notification": {
    "title": "Delivery Confirmed",
    "body": "The delivery has been confirmed by the customer."
  },
  "data": {
    "type": "transport_delivery_confirmed",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "custom_body": "The delivery has been confirmed by the customer."
  }
}
```

#### 7. transport_request_cancelled
```json
{
  "notification": {
    "title": "Request Cancelled",
    "body": "Transport request has been cancelled. Reason: Vehicle breakdown"
  },
  "data": {
    "type": "transport_request_cancelled",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "custom_body": "Transport request has been cancelled. Reason: Vehicle breakdown"
  }
}
```

#### 8. transport_request_expired
```json
{
  "notification": {
    "title": "Request Expired",
    "body": "Your transport request has expired without finding a provider."
  },
  "data": {
    "type": "transport_request_expired",
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "request_id": "101",
    "custom_body": "Your transport request has expired without finding a provider."
  }
}
```

#### 9. transport_message
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
    "sender_name": "Ramesh Patil",
    "custom_body": "New message from Ramesh Patil"
  }
}
```

---

## Request Lifecycle State Diagram

```
                    ┌────────────────────────────────────────┐
                    │                                        │
                    ▼                                        │
              ┌──────────┐                                   │
      Create  │          │  24hr timeout                     │
     ────────▶│ PENDING  │────────────────▶ EXPIRED          │
              │          │                                   │
              └────┬─────┘                                   │
                   │                                         │
                   │ Provider accepts                        │
                   ▼                                         │
              ┌──────────┐                                   │
              │          │  User/Provider cancels            │
              │ ACCEPTED │───────────────────────────────────┤
              │          │                                   │
              └────┬─────┘                                   │
                   │                                         │
                   │ Provider proposes fare                  │
                   │ User approves fare                      │
                   │ (Both must approve)                     │
                   ▼                                         │
              ┌────────────┐                                 │
              │            │  User/Provider cancels          │
              │ IN_PROGRESS│───────────────────────────────▶ │
              │            │                                 │
              └─────┬──────┘                                 │
                    │                                        │
                    │ Provider confirms pickup               │
                    ▼                                        │
              ┌───────────┐                                  │
              │           │                                  │
              │ IN_TRANSIT│                                  │
              │           │                                  │
              └─────┬─────┘                                  │
                    │                                        │
                    │ User confirms delivery                 │
                    ▼                                        │
              ┌───────────┐         ┌───────────┐            │
              │           │         │           │            │
              │ COMPLETED │         │ CANCELLED │◀───────────┘
              │           │         │           │
              └───────────┘         └───────────┘


SPECIAL CASE: Provider Cancel (ACCEPTED or IN_PROGRESS)
─────────────────────────────────────────────────────────
When provider cancels:
1. Request status → PENDING
2. Provider/vehicle cleared
3. Fare data cleared
4. Re-broadcast to nearby providers
```

### Status Descriptions

| Status | Description | Next Actions |
|--------|-------------|--------------|
| `PENDING` | Awaiting provider acceptance | Provider: Accept |
| `ACCEPTED` | Provider accepted, fare negotiation | Provider: Propose fare. User: Approve/Cancel |
| `IN_PROGRESS` | Fare agreed, ready for pickup | Provider: Confirm pickup |
| `IN_TRANSIT` | Animals picked up, en route | User: Confirm delivery |
| `COMPLETED` | Delivery confirmed | None (terminal) |
| `CANCELLED` | Cancelled by user or provider | None (terminal) |
| `EXPIRED` | No acceptance within 24 hours | None (terminal) |

---

## Edge Cases & Error Handling

### 1. Race Condition: Multiple Providers Accept

**Scenario:** Two providers try to accept the same request simultaneously.

**Backend Handling:**
- Uses `select_for_update()` for database-level locking
- First provider to acquire lock wins
- Second provider receives `404: Request not found or already accepted`

**Frontend Handling:**
```dart
try {
  await acceptRequest(requestId, vehicleId);
} catch (e) {
  if (e.statusCode == 404) {
    showSnackBar("Request was accepted by another provider");
    refreshNearbyRequests();
  }
}
```

### 2. Request Expiration

**Scenario:** User creates request, no provider accepts within 24 hours.

**Backend Handling:**
- Celery task checks for expired requests
- Status changes to `EXPIRED`
- FCM notification sent to requestor

**Frontend Handling:**
- Listen for `transport_request_expired` FCM event
- Navigate to request detail showing expired status

### 3. Provider Document Verification Pending

**Scenario:** Provider tries to accept request but documents not verified.

**API Response:**
```json
{
  "error": "Your documents are not verified yet."
}
```
**Status Code:** `403 Forbidden`

**Frontend Handling:**
- Show verification status in dashboard
- Disable "Accept" button if not verified
- Link to pending approval screen

### 4. Location Not Updated

**Scenario:** Provider tries to view nearby requests without location set.

**API Response:**
```json
{
  "error": "Please update your location first."
}
```
**Status Code:** `400 Bad Request`

**Frontend Handling:**
- Prompt for location permissions
- Show "Update Location" button
- Auto-update location on dashboard open

### 5. Chat Before Accept

**Scenario:** User tries to chat before request is accepted.

**API Response:**
```json
{
  "error": "Chat is available after request is accepted."
}
```
**Status Code:** `400 Bad Request`

**Frontend Handling:**
- Hide/disable chat button in PENDING status
- Show "Chat will be available after acceptance" message

### 6. Invalid Status Transitions

**Status-Specific Errors:**

| Current Status | Invalid Action | Error Message |
|----------------|----------------|---------------|
| PENDING | Propose fare | Cannot propose fare for pending requests |
| PENDING | Confirm pickup | Cannot confirm pickup for pending requests |
| ACCEPTED | Confirm pickup | Can only confirm pickup for requests in progress |
| IN_TRANSIT | Propose fare | Cannot modify fare during transit |
| COMPLETED | Any modification | Request already completed |
| CANCELLED | Any modification | Request was cancelled |

### 7. Network Connectivity

**Scenario:** User loses network during critical operation.

**Frontend Handling:**
```dart
// Use offline-first approach for chat
// Queue messages locally, sync when online

// For critical operations (accept, confirm):
// - Show loading indicator
// - Implement retry with exponential backoff
// - Show "Operation pending" if network lost mid-request
```

### 8. Concurrent Fare Approval

**Scenario:** Both parties approve fare simultaneously.

**Backend Handling:**
- Each approval API checks if other party already approved
- If both approved, status automatically becomes `IN_PROGRESS`
- Both parties receive `transport_fare_approved` notification

### 9. Radius Expansion

**Backend Behavior:**
- Request starts with 5km notification radius
- If no acceptance in 1 hour: expands to 10km
- After 2 hours: expands to 25km
- After 3 hours: expands to 50km
- After 24 hours: expires

**Frontend Impact:**
- Provider may receive `new_transport_request` for same request multiple times
- Check if request already in list before adding

---

## Additional Endpoints

### Fare Estimation (Public)

```bash
curl -X POST "${BASE_URL}/transport/estimate/" \
  -H "Content-Type: application/json" \
  -d '{
    "source_latitude": 19.9975,
    "source_longitude": 73.7898,
    "destination_latitude": 19.0760,
    "destination_longitude": 72.8777,
    "cargo_animals": [
      {"animal_id": 5, "count": 2},
      {"animal_id": 3, "count": 1}
    ]
  }'
```

**Response:**
```json
{
  "distance_km": 167.5,
  "estimated_weight_kg": 1200,
  "min_fare": 3500,
  "max_fare": 4500,
  "base_fare": 500,
  "cargo_breakdown": [
    {"animal_id": 5, "species": "Cattle", "breed": "Gir", "count": 2, "weight_kg": 800},
    {"animal_id": 3, "species": "Buffalo", "breed": "Murrah", "count": 1, "weight_kg": 400}
  ]
}
```

### List All Providers (Public)

```bash
curl -X GET "${BASE_URL}/transport/providers/"
```

### Get Provider Details (Public)

```bash
curl -X GET "${BASE_URL}/transport/providers/${PROVIDER_ID}/"
```

---

## Summary

This document covers the complete Transport Owner flow from role upgrade through trip completion. Key integration points:

1. **Authentication** - All endpoints (except public) require Bearer token
2. **FCM Integration** - Handle 9 notification types for real-time updates
3. **State Management** - Track request status for UI updates
4. **Error Handling** - Implement proper error handling for all edge cases
5. **Location Services** - Update provider location periodically
6. **Offline Support** - Queue chat messages for later sync

For questions or clarifications, contact the backend team.
