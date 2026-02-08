# Flutter Vet Flow Implementation - Step-by-Step Prompt

This document serves as a step-wise implementation guide for building the Vet onboarding, verification, appointment booking, and chat features in Flutter. Each step includes the screen description, UI flow, and API curl commands.

---

## Completion Status

- [x] **Phase 1: Vet Onboarding & Verification** (Steps 1.1-1.6) — 16 new files, 4 modified
- [x] **Phase 2: Vet Profile & Availability Setup** (Steps 2.1-2.3) — 11 new files, 4 modified
- [x] **Phase 3: Browse & Book Vet Appointments** (Steps 3.1-3.5) — 11 new files, 4 modified
- [x] **Phase 4: Vet Appointment Management** (Steps 4.1-4.4) — 15 new files, 5 modified
- [x] **Phase 5: Appointment Chat** (Step 5.1) — 5 new files, 6 modified
- [ ] **Phase 6: Role Switching** (Step 6.1) — NEXT

### Phase 4 Files Created
- `lib/features/appointment/models/appointment_requestor_info.dart`
- `lib/features/appointment/models/available_slot_model.dart`
- `lib/features/appointment/models/available_slots_response.dart`
- `lib/features/appointment/controllers/vet_appointment_controller.dart`
- `lib/features/appointment/mixins/vet_appointments_state_mixin.dart`
- `lib/features/appointment/mixins/approve_appointment_state_mixin.dart`
- `lib/features/appointment/mixins/reject_appointment_state_mixin.dart`
- `lib/features/appointment/mixins/complete_appointment_state_mixin.dart`
- `lib/features/appointment/widgets/vet_request_summary_card.dart`
- `lib/features/appointment/widgets/time_slot_grid.dart`
- `lib/features/appointment/widgets/vet_appointment_card.dart`
- `lib/features/appointment/screens/vet_appointments_screen.dart`
- `lib/features/appointment/screens/approve_appointment_screen.dart`
- `lib/features/appointment/screens/reject_appointment_screen.dart`
- `lib/features/appointment/screens/complete_appointment_screen.dart`

### Phase 4 Files Modified
- `lib/features/appointment/models/appointment_model.dart` (added requestor field + vet-side helpers)
- `lib/core/constants/api_endpoints.dart` (5 vet appointment endpoints)
- `lib/core/helpers/backend_helper.dart` (5 vet appointment methods)
- `lib/features/appointment/services/appointment_service.dart` (extended AppointmentResult + 5 vet methods)
- `lib/routes/app_routes.dart` (4 vet appointment routes)

### Phase 3 Files Created
- `lib/features/appointment/models/appointment_model.dart`
- `lib/features/appointment/models/appointment_listing_item.dart`
- `lib/features/appointment/controllers/appointment_controller.dart`
- `lib/features/appointment/services/appointment_service.dart`
- `lib/features/appointment/mixins/book_appointment_state_mixin.dart`
- `lib/features/appointment/mixins/my_appointments_state_mixin.dart`
- `lib/features/appointment/mixins/appointment_detail_state_mixin.dart`
- `lib/features/appointment/widgets/consultation_mode_selector.dart`
- `lib/features/appointment/widgets/appointment_vet_info_card.dart`
- `lib/features/appointment/widgets/appointment_status_chips.dart`
- `lib/features/appointment/widgets/appointment_card.dart`
- `lib/features/appointment/widgets/appointment_status_header.dart`
- `lib/features/appointment/screens/book_appointment_screen.dart`
- `lib/features/appointment/screens/my_appointments_screen.dart`
- `lib/features/appointment/screens/appointment_detail_screen.dart`

---

# FLOW 1: VET ONBOARDING & VERIFICATION

## Step 1.1: Vet Onboarding Entry Point

**Entry Trigger:** User taps "Become a Vet" button in Profile tab.

**Pre-condition Check:** Before showing onboarding, check if user has already applied:

```bash
curl -X GET "http://34.58.83.182/api/auth/vet/verification-status/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response Scenarios:**

```json
// Scenario A: Never applied
{ "has_applied": false }
// → Show Vet Onboarding Carousel (Step 1.2)

// Scenario B: Already applied
{
  "has_applied": true,
  "status": "PENDING" | "APPROVED" | "REJECTED",
  ...
}
// → Navigate directly to Verification Status Screen (Step 1.5)
```

---

## Step 1.2: Vet Onboarding Carousel Screen

**Screen Name:** `VetOnboardingCarouselScreen`

**Purpose:** Introduce the vet registration process with informative slides.

**UI Flow:**
1. Display 3-4 PageView slides with smooth transitions
2. Show progress dots at bottom
3. "Next" button advances slides, "Skip" exits to profile
4. Final slide has "Get Started" button → navigates to Document Upload Screen

**Slide Content:**
- Slide 1: "Become a Verified Vet" - Welcome message, platform benefits
- Slide 2: "Documents Required" - List: Vet Certificate, Degree Certificate, Registration Number
- Slide 3: "Verification Process" - Admin reviews within 1-2 business days
- Slide 4: "Ready to Start?" - CTA button to begin

**Navigation:**
- Skip/Back → Return to Profile
- Get Started → Document Upload Screen (Step 1.3)

---

## Step 1.3: Document Upload Screen

**Screen Name:** `VetDocumentUploadScreen`

**Purpose:** Collect vet credentials and documents for admin verification.

**UI Layout:**
```
[App Bar: "Vet Registration" with back button]

[Scrollable Form]
├── Document Upload Card: "Vet Certificate" (required)
│   └── Tap to upload → Camera/Gallery picker → Show thumbnail
├── Document Upload Card: "Degree Certificate" (required)
│   └── Tap to upload → Camera/Gallery picker → Show thumbnail
├── TextField: "Registration Number" (required)
├── TextField: "Qualifications" (required, e.g., "BVSc, MVSc")
├── TextField: "Clinic Name" (required)
├── TextField: "College Name" (required)
├── TextField/Dropdown: "Specialization" (optional)
└── [Submit Button: "Submit for Verification"]

