# Runtime Log Review - "App Not Responding" Investigation

**Date:** 2026-03-02
**Symptom:** "flutter_app is not responding" dialog after some time
**Log capture:** 2 minutes, 1679 lines, PID 10945

---

## 2-Minute Log Summary

| Metric | Count |
|--------|-------|
| Frame skips | 6 (44, 83, 74, 206, 40, 40) |
| Firestore PERMISSION_DENIED | 20 |
| GC events | 19 |
| API requests | 83 |
| Google Play DEVELOPER_ERROR | 6 |
| Per-item parse logs | 20 |
| FCM initialized (duplicate) | 2 |

---

## CRITICAL Issues

### 1. Main Thread Overload (Skipped 44 → 83 → 206 → 74 frames)

**Severity:** CRITICAL
**Impact:** Directly causes ANR ("App Not Responding") dialog

**Root Cause:**
All startup work runs synchronously on the main (UI) thread:
- Firebase initialization
- Hive cache initialization and deserialization of `ListingModel` objects
- 3 Firestore listeners set up in `main()`
- 5+ parallel API operations kicked off in `initState` of the home screen
- Multiple `setState()` calls fire from concurrent API response callbacks, causing rapid widget rebuilds

**Evidence:** Frame skip counts escalating from 44 to 206 indicates the main thread is blocked for several seconds at a time.

**Recommended Fix (Priority: P0):**
1. Move Hive cache deserialization to an isolate (`compute()`)
2. Defer non-essential init work using `WidgetsBinding.instance.addPostFrameCallback`
3. Batch `setState()` calls — collect results then call `setState()` once
4. Stagger API calls instead of firing all 5 simultaneously in `initState`

---

### 2. Firestore PERMISSION_DENIED (repeated 5+ times)

**Severity:** CRITICAL
**Impact:** Repeated errors with exponential retry consume CPU/memory and flood logs

**Root Cause:**
`FirebaseCacheSyncService.initialize()` sets up 3 Firestore snapshot listeners inside `main()` BEFORE the user has authenticated. Firestore security rules reject unauthenticated reads, causing `PERMISSION_DENIED` errors. Each failed listener retries with backoff, logging large stack traces each time.

**Evidence:** 20 `PERMISSION_DENIED` errors in 2 minutes with exponential backoff retry pattern:
- First 5 errors within 3 seconds (11:42:53–11:42:56)
- Then retries at: +3s, +6s, +10s, +20s, +14s, +24s, +56s, +68s, +56s, +46s, +82s
- Error message: *"Cloud Firestore API has not been used in project metamersist-dc7df before or it is disabled"*
- Retries never stop — still firing at end of 2-min window

**Recommended Fix (Priority: P0):**
1. Move Firestore listener setup to AFTER successful authentication (e.g., after login completes or token is verified)
2. Gate `FirebaseCacheSyncService.initialize()` behind an auth state check
3. Add a guard so listeners are only created once per session

---

### 3. FCM Creates Second Flutter Engine

**Severity:** CRITICAL
**Impact:** Doubles resource usage (memory, CPU, Geolocator connections)

**Root Cause:**
`FLTFireBGExecutor` creates a background `FlutterEngine` instance for handling FCM background messages. This second engine initializes its own set of plugins, including Geolocator, doubling the connection count from 1 to 2.

**Evidence:** Log line `FLTFireBGExecutor: Creating background FlutterEngine instance` followed by Geolocator engine count incrementing.

**Recommended Fix (Priority: P1):**
1. Keep the background message handler minimal — avoid initializing heavy plugins in the background isolate
2. Ensure `@pragma('vm:entry-point')` background handler does not call `Firebase.initializeApp()` redundantly if already initialized
3. Consider whether background message handling is needed at all during startup; if not, defer FCM background registration

---

## MODERATE Issues

### 4. Excessive Debug Logging

**Severity:** MODERATE
**Impact:** Log noise, minor CPU overhead from string formatting and I/O

**Root Cause:**
- Dio interceptor logs full API response bodies
- Service layer logs the same response again
- Individual listing objects are logged one-by-one in loops

**Recommended Fix (Priority: P2):**
1. Remove duplicate logging — log responses in ONE place (interceptor OR service, not both)
2. Remove per-item listing logs; log count only (e.g., `"Fetched 24 listings"`)
3. Gate verbose logging behind a debug flag or `kDebugMode` check

---

### 5. Google Play Services DEVELOPER_ERROR

**Severity:** MODERATE
**Impact:** Large stack traces in logs; may affect Google Sign-In or other Google APIs

