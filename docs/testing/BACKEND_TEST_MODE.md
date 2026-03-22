# Backend Test Mode — Fixed OTP Configuration

Configure the FarmerApp Django backend to accept a **fixed test OTP** during automated UI testing so Maestro flows can complete OTP login without SMS delivery.

---

## Why This Is Needed

Maestro cannot intercept real SMS messages. The login helper (`maestro/helpers/login_helper.yaml`) uses a hardcoded OTP from the `FARMERAPP_TEST_OTP` environment variable. The backend must accept this value instead of a real one-time code.

---

## Django Settings Change

In your Django settings file (e.g. `settings/test.py` or guarded by an env flag):

```python
# settings/base.py (or settings/test.py)

# Allow a fixed OTP for automated testing when this env var is set.
# NEVER set this in production.
TEST_MODE_FIXED_OTP = os.environ.get("FARMERAPP_FIXED_OTP", "")
```

In your OTP verification view / utility:

```python
from django.conf import settings

def verify_otp(phone_number: str, provided_otp: str) -> bool:
    # Test mode: accept fixed OTP if configured
    if settings.TEST_MODE_FIXED_OTP and provided_otp == settings.TEST_MODE_FIXED_OTP:
        return True

    # Normal production verification
    return cache.get(f"otp:{phone_number}") == provided_otp
```

---

## Running the Backend in Test Mode

Set the environment variable before starting the server:

```bash
FARMERAPP_FIXED_OTP=123456 python manage.py runserver
```

Or add to your `.env` (development only):

```env
FARMERAPP_FIXED_OTP=123456
```

> **Warning:** Never set `FARMERAPP_FIXED_OTP` on a production server. Gate the logic with an explicit environment check or Django `DEBUG` flag if needed.

---

## Test Account Requirements

The test phone number used in `.env.test` must:

1. Exist in the database (`User` table or equivalent).
2. Be associated with a farmer role (so the home screen loads after login).
3. Not have active rate-limiting that blocks repeated OTP requests.

### Creating a test user via Django shell

```python
# python manage.py shell
from accounts.models import User, UserProfile

phone = "919876543210"
user, created = User.objects.get_or_create(phone_number=phone)
if created:
    user.set_unusable_password()
    user.save()
    UserProfile.objects.create(user=user, role="farmer")
    print(f"Created test user: {phone}")
else:
    print(f"Test user already exists: {phone}")
```

---

## CI Configuration

In GitHub Actions the backend URL and test credentials are passed as secrets:

```yaml
env:
  FARMERAPP_TEST_PHONE: ${{ secrets.FARMERAPP_TEST_PHONE }}
  FARMERAPP_TEST_OTP:   ${{ secrets.FARMERAPP_TEST_OTP }}
```

The backend deployment in CI / staging must have `FARMERAPP_FIXED_OTP` set to match `FARMERAPP_TEST_OTP`.

---

## Rate Limit Bypass

If the backend enforces OTP request rate limits (e.g., max 3 per hour per number), add an exception for the test phone number:

```python
TEST_PHONE_NUMBERS = set(
    filter(None, os.environ.get("FARMERAPP_TEST_PHONES", "").split(","))
)

def send_otp(phone_number: str) -> None:
    if phone_number in TEST_PHONE_NUMBERS:
        return  # Skip actual SMS; fixed OTP will be accepted on verify

    # ... normal OTP generation and SMS send
```

---

## Verifying Test Mode Works

```bash
# 1. Start backend with fixed OTP
FARMERAPP_FIXED_OTP=123456 python manage.py runserver

# 2. Run the auth smoke flow
maestro test maestro/flows/01_auth/01_otp_login_success.yaml \
  --env FARMERAPP_TEST_PHONE=919876543210 \
  --env FARMERAPP_TEST_OTP=123456

# Expected: flow passes, screenshot shows home screen
```
