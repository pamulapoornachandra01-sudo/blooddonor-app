# Firebase Data Connect Setup Guide

## Overview

This document describes the setup required to complete the Firebase Data Connect (PostgreSQL) integration for the BloodDonate app.

---

## Current Status

| Component | Status |
|-----------|--------|
| Firebase Auth (Phone OTP) | ✅ Configured |
| Firestore Service | ✅ Created |
| Data Connect Schema | ✅ Created |
| Android Build | ✅ Success |
| Cloud SQL Instance | ❌ Not created |
| Data Connect Deployment | ❌ Not deployed |
| Generated SDK | ❌ Not generated |

---

## Prerequisites

1. **Firebase Project**: `blood-bank-8cc48` (already exists - cloud-based, no laptop required)
2. **Google Cloud Account**: Required for Cloud SQL
3. **Firebase CLI**: Must be installed
4. **gcloud CLI**: Required for Cloud SQL management

---

## Setting Up on Another Laptop

The Firebase project and Cloud SQL database are **cloud-based** - they don't live on any specific laptop. Simply clone the project and connect to the existing cloud resources.

### On a New Laptop:

```bash
# 1. Clone the project
git clone <your-repo>
cd blood_donate

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Firebase CLI (if not installed)
npm install -g firebase-tools

# 4. Login to Firebase (use the same Google account)
firebase login

# 5. Project is already linked to blood-bank-8cc48
# Just initialize Data Connect:
firebase init dataconnect

# Select "Use existing Cloud SQL instance" when prompted
# Choose "blooddonate-db" (already exists!)

# 6. Generate SDK and deploy
firebase deploy
```

### What to Do If Cloud SQL Instance Doesn't Exist Yet:

If `blooddonate-db` doesn't exist yet (first-time setup):

```bash
# Run on the original laptop or any laptop with proper permissions:
firebase init dataconnect
# Select "Create a new instance" when prompted

# After creation, all other laptops can connect to it
```

### Key Points:
- The database (`blooddonate-db`) is created once and lives in Google Cloud
- All laptops connect to the same cloud database
- No database setup needed on individual laptops
- Just need Firebase CLI + Google login

---

## Step-by-Step Instructions

### Step 1: Install Required CLI Tools

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Install gcloud CLI
# Download from: https://cloud.google.com/sdk/docs/install

# Verify installations
firebase --version
gcloud --version
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Initialize Data Connect

```bash
cd C:\Users\nandu\Desktop\yv project\blood_donate
firebase init dataconnect
```

**Follow the prompts:**
```
? What ID would you like to use for this service? 
→ blooddonate

? In which region would you like to deploy?
→ us-central1

? Connect to an existing Cloud SQL instance or create a new one?
→ Create a new instance

? What would you like to name your Cloud SQL instance?
→ blooddonate-db

? Which PostgreSQL version would you like to use?
→ POSTGRES_15
```

### Step 4: Update Data Connect Config

After initialization, update `firebase/dataconnect.yaml` with:

```yaml
specVersion: "v1"
serviceId: "blooddonate"
location: "us-central1"

schema:
  source: "./schema.gql"
  
connectors:
  source: "./connectors"
```

### Step 5: Deploy Schema to Cloud SQL

```bash
firebase deploy
```

This will:
1. Create Cloud SQL instance (if not exists)
2. Create PostgreSQL database
3. Deploy schema to database
4. Deploy GraphQL connectors

### Step 6: Generate Flutter SDK

**Option A: Using Firebase VSCode Extension**
1. Install Firebase VSCode extension
2. Open the Data Connect panel
3. Click "Add SDK to app"
4. Select Flutter and output directory

**Option B: Using CLI**
```bash
firebase dataconnect:sdk:install --flutter-output-dir=./lib/generated
```

### Step 7: Update Data Connect Service

Once SDK is generated, update `lib/shared/services/data_connect_service.dart`:

```dart
// Replace the placeholder imports with:
import 'package:blooddonate/generated/cloud_sql.dart';
import 'package:blooddonate/generated/data_connect.dart';

// Replace each TODO section with actual SDK calls
// Example:
// final result = await UsersConnector.instance.createUser(
//   firebaseUid: firebaseUid,
//   phone: phone,
//   role: role.name,
// );
```

---

## Database Schema (PostgreSQL)