**Root Cause:**
`GoogleApiManager` fails with `SecurityException`, `ProviderInstaller` and `FlagRegistrar` also fail. This typically indicates a SHA-1 fingerprint mismatch between the app signing key and the Firebase/Google Cloud Console configuration.

**Evidence:** `DEVELOPER_ERROR` from GoogleApiManager, SecurityException stack traces.

**Recommended Fix (Priority: P2):**
1. Verify the debug and release SHA-1 fingerprints are registered in Firebase Console → Project Settings → Android app
2. Run `./gradlew signingReport` and compare output with Firebase config
3. Re-download `google-services.json` after adding any missing fingerprints

---

## Summary Table

| # | Issue | Severity | Priority | Effort |
|---|-------|----------|----------|--------|
| 1 | Main thread overload / skipped frames | CRITICAL | P0 | Medium |
| 2 | Firestore PERMISSION_DENIED before auth | CRITICAL | P0 | Low |
| 3 | FCM second Flutter engine | CRITICAL | P1 | Low |
| 4 | Excessive debug logging | MODERATE | P2 | Low |
| 5 | Google Play Services DEVELOPER_ERROR | MODERATE | P2 | Low |

**Recommended order of fixes:** #2 → #6 → #1 → #3 → #4 → #5 → #7
(#2 is the quickest win with highest impact — just move listener setup behind auth gate)

---

## NEW Issues Found in 2-Minute Capture

### 6. Chat Message Polling Every 5 Seconds (HTTP, not WebSocket)

**Severity:** HIGH
**Impact:** 83 API requests in 2 minutes; ~50 are chat polling alone. Battery drain, network overhead, server load.

**Root Cause:**
Chat screen polls `GET /messages/conversations/1/messages/` every ~5 seconds AND `GET /messages/conversations/` every ~10 seconds via HTTP polling. This continues as long as chat is open.

**Evidence (timestamps showing 5s interval):**
```
11:45:02, 11:45:08, 11:45:13, 11:45:18, 11:45:23, 11:45:28, 11:45:34, 11:45:38, 11:45:43, 11:45:48, 11:45:53, 11:45:58, 11:46:03, 11:46:08, 11:46:13...
```

**Recommended Fix (Priority: P1):**
1. Replace HTTP polling with WebSocket for real-time chat
2. If WebSocket not feasible short-term, increase poll interval to 15–30s
3. Stop polling when chat screen is backgrounded / not visible

---

### 7. GCS Upload 403 Forbidden

**Severity:** MODERATE
**Impact:** File uploads to Google Cloud Storage fail with 403

**Root Cause:**
`POST /api/upload/?category=vet_certificates` returns 500, with inner error being a 403 from `storage.googleapis.com` on bucket `metamersisttest`. The service account lacks `storage.objects.create` permission on the bucket.

**Evidence:**
```
Upload failed: 403 POST https://storage.googleapis.com/upload/storage/v1/b/metamersisttest/o
```

**Recommended Fix (Priority: P2):**
1. Grant the backend service account `Storage Object Creator` role on the `metamersisttest` bucket
2. Or check if the bucket IAM policy was recently changed

---

### 8. Excessive GC Pressure

**Severity:** LOW
**Impact:** 19 GC events in 2 minutes, some with pauses up to 20ms

**Root Cause:**
Frequent object allocation from: parsing 20 listings individually from cache, logging full API response bodies as strings, and rapid widget rebuilds from polling.

**Evidence:** GC consistently freeing 2.5–6.6MB per cycle, heap steady at ~11MB (49% free). The 787ms total GC at 11:46:46 is notable.

**Recommended Fix (Priority: P3):**
Will largely resolve itself when #1 (cache deserialization), #4 (logging), and #6 (polling) are fixed.

---

## Updated Summary Table

| # | Issue | Severity | Priority | Effort |
|---|-------|----------|----------|--------|
| 1 | Main thread overload / skipped frames | CRITICAL | P0 | Medium |
| 2 | Firestore PERMISSION_DENIED (20 in 2min, never stops) | CRITICAL | P0 | Low |
| 3 | FCM second Flutter engine | CRITICAL | P1 | Low |
| 6 | Chat HTTP polling every 5s (50+ requests/2min) | HIGH | P1 | Medium |
| 4 | Excessive debug logging | MODERATE | P2 | Low |
| 5 | Google Play Services DEVELOPER_ERROR | MODERATE | P2 | Low |
| 7 | GCS upload 403 (bucket permissions) | MODERATE | P2 | Low |
| 8 | Excessive GC pressure (19 events/2min) | LOW | P3 | — |
