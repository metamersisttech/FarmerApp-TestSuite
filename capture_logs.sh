#!/bin/bash
# Flutter log capture script

echo "Starting Flutter log capture..."
echo "Logs will be saved to: consolelogs"

# Clear previous logs
> consolelogs

# Run flutter and capture ALL logs (includes framework, app, and errors)
flutter run -d emulator --verbose 2>&1 | tee consolelogs