[Loading overlay when submitting]
```

**File Upload Flow:**
1. User taps upload card
2. Show BottomSheet: "Take Photo" / "Choose from Gallery"
3. Upload file to your storage (GCS/S3) with the /upload endpoints already implemented
4. Receive file URL (e.g., `gs://bucket/path/file.jpg`)
5. Store URL in form state
6. Display thumbnail preview with "Remove" option

**Form Validation:**
- All required fields must be filled
- Both documents must be uploaded
- Registration number format validation (optional)

**API Call on Submit:**

```bash
curl -X POST "http://34.58.83.182/api/auth/role/upgrade/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "vet",
    "vet_certificate": "gs://bucket/vet_cert.jpg",
    "degree_certificate": "gs://bucket/degree_cert.jpg",
    "registration_no": "VET-MH-2024-12345",
    "qualifications": "BVSc, MVSc (Surgery)",
    "clinic_name": "Green Valley Veterinary Clinic",
    "college_name": "Mumbai Veterinary College",
    "specialization": "Large Animals"
  }'
```

**Success Response (201 Created):**
```json
{
  "request_id": 42,
  "requested_role": 3,
  "requested_role_name": "vet",
  "status": "PENDING",
  "additional_info": {
    "vet_certificate": "gs://bucket/vet_cert.jpg",
    "degree_certificate": "gs://bucket/degree_cert.jpg",
    "registration_no": "VET-MH-2024-12345",
    "qualifications": "BVSc, MVSc (Surgery)",
    "clinic_name": "Green Valley Veterinary Clinic",
    "college_name": "Mumbai Veterinary College",
    "specialization": "Large Animals"
  },
  "documents": ["gs://bucket/vet_cert.jpg", "gs://bucket/degree_cert.jpg"],
  "rejection_reason": null,
  "rejected_documents": null,
  "admin_remarks": null,
  "created_at": "2026-02-08T10:30:00Z",
  "updated_at": "2026-02-08T10:30:00Z",
  "reviewed_at": null
}
```

**Error Response (400 Bad Request):**
```json
{
  "role": ["This field is required."],
  "vet_certificate": ["This field is required for vet role upgrade."]
}
```

**Navigation on Success:**
- Store `request_id` in local state/storage
- Navigate to Verification Status Screen (Step 1.5)

---

## Step 1.4: Get Verification Status (API Only)

**Purpose:** Check current verification status. Called from multiple places.

```bash
curl -X GET "http://34.58.83.182/api/auth/vet/verification-status/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Full Response Structure:**
```json
{
  "has_applied": true,
  "request_id": 42,
  "status": "PENDING",  // or "APPROVED" or "REJECTED"
  "submitted_at": "2026-02-08T10:30:00Z",
  "documents": {
    "vet_certificate": "gs://bucket/vet_cert.jpg",
    "degree_certificate": "gs://bucket/degree_cert.jpg",
    "registration_no": "VET-MH-2024-12345",
    "qualifications": "BVSc, MVSc (Surgery)",
    "clinic_name": "Green Valley Veterinary Clinic",
    "college_name": "Mumbai Veterinary College",
    "specialization": "Large Animals"
  },
  "rejected_documents": null,  // or object with per-document feedback
  "admin_remarks": null,
  "rejection_reason": null,
  "reviewed_at": null
}
```

**When status is "REJECTED", rejected_documents contains:**
```json
{
  "rejected_documents": {
    "vet_certificate": {
      "rejected": true,
      "reason": "Image is blurry. Please upload a clearer photo of your certificate."
    },
    "degree_certificate": {
      "rejected": false
    }
  },
  "admin_remarks": "The vet certificate is not readable. Please resubmit.",
  "rejection_reason": "Document quality issues"
}
```

---

## Step 1.5: Verification Status Screen

**Screen Name:** `VetVerificationStatusScreen`

**Purpose:** Display the current verification status with appropriate UI.

**API Call on Screen Load:**
```bash
curl -X GET "http://34.58.83.182/api/auth/vet/verification-status/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**UI States Based on Response:**

### State A: PENDING
```
[App Bar: "Verification Status"]

[Center Content]
├── [Animated Hourglass/Clock Icon]
├── [Title: "Documents Under Review"]
├── [Subtitle: "Our team is reviewing your documents.
│    This usually takes 1-2 business days."]
├── [Info Card: "Submitted on: Feb 8, 2026"]
├── [Button: "View Submitted Documents" → opens modal/sheet]
└── [Button: "Back to Profile"]
```

**Polling (Optional):** Refresh status every 3500 seconds while on this screen.

### State B: APPROVED
```
[App Bar: "Verification Status"]

[Center Content]
├── [Green Checkmark Animation]
├── [Title: "Congratulations!"]
├── [Subtitle: "You are now a verified vet on our platform."]
├── [Benefits List:
│    • Receive appointment requests from farmers
│    • Set your weekly availability
│    • Manage your consultations]
├── [Primary Button: "Set Up Availability" → Availability Screen]
└── [Secondary Button: "Go to Vet Dashboard"]
```

### State C: REJECTED
```
[App Bar: "Verification Status"]

[Scrollable Content]
├── [Red Warning Icon]
├── [Title: "Action Required"]
├── [Subtitle: "Some documents need to be resubmitted."]
│
├── [Admin Remarks Card (if present):
│    "The vet certificate is not readable. Please resubmit."]
│
├── [For each document in documents:]
│   ├── [Document Card: "Vet Certificate"]
│   │   ├── [Status Badge: "❌ Rejected" or "✓ Accepted"]
│   │   ├── [Reason: "Image is blurry..." (if rejected)]
│   │   ├── [Thumbnail of current upload]
│   │   └── [Button: "Re-upload" (if rejected)]
│   │
│   └── [Document Card: "Degree Certificate"]
│       ├── [Status Badge: "✓ Accepted"]
│       └── [Thumbnail of current upload]
│
└── [Button: "Resubmit Documents" → triggers re-upload flow]
```

---

## Step 1.6: Document Re-upload Screen

**Screen Name:** `VetDocumentReuploadScreen`

**Purpose:** Allow user to re-upload only the rejected documents.

**Pre-requisite:** Fetch verification status to know which documents were rejected.

