# Auto-login Implementation Plan

This plan implements an automatic sign-in for the Firebase account `summittpaulm@gmail.com` so the user is not prompted for credentials.

## Proposed Changes

### Core Logic

#### [MODIFY] [main.dart](file:///C:/Users/summi/GitHub/FleetControl/FleetControl_flutter/lib/main.dart)
Add logic to the `main()` function to:
1. Initialize Firebase.
2. Check if a user is already authenticated.
3. If not, perform a silent sign-in using the provided credentials (`summittpaulm@gmail.com` / `Gr1zl3yB3ar$`).
4. Proceed to launch the app.

## Verification Plan

### Manual Verification
1. Launch the application.
2. Observe that the app bypasses the login screen and lands directly on the dashboard.
3. Verify that the authenticated user is indeed `summittpaulm@gmail.com`.