The schema will be deployed as:

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  role VARCHAR(20) DEFAULT 'donor',
  name VARCHAR(100),
  blood_type VARCHAR(5),
  verification_status VARCHAR(20) DEFAULT 'pending',
  is_available BOOLEAN DEFAULT false,
  is_banned BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Blood Requests Table
```sql
CREATE TABLE blood_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  receiver_id UUID REFERENCES users(id),
  receiver_name VARCHAR(100),
  blood_type VARCHAR(5) NOT NULL,
  units_needed INTEGER NOT NULL,
  location VARCHAR(255) NOT NULL,
  location_details TEXT,
  urgency VARCHAR(20) DEFAULT 'normal',
  medical_proof_url TEXT,
  status VARCHAR(20) DEFAULT 'posted',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  fulfilled_at TIMESTAMP WITH TIME ZONE,
  pledged_donors TEXT[],
  hospital_name VARCHAR(255),
  contact_phone VARCHAR(20)
);
```

### Verifications Table
```sql
CREATE TABLE verifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id),
  id_front_url TEXT,
  id_back_url TEXT,
  selfie_url TEXT,
  medical_doc_url TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  rejection_reason TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewer_id UUID REFERENCES users(id)
);
```

### Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  body TEXT,
  type VARCHAR(50),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

## GraphQL Operations

### Queries Available
- `getUser(id)` - Get user by ID
- `getUserByFirebaseUid(firebaseUid)` - Get user by Firebase UID
- `listUsers` - List all users
- `listUsersByRole(role)` - Filter users by role
- `getBloodRequest(id)` - Get blood request by ID
- `listBloodRequests` - List all blood requests
- `listBloodRequestsByReceiver(receiverId)` - Get requests for a receiver
- `listBloodRequestsByBloodType(bloodType)` - Filter by blood type
- `getVerification(userId)` - Get verification status
- `listPendingVerifications` - Get pending verifications

### Mutations Available
- `createUser(firebaseUid, phone, role)` - Create new user
- `updateUser(id, ...)` - Update user profile
- `createBloodRequest(...)` - Create blood request
- `updateBloodRequest(id, ...)` - Update blood request status
- `createVerification(...)` - Submit verification documents
- `updateVerification(...)` - Approve/reject verification
- `createNotification(...)` - Create notification

---

## Switching from Firestore to Data Connect

Once Data Connect is deployed:

1. Update imports in your services:
   ```dart
   // From:
   import 'firestore_service.dart';
   
   // To:
   import 'data_connect_service.dart';
   ```

2. Update providers to use `dataConnectServiceProvider` instead of `firestoreServiceProvider`

3. Test all database operations

---

## Troubleshooting

### Cloud SQL Connection Issues
```bash
# Check instance status
gcloud sql instances describe blooddonate-db

# Get connection name
gcloud sql instances describe blooddonate-db --format="value(connectionName)"
```

### Authentication Issues
```bash
# Re-authenticate
firebase logout
firebase login
```

### Schema Deployment Issues
```bash
# Check schema differences
firebase dataconnect:sql:diff

# Apply migrations
firebase dataconnect:sql:migrate
```

---

## Cost Estimation

| Resource | Free Tier | Paid |
|----------|-----------|------|
| Cloud SQL (PostgreSQL) | 90 days | ~$7/month |
| Data Connect | Included | Included |
| Firebase Auth | 10K/month | Free |
| Firebase Storage | 5GB | ~$0.026/GB |

---

## File Locations

| File | Path |
|------|------|
| Data Connect Config | `firebase/dataconnect.yaml` |
| Database Schema | `firebase/schema.gql` |
| User Operations | `firebase/connectors/users.gql` |
| Blood Request Operations | `firebase/connectors/blood_requests.gql` |
| Verification Operations | `firebase/connectors/verifications.gql` |
| Notification Operations | `firebase/connectors/notifications.gql` |
| Service Wrapper | `lib/shared/services/data_connect_service.dart` |

---

## Next Steps After Setup

1. ✅ Deploy schema
2. ⬜ Generate Flutter SDK
3. ⬜ Update data_connect_service.dart with generated code
4. ⬜ Update providers to use Data Connect
5. ⬜ Test all features
6. ⬜ Build release APK

---

*Generated on: March 17, 2026*
*Project: BloodDonate*
*Firebase Project: blood-bank-8cc48*