**UI Layout:**
```
[App Bar: "Resubmit Documents"]

[Info Banner: "Only rejected documents need to be re-uploaded"]

[For each rejected document:]
├── [Document Card]
│   ├── [Label: "Vet Certificate"]
│   ├── [Rejection Reason: "Image is blurry..."]
│   ├── [Current: thumbnail with red border]
│   ├── [New Upload Area: "Tap to upload new document"]
│   └── [Preview of new upload (if selected)]

[Accepted documents shown as read-only with green checkmark]

[Button: "Submit Updated Documents"]
```

**API Call on Submit:**

```bash
curl -X PATCH "http://34.58.83.182/api/auth/role/upgrade/<REQUEST_ID>/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vet_certificate": "gs://bucket/new_vet_cert.jpg"
  }'
```

**Note:** Only include fields that are being re-uploaded.

**Success Response (200 OK):**
```json
{
  "request_id": 42,
  "status": "PENDING",
  "message": "Documents updated. Your application is under review."
}
```

**Navigation on Success:**
- Navigate back to Verification Status Screen
- Status will now show as PENDING again

---

# FLOW 2: VET PROFILE & AVAILABILITY SETUP

**Pre-condition:** User must have "vet" role (status = APPROVED).

## Step 2.1: Vet Profile Screen

**Screen Name:** `VetProfileScreen`

**Purpose:** Allow verified vets to view and edit their professional profile.

**Get Profile:**
```bash
curl -X GET "http://34.58.83.182/api/vets/me/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "vet_id": 15,
  "user": {
    "id": 42,
    "username": "dr_sharma",
    "email": "dr.sharma@email.com"
  },
  "clinic_name": "Green Valley Veterinary Clinic",
  "qualifications": "BVSc, MVSc (Surgery)",
  "registration_no": "VET-MH-2024-12345",
  "specialization": "Large Animals",
  "bio": "Experienced veterinarian with 10 years in large animal care.",
  "specializations": ["Large Animals", "Surgery", "Emergency Care"],
  "years_of_experience": 10,
  "consultation_fee": "500.00",
  "video_consultation_fee": "400.00",
  "home_visit_fee": "1000.00",
  "emergency_fee_multiplier": "1.50",
  "available": true,
  "latitude": "19.0760",
  "longitude": "72.8777",
  "is_documents_verified": true
}
```

**Update Profile:**
```bash
curl -X PATCH "http://34.58.83.182/api/vets/me/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Updated bio text here",
    "years_of_experience": 12,
    "available": true
  }'
```

**UI Layout:**
```
[App Bar: "Vet Profile" with Edit button]

[Profile Header]
├── [Profile Image]
├── [Name: "Dr. Sharma"]
├── [Clinic: "Green Valley Veterinary Clinic"]
└── [Verified Badge]

[Sections with Edit capability]
├── [Bio Section]
├── [Specializations: Chip list]
├── [Experience: "10 years"]
├── [Location: Map picker]
└── [Availability Toggle: On/Off]

[Button: "Manage Availability" → Step 2.2]
[Button: "Manage Pricing" → Step 2.3]
```

---

## Step 2.2: Availability Setup Screen

**Screen Name:** `VetAvailabilityScreen`

**Purpose:** Allow vets to set their weekly availability schedule.

**Get Current Availability:**
```bash
curl -X GET "http://34.58.83.182/api/vets/me/availability/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
[
  {
    "availability_id": 1,
    "day_of_week": 0,
    "day_name": "Monday",
    "start_time": "09:00:00",
    "end_time": "17:00:00",
    "is_active": true,
    "slot_duration_minutes": 30
  },
  {
    "availability_id": 2,
    "day_of_week": 1,
    "day_name": "Tuesday",
    "start_time": "10:00:00",
    "end_time": "16:00:00",
    "is_active": true,
    "slot_duration_minutes": 30
  }
]
```

**UI Layout:**
```
[App Bar: "Weekly Availability"]

[Day Cards - One for each day (0-6)]
├── [Monday Card]
│   ├── [Day Label: "Monday"]
│   ├── [If has slot:]
│   │   ├── [Time Range: "09:00 - 17:00"]
│   │   ├── [Edit Button]
│   │   └── [Delete Button]
│   └── [If no slot: "+ Add Availability"]
│
├── [Tuesday Card]
│   └── [Time Range: "10:00 - 16:00" with edit/delete]
│
├── [Wednesday Card]
│   └── ["+ Add Availability"]
│
└── ... [Thursday through Sunday]

[Save Button (if using bulk update)]
```

**Add New Availability Slot:**
```bash
curl -X POST "http://34.58.83.182/api/vets/me/availability/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "day_of_week": 2,
    "start_time": "09:00",
    "end_time": "13:00"
  }'
```

**Response (201 Created):**
```json
{
  "availability_id": 3,
  "day_of_week": 2,
  "day_name": "Wednesday",
  "start_time": "09:00:00",
  "end_time": "13:00:00",
  "is_active": true,
  "slot_duration_minutes": 30
}
```

**Update Existing Slot:**
```bash
curl -X PATCH "http://34.58.83.182/api/vets/me/availability/1/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_time": "08:00",
    "end_time": "18:00"
  }'
```

**Delete Slot:**
```bash
curl -X DELETE "http://34.58.83.182/api/vets/me/availability/1/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Bulk Replace All Slots (Alternative approach):**
```bash
curl -X PUT "http://34.58.83.182/api/vets/me/availability/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '[
    {"day_of_week": 0, "start_time": "09:00", "end_time": "17:00"},
    {"day_of_week": 1, "start_time": "09:00", "end_time": "17:00"},
    {"day_of_week": 2, "start_time": "09:00", "end_time": "13:00"}
  ]'
```

**Add Slot Modal UI:**
```
[Bottom Sheet / Modal]
├── [Title: "Add Availability"]
├── [Day Picker: Dropdown with Mon-Sun]
├── [Start Time: Time picker showing "09:00"]
├── [End Time: Time picker showing "17:00"]
├── [Cancel Button]
└── [Save Button]
```

---

## Step 2.3: Pricing Setup Screen

**Screen Name:** `VetPricingScreen`

**Purpose:** Allow vets to set their consultation fees.

**Get Pricing:**
```bash
curl -X GET "http://34.58.83.182/api/vets/me/pricing/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "consultation_fee": "500.00",
  "video_consultation_fee": "400.00",
  "home_visit_fee": "1000.00",
  "emergency_fee_multiplier": "1.50"
}
```

**Update Pricing:**
```bash
curl -X PATCH "http://34.58.83.182/api/vets/me/pricing/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "consultation_fee": "600.00",
    "video_consultation_fee": "450.00",
    "home_visit_fee": "1200.00",
    "emergency_fee_multiplier": "2.00"
  }'
