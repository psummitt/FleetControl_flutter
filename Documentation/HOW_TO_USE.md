# FleetControl - How To Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation & Setup](#installation--setup)
3. [Running the Application](#running-the-application)
4. [Account Registration](#account-registration)
5. [Logging In](#logging-in)
6. [Dashboard](#dashboard)
7. [Managing Vehicles](#managing-vehicles)
8. [Managing Drivers](#managing-drivers)
9. [Maintenance Tracking](#maintenance-tracking)
10. [Service Centers](#service-centers)
11. [Reports](#reports)
12. [Settings](#settings)
13. [Accessibility Features](#accessibility-features)
14. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before running FleetControl, ensure you have:

- **Flutter SDK** 3.8.1 or higher installed ([flutter.dev](https://flutter.dev))
- **Android SDK** (for Android builds) or **Android Studio**
- **Firebase CLI** installed (`npm install -g firebase-tools`)
- **FlutterFire CLI** (`dart pub global activate flutterfire_cli`)
- A **Firebase project** with Authentication and Cloud Firestore enabled

### Verify Flutter Installation

```bash
flutter doctor
```

Ensure all checkmarks pass for your target platform (Android, Web, or Windows).

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/summitech/FleetControl_flutter.git
cd FleetControl_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

The application comes pre-configured with Firebase project `fleetcontrol-ecdc1`. The following files are already in place:

- `android/app/google-services.json` (Android)
- `lib/firebase_options.dart` (All platforms)
- `web/index.html` (Web)
- `windows/` (Windows via firebase_core plugin)

If you need to reconfigure Firebase for your own project:

```bash
flutterfire configure
```

### 4. Firestore Database Setup

In the Firebase Console ([console.firebase.google.com](https://console.firebase.google.com)):

1. Go to **Firestore Database** and create a database
2. Start in **test mode** for development
3. The app will automatically create these collections on first use:
   - `companies/` - Company profiles
   - `users/` - User accounts
   - `companies/{companyId}/vehicles/` - Vehicle records
   - `companies/{companyId}/drivers/` - Driver records
   - `companies/{companyId}/maintenance/` - Maintenance records
   - `companies/{companyId}/serviceCenters/` - Service center records

### 5. Enable Authentication

In the Firebase Console:

1. Go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. (Optional) Enable additional providers as needed

---

## Running the Application

### Android

```bash
flutter run -d android
```

Or connect a physical Android device via USB with developer mode enabled:

```bash
flutter devices          # List available devices
flutter run -d <device>  # Run on specific device
```

### Web (Chrome)

```bash
flutter run -d chrome
```

The app will open at `http://localhost:<port>`.

### Windows

```bash
flutter run -d windows
```

### Build for Release

**Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Web:**
```bash
flutter build web --release
```
Output: `build/web/` (deploy to any web server or Firebase Hosting)

**Windows:**
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/`

---

## Account Registration

1. Open the app and click **"Need an account? Register"** on the login screen
2. Fill in the registration form:
   - **First Name** (required)
   - **Last Name** (required)
   - **Company Name** (required) - Your fleet company name
   - **Email** (required) - Will be your login username
   - **Password** (required) - Must be at least 8 characters with uppercase, lowercase, and a number
   - **Confirm Password** (required)
3. Check the **"I accept the Terms and Conditions"** checkbox
4. Click **"Sign Up"**

Your company and user account will be created automatically. Each company gets its own isolated data space.

---

## Logging In

1. Enter your **email address** and **password**
2. Click **"Login"**
3. If you forgot your password, click **"Forgot Password?"** to receive a reset email

**Note:** Your session persists across app restarts. You will remain logged in until you sign out.

---

## Dashboard

The Dashboard is your fleet overview screen, showing:

- **Total Vehicles** - Count of all vehicles with active status breakdown
- **Active Drivers** - Number of active drivers in your fleet
- **In Maintenance** - Vehicles currently undergoing maintenance
- **Overdue Service** - Maintenance items past their scheduled date (highlighted in red)

### Quick Actions
From the Dashboard, you can quickly access:
- **Add Vehicle** - Navigate to the vehicle form
- **Add Driver** - Navigate to the driver form
- **Log Maintenance** - Navigate to the maintenance form
- **Add Service Center** - Navigate to the service center form

### Recent Maintenance
The bottom section shows the 5 most recent maintenance records across your fleet.

---

## Managing Vehicles

### View All Vehicles
Click **"Vehicles"** in the sidebar (or navigation drawer on mobile) to see your fleet list.

**Features:**
- **Search** - Filter vehicles by name, make, model, or VIN
- **Status Filter** - Toggle between All, Active, Maintenance, and Retired
- **Grid/List View** - Desktop shows a grid; mobile shows a list

### Add a New Vehicle
1. Click **"Add Vehicle"** button
2. Fill in the **Vehicle Details** section:
   - **Vehicle Name** (required) - e.g., "Truck 001"
   - **Year** (required) - e.g., 2024
   - **Make** (required) - e.g., Ford
   - **Model** (required) - e.g., F-150
   - **VIN** - Vehicle Identification Number
   - **Color** - Vehicle color
3. Fill in **Registration & Keys**:
   - **License State** - State of registration
   - **License Number** - License plate number
   - **Ignition Key** - Key code or identifier
   - **Door Key** - Key code or identifier
4. Fill in **Purchase & Status**:
   - **Odometer** - Current mileage
   - **Purchase Price** - Acquisition cost
   - **Purchase Date** - Date of purchase
   - **Status** - Active, Maintenance, or Retired
   - **Notes** - Any additional information
5. Click **"Add Vehicle"**

### View Vehicle Details
Click any vehicle in the list to see its full details, including:
- All vehicle information
- Registration and key details
- Purchase information
- Maintenance history for this specific vehicle

### Edit a Vehicle
1. Open the vehicle's detail page
2. Click the **edit icon** (pencil) in the top-right
3. Modify any fields
4. Click **"Save Changes"**

### Delete a Vehicle
1. Open the vehicle's detail page
2. Click the **delete icon** (trash can) in the top-right
3. Confirm the deletion in the dialog

**Note:** Deleting a vehicle cannot be undone.

---

## Managing Drivers

### View All Drivers
Click **"Drivers"** in the sidebar to see your driver roster.

**Features:**
- **Search** - Filter by driver name or email
- **Grid/List View** - Responsive layout adapts to screen size

### Add a New Driver
1. Click **"Add Driver"**
2. Fill in **Personal Information**:
   - **First Name** (required)
   - **Last Name** (required)
   - **Email** (required)
   - **Phone** (optional)
3. Fill in **License Information**:
   - **License Number**
   - **License State**
   - **License Expiry Date** - Tap the calendar icon to select
   - **Status** - Active or Inactive
4. Click **"Add Driver"**

### Edit or Delete a Driver
- Click the **three-dot menu** (⋮) on any driver card/tile
- Select **Edit** to modify or **Delete** to remove

---

## Maintenance Tracking

### View Maintenance Records
Click **"Maintenance"** in the sidebar to see all records.

**Filters:**
- **All** - Shows all maintenance records
- **Scheduled** - Upcoming maintenance items
- **Completed** - Finished maintenance
- **Overdue** - Maintenance past its scheduled date (highlighted in red)

### Add a Maintenance Record
1. Click **"Add Record"**
2. Select the **Vehicle** from the dropdown
3. Choose the **Type**:
   - General, Oil Change, Tire Service, Brake Service, Inspection, or Repair
4. Enter **Title** (required) - e.g., "50,000 Mile Service"
5. Add **Description** (optional) - Details about the work performed
6. Enter **Cost** and **Odometer at Service**
7. Set the **Service Date**
8. Under **Schedule Next Service**:
   - Set status to "Scheduled" for future maintenance
   - Pick a **Next Service Date** if needed
   - Add any **Notes**
9. Click **"Add Record"**

### Edit or Delete a Record
- Click any record to open the edit form
- Use the **three-dot menu** (⋮) for delete option

### Overdue Maintenance
The Dashboard highlights overdue maintenance items in red. These are scheduled items whose `Next Service Date` has passed. Use this to proactively service your fleet.

---

## Service Centers

### View All Service Centers
Click **"Service Centers"** in the sidebar.

**Features:**
- **Search** - By name, city, or service type
- **Preferred Only** - Toggle to show only your preferred centers
- **Service Types** - Each center can list the types of services they offer

### Add a Service Center
1. Click **"Add Center"**
2. Fill in **Center Information**:
   - **Center Name** (required)
   - **Address** (required)
   - **City**, **State**, **Zip Code**
3. Fill in **Contact Information**:
   - **Phone**, **Email**, **Website**
4. Under **Services & Preferences**:
   - Toggle **"Preferred Service Center"** if this is a go-to location
   - Add **Service Types** (e.g., "Oil Change", "Tire Service", "Body Work") - type and press Enter or click the + button
5. Add **Notes** if needed
6. Click **"Add Center""

### Edit or Delete
- Click any center card to edit
- Use the **three-dot menu** (⋮) for delete

---

## Reports

Click **"Reports"** in the sidebar to view fleet analytics:

### Fleet Overview
- Total vehicle count with status breakdown
- Active driver count
- Assigned vs unassigned vehicles
- Vehicles in maintenance

### Maintenance Summary
- Total maintenance records
- Completed vs scheduled vs overdue counts
- Total maintenance cost across all records
- Average cost per service

### Vehicle Breakdown
- Vehicle count by make
- Total and average odometer across the fleet

---

## Settings

Click **"Settings"** in the sidebar to manage your account:

### Account
- View and edit your **First Name** and **Last Name**
- View your **email** (read-only)
- Click **"Send Password Reset Email"** to change your password

### Company Information
- View your company details (name, address, phone)

### Appearance
- **Dark Mode** toggle (follows system setting currently)

### About
- App version and platform information
- **Sign Out** button to log out of the application

---

## Accessibility Features

FleetControl is built with accessibility in mind, following WCAG guidelines:

### Screen Reader Support
- **Semantics labels** on all interactive elements (buttons, form fields, navigation)
- **Semantic headers** (header: true) on all section titles for easy navigation
- **Semantic roles** (button, checked, selected) on interactive elements
- **Meaningful alt text** on images and icons

### Keyboard Navigation
- All interactive elements are **focusable via Tab key**
- **Enter/Space** activates buttons
- **Escape** closes dialogs
- Form fields support **keyboard-only input**
- **Focus indicators** are visible with high-contrast outlines

### Visual Accessibility
- **Material Design 3** color system ensures **4.5:1 minimum contrast ratio**
- **Status indicators** use both **color and text** (not color alone)
- **Responsive layout** adapts from mobile (320px) to desktop (1920px+)
- **Minimum touch targets** of 48x48 pixels on all buttons and interactive elements

### Form Accessibility
- All form fields have **labels** associated with their inputs
- **Error messages** are displayed inline with clear text
- **Required fields** are marked with asterisks
- **Password visibility toggle** with semantic label

### Navigation
- **Skip to content** structure with semantic landmarks
- **Drawer navigation** on mobile, **sidebar** on desktop
- **Breadcrumbs** via route context
- **Consistent navigation** across all screens

---

## Troubleshooting

### App won't start / White screen
1. Ensure Firebase is properly configured
2. Run `flutter clean` then `flutter pub get`
3. Check that `google-services.json` is in `android/app/`
4. For web, ensure internet connection for Firebase SDK loading

### Authentication errors
- Verify Email/Password auth is enabled in Firebase Console
- Check that the Firebase project matches `fleetcontrol-ecdc1`
- Ensure Firestore is in test mode or has proper security rules

### Build fails
```bash
flutter clean
flutter pub get
flutter analyze
```

### Android build fails
- Ensure `android/app/google-services.json` is present
- Check that `compileSdk` and `minSdk` versions are compatible
- Run `cd android; ./gradlew clean; cd ..`

### Windows build fails
- Ensure Visual Studio 2022 with C++ Desktop Development workload is installed
- Windows SDK 10.0.17763.0 or higher required

### Web build issues
- Ensure Firebase project has Web app registered
- Check `web/index.html` has no syntax errors
- Firebase Hosting requires `flutter build web` output in `build/web/`

---

## Data Model Reference

The application stores data in Firestore with this hierarchy:

```
companies/
  {companyId}/
    name: string
    address1, address2, city, state, zipCode: string
    phone, email: string
    
users/
  {uid}/
    email: string
    firstName, lastName: string
    companyId: string (reference to companies/{companyId})
    role: string ("admin")

companies/{companyId}/vehicles/
  {vehicleId}/
    name, make, model: string
    year: number
    vin, licenseState, licenseNumber, color: string
    odometer: number
    keyIgnition, keyDoor: string
    purchaseDate: string (ISO date)
    purchasePrice: number
    notes: string
    status: string ("active" | "maintenance" | "retired")
    assignedDriverId: string | null

companies/{companyId}/drivers/
  {driverId}/
    firstName, lastName, email: string
    phone, licenseNumber, licenseState: string
    licenseExpiry: string (ISO date)
    status: string ("active" | "inactive")
    assignedVehicleId: string | null

companies/{companyId}/maintenance/
  {recordId}/
    vehicleId: string (reference)
    type: string ("general" | "oil_change" | "tire" | "brake" | "inspection" | "repair")
    title, description: string
    cost, odometerAtService: number
    serviceDate, nextServiceDate: string (ISO date)
    nextServiceOdometer: number
    status: string ("completed" | "scheduled")
    notes: string

companies/{companyId}/serviceCenters/
  {centerId}/
    name, address, city, state, zipCode: string
    phone, email, website: string
    serviceTypes: array of strings
    rating: number
    isPreferred: boolean
    notes: string
```

---

## Firestore Security Rules

For production, configure these Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Company members can access their company data
    match /companies/{companyId} {
      allow read, write: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.companyId == companyId;
      
      match /{document=**} {
        allow read, write: if request.auth != null 
          && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.companyId == companyId;
      }
    }
  }
}
```