```

**UI Layout:**
```
[App Bar: "Consultation Pricing"]

[Fee Input Cards]
├── [In-Clinic Consultation: ₹ TextField]
├── [Video Consultation: ₹ TextField]
├── [Home Visit: ₹ TextField]
├── [Emergency Multiplier: x TextField]
│   └── [Helper: "e.g., 1.5x means 50% extra"]

[Save Button]
```

---

# FLOW 3: BROWSE & BOOK VET APPOINTMENTS (USER/FARMER SIDE)

## Step 3.1: Vet List Screen

**Screen Name:** `VetListScreen`

**Purpose:** Allow farmers to browse and search available vets.

**Get Vet List:**
```bash
# Basic list
curl -X GET "http://34.58.83.182/api/vets/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# With filters
curl -X GET "http://34.58.83.182/api/vets/?available=true&specialization=Large%20Animals" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "count": 15,
  "next": "http://34.58.83.182/api/vets/?page=2",
  "previous": null,
  "results": [
    {
      "vet_id": 15,
      "user": {
        "id": 42,
        "username": "dr_sharma"
      },
      "clinic_name": "Green Valley Veterinary Clinic",
      "qualifications": "BVSc, MVSc (Surgery)",
      "specialization": "Large Animals",
      "specializations": ["Large Animals", "Surgery"],
      "years_of_experience": 10,
      "consultation_fee": "500.00",
      "bio": "Experienced veterinarian...",
      "available": true
    },
    {
      "vet_id": 16,
      "user": {
        "id": 43,
        "username": "dr_patel"
      },
      "clinic_name": "City Animal Hospital",
      "qualifications": "BVSc",
      "specialization": "Small Animals",
      "specializations": ["Small Animals", "Vaccination"],
      "years_of_experience": 5,
      "consultation_fee": "400.00",
      "bio": "Specializing in pets...",
      "available": true
    }
  ]
}
```

**UI Layout:**
```
[App Bar: "Find a Vet"]

[Search Bar: "Search by name, clinic..."]

[Filter Chips: All | Available | Nearby]

[Vet List - Scrollable]
├── [Vet Card 1]
│   ├── [Avatar/Photo]
│   ├── [Name: "Dr. Sharma"]
│   ├── [Clinic: "Green Valley Veterinary Clinic"]
│   ├── [Specialization chips: "Large Animals", "Surgery"]
│   ├── [Experience: "10 years"]
│   ├── [Fee: "₹500"]
│   ├── [Availability indicator: Green dot if available]
│   └── [Buttons: "View Profile" | "Book Now"]
│
└── [Vet Card 2] ...

[Pagination / Infinite scroll]
```

**Card Actions:**
- "View Profile" → Navigate to Vet Detail Screen (Step 3.2)
- "Book Now" → Navigate to Book Appointment Screen (Step 3.3)

---

## Step 3.2: Vet Detail Screen (Public)

**Screen Name:** `VetDetailScreen`

**Purpose:** View detailed vet information before booking.

**Get Vet Details:**
```bash
curl -X GET "http://34.58.83.182/api/vets/15/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "vet_id": 15,
  "user": {
    "id": 42,
    "username": "dr_sharma"
  },
  "clinic_name": "Green Valley Veterinary Clinic",
  "qualifications": "BVSc, MVSc (Surgery)",
  "registration_no": "VET-MH-2024-12345",
  "specialization": "Large Animals",
  "specializations": ["Large Animals", "Surgery", "Emergency Care"],
  "years_of_experience": 10,
  "bio": "Experienced veterinarian with over 10 years in large animal care...",
  "consultation_fee": "500.00",
  "video_consultation_fee": "400.00",
  "home_visit_fee": "1000.00",
  "available": true,
  "is_documents_verified": true
}
```

**Note:** Phone number is NOT included in public vet details. User can only see phone after appointment is CONFIRMED.

**Get Vet Availability:**
```bash
curl -X GET "http://34.58.83.182/api/vets/15/availability/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
[
  {"day_of_week": 0, "day_name": "Monday", "start_time": "09:00:00", "end_time": "17:00:00"},
  {"day_of_week": 1, "day_name": "Tuesday", "start_time": "10:00:00", "end_time": "16:00:00"},
  {"day_of_week": 2, "day_name": "Wednesday", "start_time": "09:00:00", "end_time": "13:00:00"}
]
```

**UI Layout:**
```
[App Bar: Back button]

[Header Section]
├── [Large Profile Image]
├── [Name: "Dr. Sharma"]
├── [Clinic: "Green Valley Veterinary Clinic"]
├── [Verified Badge ✓]
└── [Rating: ⭐ 4.8 (if reviews implemented)]

[Bio Section]
└── [Full bio text]

[Specializations Section]
└── [Chips: "Large Animals", "Surgery", "Emergency Care"]

[Availability Section]
├── [Title: "Weekly Schedule"]
├── [Monday: 09:00 - 17:00]
├── [Tuesday: 10:00 - 16:00]
├── [Wednesday: 09:00 - 13:00]
└── [Thu-Sun: Unavailable]

[Pricing Section]
├── [In-Clinic: ₹500]
├── [Video Call: ₹400]
└── [Home Visit: ₹1000]

[Bottom Button: "Book Appointment"]
```

---

## Step 3.3: Book Appointment Screen

**Screen Name:** `BookAppointmentScreen`

**Purpose:** Create an appointment request with selected vet.

**UI Layout:**
```
[App Bar: "Book Appointment"]

[Vet Info Card - Read Only]
├── [Avatar]
├── [Name: "Dr. Sharma"]
└── [Clinic: "Green Valley Veterinary Clinic"]

[Divider]

[Appointment Mode Selection]
├── [Label: "Consultation Type"]
└── [Segmented Buttons / Radio]
    ├── [In-Person: ₹500] ← Selected
    ├── [Video: ₹400]
    └── [Phone: ₹400]

[Animal Selection - Optional]
├── [Label: "Select Animal (Optional)"]
└── [Dropdown: "Choose from your listings"]
    └── [Options from user's listings]

[Notes Section]
├── [Label: "Describe the issue"]
└── [Multi-line TextField]
    └── [Placeholder: "What symptoms is your animal showing?"]

[Fee Summary]
└── [Consultation Fee: ₹500]

[Info Banner]
└── [Icon + Text: "The vet will review your request and assign a time slot."]

[Submit Button: "Request Appointment"]
```

**Get User's Listings (for animal selection):**
```bash
curl -X GET "http://34.58.83.182/api/listings/my/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Create Appointment:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "vet": 15,
    "listing": 42,
    "mode": "in_person",
    "notes": "My cow has not been eating properly for 2 days. She seems lethargic and is not producing as much milk as usual."
  }'
```

**Request Body Fields:**
- `vet` (required): Vet ID
- `listing` (optional): Animal listing ID
- `mode` (required): "in_person" | "video" | "phone" | "chat"
- `notes` (optional): Description of the issue

**Success Response (201 Created):**
```json
{
  "appointment_id": 78,
  "vet": {
    "vet_id": 15,
    "name": "Dr. Sharma",
    "clinic_name": "Green Valley Veterinary Clinic",
    "phone": null
  },
  "listing": {
    "listing_id": 42,
    "title": "Jersey Cow"
  },
  "mode": "in_person",
  "status": "REQUESTED",
  "notes": "My cow has not been eating properly for 2 days...",
  "scheduled_date": null,
  "scheduled_start_time": null,
  "scheduled_end_time": null,
  "rejection_reason": null,
  "prescription": null,
  "completion_notes": null,
  "completed_at": null,
  "fee": "500.00",
  "created_at": "2026-02-08T14:30:00Z",
  "updated_at": "2026-02-08T14:30:00Z"
}
```

**IMPORTANT:** Notice `phone: null` in vet object. Phone is hidden until status becomes CONFIRMED.

**Navigation on Success:**
- Show success dialog: "Appointment request sent! The vet will review and assign a time slot."
- Navigate to My Appointments Screen (Step 3.4)

---

## Step 3.4: My Appointments Screen (User)

**Screen Name:** `MyAppointmentsScreen`

**Purpose:** View all user's appointments with status filters.

**Get Appointments:**
```bash
# All appointments
curl -X GET "http://34.58.83.182/api/appointments/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Filter by status
curl -X GET "http://34.58.83.182/api/appointments/?status=REQUESTED" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

curl -X GET "http://34.58.83.182/api/appointments/?status=CONFIRMED" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "count": 5,
  "results": [
    {
      "appointment_id": 78,
      "vet": {
        "vet_id": 15,
        "name": "Dr. Sharma",
        "clinic_name": "Green Valley Veterinary Clinic",
        "phone": null
      },
      "listing": {"listing_id": 42, "title": "Jersey Cow"},
      "mode": "in_person",
      "status": "REQUESTED",
      "notes": "My cow has not been eating...",
      "scheduled_date": null,
      "scheduled_start_time": null,
      "scheduled_end_time": null,
      "fee": "500.00",
      "created_at": "2026-02-08T14:30:00Z"
    },
    {
      "appointment_id": 72,
      "vet": {
        "vet_id": 16,
        "name": "Dr. Patel",
        "clinic_name": "City Animal Hospital",
        "phone": "+919876543210"
      },
      "listing": null,
      "mode": "video",
      "status": "CONFIRMED",
      "notes": "General health checkup",
      "scheduled_date": "2026-02-10",
      "scheduled_start_time": "10:00:00",
      "scheduled_end_time": "10:30:00",
      "fee": "400.00",
      "created_at": "2026-02-05T09:00:00Z"
    }
  ]
}
```

**IMPORTANT - Contact Visibility:**
| Status | Vet Phone Visible | Available Actions |
|--------|-------------------|-------------------|
| REQUESTED | ❌ `null` | Cancel |
| CONFIRMED | ✅ Shown | Chat, Cancel |
| REJECTED | ❌ `null` | - |
| COMPLETED | ✅ Shown | View Details, Chat History |
| CANCELLED | ❌ `null` | - |

**UI Layout:**
```
[App Bar: "My Appointments"]

[Status Filter Chips - Horizontal Scroll]
├── [All (5)]
├── [Pending (2)] ← REQUESTED status
├── [Confirmed (1)]
├── [Completed (1)]
├── [Rejected (1)]
└── [Cancelled (0)]

[Appointment List]
├── [Appointment Card - REQUESTED]
│   ├── [Status Badge: "⏳ Pending" - Yellow]
│   ├── [Vet: "Dr. Sharma - Green Valley Clinic"]
│   ├── [Mode Icon + "In-Person"]
│   ├── [Animal: "Jersey Cow" (if linked)]
│   ├── [Notes preview: "My cow has not been eating..."]
│   ├── [Submitted: "Feb 8, 2026"]
│   ├── [Awaiting vet response...]
│   └── [Button: "Cancel"]
│
├── [Appointment Card - CONFIRMED]
│   ├── [Status Badge: "✓ Confirmed" - Green]
│   ├── [Vet: "Dr. Patel - City Animal Hospital"]
│   ├── [📅 Feb 10, 2026 | 10:00 AM]
│   ├── [📞 +91 98765 43210] ← Phone now visible!
│   ├── [Mode Icon + "Video Call"]
│   └── [Buttons: "Chat" | "View Details"]
│
└── [Empty State if no appointments]
```

**Cancel Appointment:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/78/cancel/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "appointment_id": 78,
  "status": "CANCELLED",
  "message": "Appointment cancelled successfully."
}
```

---

## Step 3.5: Appointment Detail Screen (User)

**Screen Name:** `AppointmentDetailScreen`

**Purpose:** View full appointment details.

**Get Appointment Detail:**
```bash
curl -X GET "http://34.58.83.182/api/appointments/78/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:** Same structure as list item but complete.

**UI Layout (varies by status):**

```
[App Bar: "Appointment Details" with back]

[Status Header - Color coded]
├── REQUESTED: Yellow "Awaiting Vet Response"
├── CONFIRMED: Green "Appointment Confirmed"
├── REJECTED: Red "Request Rejected"
├── COMPLETED: Blue "Completed"
└── CANCELLED: Gray "Cancelled"

[Vet Info Card]
├── [Avatar]
├── [Name]
├── [Clinic]
├── [Phone: shown only if CONFIRMED/COMPLETED]
└── [Call button if phone visible]

[Schedule Card - Only if CONFIRMED/COMPLETED]
├── [📅 Date: Feb 10, 2026]
├── [🕐 Time: 10:00 AM - 10:30 AM]
└── [Mode: In-Person / Video / Phone]

[Animal Card - If linked]
├── [Animal Image]
├── [Name/Title]
└── [Button: View Listing]

[Notes Section]
└── [User's submitted notes]

[Rejection Reason - Only if REJECTED]
└── [Red card with vet's rejection reason]

[Prescription - Only if COMPLETED]
├── [Title: "Prescription"]
├── [Prescription text]
├── [Title: "Doctor's Notes"]
└── [Completion notes]

[Action Buttons - Based on status]
├── REQUESTED: [Cancel Appointment]
├── CONFIRMED: [Chat with Vet] [Cancel]
├── COMPLETED: [Chat History]
└── REJECTED/CANCELLED: None
```

---

# FLOW 4: APPOINTMENT MANAGEMENT (VET SIDE)

**Pre-condition:** User must have "vet" role.

## Step 4.1: Vet Appointments Dashboard

**Screen Name:** `VetAppointmentsScreen`

**Purpose:** View all incoming appointment requests as a vet.

**Get Vet's Appointments:**
```bash
# All appointments for this vet
curl -X GET "http://34.58.83.182/api/appointments/vet/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Filter by status
curl -X GET "http://34.58.83.182/api/appointments/vet/?status=REQUESTED" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response (Vet always sees user's phone):**
```json
{
  "count": 8,
  "results": [
    {
      "appointment_id": 78,
      "requestor": {
        "user_id": 100,
        "name": "Ramesh Kumar",
        "phone": "+919876543210"
      },
      "listing": {"listing_id": 42, "title": "Jersey Cow"},
      "mode": "in_person",
      "status": "REQUESTED",
      "notes": "My cow has not been eating properly for 2 days...",
      "scheduled_date": null,
      "scheduled_start_time": null,
      "scheduled_end_time": null,
      "fee": "500.00",
      "created_at": "2026-02-08T14:30:00Z"
    }
  ]
}
```

**IMPORTANT:** Vet ALWAYS sees `requestor.phone` regardless of status.

**UI Layout:**
```
[App Bar: "Appointment Requests"]

[Status Filter Chips]
├── [New (3)] ← REQUESTED
├── [Confirmed (2)]
├── [Completed (5)]
└── [Rejected (1)]

[Appointment Request List]
├── [Request Card - NEW]
│   ├── [🔔 Badge: "NEW REQUEST"]
│   ├── [User: "Ramesh Kumar"]
│   ├── [📞 +91 98765 43210] ← Always visible to vet
│   ├── [Animal: "Jersey Cow"]
│   ├── [Mode: "In-Person"]
│   ├── [Notes: "My cow has not been eating..."]
│   ├── [Received: "2 hours ago"]
│   └── [Buttons: "Approve" | "Reject"]
│
├── [Request Card - CONFIRMED]
│   ├── [✓ CONFIRMED]
│   ├── [User: "Suresh Patel"]
│   ├── [📅 Feb 10, 2026 | 10:00 AM]
│   ├── [📞 +91 87654 32109]
│   └── [Buttons: "Chat" | "Complete"]
│
└── ...
```

**Card Actions:**
- "Approve" → Navigate to Approve Screen (Step 4.2)
- "Reject" → Navigate to Reject Screen (Step 4.3)
- "Chat" → Navigate to Chat Screen (Flow 5)
- "Complete" → Navigate to Complete Screen (Step 4.4)

---

## Step 4.2: Approve Appointment Screen (Slot Selection)

**Screen Name:** `ApproveAppointmentScreen`

**Purpose:** Vet approves request and assigns a time slot.

**Step 1: Get Available Slots for Selected Date:**
```bash
curl -X GET "http://34.58.83.182/api/appointments/vet/15/available-slots/?date=2026-02-10" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "vet_id": 15,
  "date": "2026-02-10",
  "day_of_week": 0,
  "day_name": "Monday",
  "slots": [
    {"start_time": "09:00", "end_time": "09:30", "available": true},
    {"start_time": "09:30", "end_time": "10:00", "available": false, "reason": "booked"},
    {"start_time": "10:00", "end_time": "10:30", "available": true},
    {"start_time": "10:30", "end_time": "11:00", "available": true},
    {"start_time": "11:00", "end_time": "11:30", "available": false, "reason": "booked"},
    {"start_time": "11:30", "end_time": "12:00", "available": true},
    {"start_time": "12:00", "end_time": "12:30", "available": true},
    {"start_time": "12:30", "end_time": "13:00", "available": true}
  ]
}
```

**Slot Generation Logic:**
- Backend generates 30-minute slots based on vet's availability for that day
- Marks slots as `available: false` if already booked
- If vet has no availability for that day, returns empty slots array

**Step 2: Approve with Selected Slot:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/78/approve/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "scheduled_date": "2026-02-10",
    "start_time": "10:00"
  }'
```

**Success Response (200 OK):**
```json
{
  "appointment_id": 78,
  "requestor": {
    "user_id": 100,
    "name": "Ramesh Kumar",
    "phone": "+919876543210"
  },
  "status": "CONFIRMED",
  "scheduled_date": "2026-02-10",
  "scheduled_start_time": "10:00:00",
  "scheduled_end_time": "10:30:00",
  "message": "Appointment confirmed successfully."
}
```

**Error Response (409 Conflict - Double Booking):**
```json
{
  "error": "This time slot has already been booked. Please select another slot.",
  "code": "SLOT_UNAVAILABLE"
}
```

**UI Layout:**
```
[App Bar: "Approve Appointment"]

[Request Summary Card]
├── [User: "Ramesh Kumar"]
├── [📞 +91 98765 43210]
├── [Animal: "Jersey Cow"]
├── [Issue: "My cow has not been eating properly..."]
└── [Mode: In-Person | Fee: ₹500]

[Divider]

[Date Selection]
├── [Label: "Select Date"]
└── [Calendar Widget]
    ├── [< February 2026 >]
    ├── [Week days header]
    ├── [Dates grid]
    │   ├── [Past dates: Disabled/grayed]
    │   ├── [Available days: Selectable]
    │   └── [Selected date: Highlighted]
    └── [Note: Only dates with availability shown]

[Time Slot Selection - Shows after date selected]
├── [Label: "Available Slots for Feb 10, 2026"]
├── [Day: Monday]
└── [Slot Grid - 3 columns]
    ├── [09:00 ✓] [09:30 🔒] [10:00 ✓]
    ├── [10:30 ✓] [11:00 🔒] [11:30 ✓]
    └── [12:00 ✓] [12:30 ✓]

[Legend]
├── [✓ Available - Green/White]
└── [🔒 Booked - Gray with lock icon]

[Bottom Button: "Confirm Appointment"]
├── [Disabled until date + slot selected]
└── [Loading state while API call]
```

**Error Handling:**
- If 409 Conflict: Show snackbar "Slot just booked by another appointment. Please refresh."
- Refresh slots list automatically
- Let vet select another slot

---

## Step 4.3: Reject Appointment Screen

**Screen Name:** `RejectAppointmentScreen`

**Purpose:** Vet rejects with a reason.

**Reject Appointment:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/78/reject/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "rejection_reason": "I am fully booked for the next two weeks. Please try another vet or contact me again after February 25th."
  }'
```

**Response (200 OK):**
```json
{
  "appointment_id": 78,
  "status": "REJECTED",
  "rejection_reason": "I am fully booked for the next two weeks...",
  "message": "Appointment rejected."
}
```

**UI Layout:**
```
[App Bar: "Reject Appointment"]

[Request Summary Card]
├── [User: "Ramesh Kumar"]
├── [Animal: "Jersey Cow"]
└── [Issue: "My cow has not been eating properly..."]

[Divider]

[Rejection Reason Section]
├── [Label: "Reason for Rejection (Required)"]
├── [Multi-line TextField]
│   └── [Placeholder: "Let the farmer know why you cannot accept this request..."]
└── [Character count: "45/500"]

[Quick Reasons - Optional Chips]
├── ["Fully booked"]
├── ["Outside service area"]
├── ["Not my specialization"]
└── ["Emergency only this week"]

[Bottom Buttons]
├── [Secondary: "Cancel" → Go back]
└── [Primary: "Reject Request"]
```

---

## Step 4.4: Complete Appointment Screen

**Screen Name:** `CompleteAppointmentScreen`

**Purpose:** Vet marks appointment as completed with prescription/notes.

**Complete Appointment:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/72/complete/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "prescription": "1. Inj. Meloxicam 10ml IM - once daily for 3 days\n2. Tab. Metronidazole 400mg - twice daily for 5 days\n3. Electrolyte water - 2 liters daily\n4. Follow-up after 5 days if symptoms persist",
    "completion_notes": "Animal was found to be dehydrated with mild fever. Administered initial injection and IV fluids. Advised farmer to ensure clean water supply and proper ventilation in the shed."
  }'
```

**Response (200 OK):**
```json
{
  "appointment_id": 72,
  "status": "COMPLETED",
  "prescription": "1. Inj. Meloxicam 10ml IM...",
  "completion_notes": "Animal was found to be dehydrated...",
  "completed_at": "2026-02-10T11:15:00Z",
  "message": "Appointment marked as completed."
}
```

**UI Layout:**
```
[App Bar: "Complete Appointment"]

[Appointment Summary Card]
├── [User: "Suresh Patel"]
├── [📅 Feb 10, 2026 | 10:00 AM]
├── [Mode: In-Person]
└── [Issue: "General health checkup"]

[Divider]

[Prescription Section]
├── [Label: "Prescription"]
├── [Multi-line TextField with rich formatting hints]
│   └── [Placeholder: "Enter medicines, dosage, and instructions..."]
└── [Tip: "Use numbered list for multiple medicines"]

[Notes Section]
├── [Label: "Doctor's Notes (Optional)"]
├── [Multi-line TextField]
│   └── [Placeholder: "Additional observations, advice, follow-up instructions..."]

[Bottom Button: "Mark as Completed"]
```

---

# FLOW 5: APPOINTMENT CHAT

**Pre-condition:** Appointment status must be CONFIRMED.

## Step 5.1: Chat Screen

**Screen Name:** `AppointmentChatScreen`

**Purpose:** Real-time messaging between farmer and vet for a confirmed appointment.

**Access Check:** Chat is ONLY available when `appointment.status == "CONFIRMED"`.

**Get Messages:**
```bash
curl -X GET "http://34.58.83.182/api/appointments/72/messages/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "messages": [
    {
      "message_id": 101,
      "from_user": {
        "id": 100,
        "name": "Ramesh Kumar"
      },
      "body": "Hello doctor, what should I prepare for your visit tomorrow?",
      "attachments": null,
      "is_read": true,
      "created_at": "2026-02-09T16:30:00Z"
    },
    {
      "message_id": 102,
      "from_user": {
        "id": 42,
        "name": "Dr. Sharma"
      },
      "body": "Please ensure the animal is in a shaded area and have clean water ready. Also keep any previous medical records if you have them.",
      "attachments": null,
      "is_read": true,
      "created_at": "2026-02-09T16:45:00Z"
    },
    {
      "message_id": 103,
      "from_user": {
        "id": 100,
        "name": "Ramesh Kumar"
      },
      "body": "Noted, thank you doctor. Will keep everything ready.",
      "attachments": null,
      "is_read": false,
      "created_at": "2026-02-09T17:00:00Z"
    }
  ],
  "count": 3
}
```

**Send Message:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/72/messages/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Perfect, see you tomorrow at 10 AM."
  }'
```

**Response (201 Created):**
```json
{
  "message_id": 104,
  "from_user": {
    "id": 42,
    "name": "Dr. Sharma"
  },
  "body": "Perfect, see you tomorrow at 10 AM.",
  "attachments": null,
  "is_read": false,
  "created_at": "2026-02-09T17:05:00Z"
}
```

**Get Unread Count:**
```bash
curl -X GET "http://34.58.83.182/api/appointments/72/messages/unread-count/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "unread_count": 2
}
```

**Mark Messages as Read:**
```bash
curl -X POST "http://34.58.83.182/api/appointments/72/messages/read/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "marked_read": 2
}
```

**UI Layout:**
```
[App Bar]
├── [Back Button]
├── [Title: "Dr. Sharma" or "Ramesh Kumar"]
├── [Subtitle: "Green Valley Clinic" or "Jersey Cow Consultation"]
└── [Phone Icon - tap to call]

[Messages List - Scrollable, newest at bottom]
├── [Message Bubble - Other User (Left aligned)]
│   ├── [Avatar]
│   ├── [Message Text]
│   └── [Time: "4:30 PM"]
│
├── [Message Bubble - Current User (Right aligned)]
│   ├── [Message Text]
│   ├── [Time: "4:45 PM"]
│   └── [Read Receipt: ✓✓]
│
└── ... more messages

[Input Area - Fixed at bottom]
├── [Attachment Button 📎]
├── [Text Input: "Type a message..."]
└── [Send Button ➤]
```

**Polling Strategy (No WebSocket):**
- Poll for new messages every 5-10 seconds when chat screen is open
- Use `unread-count` endpoint for badge on appointment cards
- Call `read` endpoint when opening chat to mark all as read

**Implementation Notes:**
- Auto-scroll to bottom on new message
- Show typing indicator (optional, requires WebSocket)
- Group messages by date
- Show "Today", "Yesterday", or date headers

---

# FLOW 6: ROLE SWITCHING

## Step 6.1: Profile Tab with Role Switching

**Screen:** Existing Profile Tab

**Get User Roles:**
```bash
curl -X GET "http://34.58.83.182/api/auth/me/roles/" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

**Response:**
```json
{
  "roles": ["farmer", "vet"]
}
```

**UI Integration in Profile:**
```
[Profile Screen]
├── [Profile Header]
│   ├── [Avatar]
│   ├── [Name]
│   └── [Email]
│
├── [Role Section]
│   ├── [Label: "Current Role"]
│   └── [Dropdown/Switcher: "Farmer" ▼]
│       ├── ["Farmer" ✓] ← Currently selected
│       └── ["Vet"]
│
├── [Conditional Sections based on role]
│   ├── [If Farmer selected:]
│   │   ├── [My Farms]
│   │   ├── [My Listings]
│   │   └── [My Appointments]
│   │
│   └── [If Vet selected:]
│       ├── [Vet Profile]
│       ├── [Availability]
│       ├── [Appointment Requests]
│       └── [Pricing]
│
├── [If user only has "farmer" role:]
│   └── [Card: "Become a Vet →"]
│       └── [Tap → Vet Onboarding Carousel]
│
└── [Settings, Logout, etc.]
```

**Role Switching Logic:**
- Store selected role in local state/SharedPreferences
- Conditionally render menu items based on selected role
- Bottom navigation items may change based on role
- API calls for vet endpoints require "vet" role

---

# IMPLEMENTATION ORDER RECOMMENDATION

Follow this order for a structured implementation:

## Phase 1: Vet Onboarding (Screens 1.1 - 1.6)
1. Entry point check in Profile
2. Onboarding carousel
3. Document upload with file picker
4. Verification status screen (all 3 states)
5. Document re-upload flow

## Phase 2: Vet Profile Setup (Screens 2.1 - 2.3)
1. Vet profile view/edit
2. Availability setup with day/time picker
3. Pricing configuration

## Phase 3: Browse & Book (Screens 3.1 - 3.5)
1. Vet list with search/filter
2. Vet detail view
3. Book appointment form
4. My appointments list with filters
5. Appointment detail view

## Phase 4: Vet Appointment Management (Screens 4.1 - 4.4)
1. Vet appointments dashboard
2. Approve with slot selection
3. Reject with reason
4. Complete with prescription

## Phase 5: Chat (Screen 5.1)
1. Chat screen UI
2. Message polling
3. Read receipts

## Phase 6: Role Switching
1. Profile integration
2. Conditional navigation

---

# TESTING CHECKLIST

After implementation, verify these end-to-end flows:

## Vet Onboarding
- [ ] Check verification status before showing onboarding
- [ ] Carousel navigation works
- [ ] File upload to storage works
- [ ] Form validation prevents empty submit
- [ ] Role upgrade API creates PENDING request
- [ ] Status screen shows correct state
- [ ] Rejection shows per-document feedback
- [ ] Re-upload updates only rejected documents
- [ ] Re-upload resets status to PENDING

## Vet Availability
- [ ] Can view existing availability
- [ ] Can add new slots
- [ ] Can edit existing slots
- [ ] Can delete slots
- [ ] Time pickers work correctly

## Appointment Booking
- [ ] Can browse vet list
- [ ] Can filter by availability
- [ ] Can view vet details (no phone shown)
- [ ] Can create appointment request
- [ ] Request shows as REQUESTED
- [ ] Phone hidden until CONFIRMED

## Vet Appointment Management
- [ ] Sees all requests with user phone
- [ ] Can fetch available slots for date
- [ ] Only available slots are selectable
- [ ] Approve updates status to CONFIRMED
- [ ] Double-booking returns 409 error
- [ ] Reject stores reason
- [ ] Complete stores prescription

## Chat
- [ ] Chat only available when CONFIRMED
- [ ] Messages display correctly
- [ ] Can send new messages
- [ ] Polling fetches new messages
- [ ] Unread count updates
- [ ] Mark as read works

## Contact Visibility
- [ ] User cannot see vet phone when REQUESTED
- [ ] User can see vet phone when CONFIRMED
- [ ] User can see vet phone when COMPLETED
- [ ] Vet always sees user phone
