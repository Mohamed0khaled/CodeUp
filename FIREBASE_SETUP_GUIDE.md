# Firebase Integration Setup Guide

This guide will help you set up Firebase Firestore for the tournament system integration between the Flutter app and admin panel.

## Prerequisites

1. Google account
2. Firebase project
3. Flutter project with Firebase configuration

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "codeup-tournaments")
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Set up Firestore Database

1. In your Firebase project, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 3: Get Firebase Configuration

### For Flutter App (Already configured)
The Flutter app should already have Firebase configured. If not:

1. In Firebase Console, click the Android/iOS icon to add an app
2. Follow the setup instructions
3. Download the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories

### For Admin Panel (Web)
1. In Firebase Console, click the Web icon (</>) to add a web app
2. Register your app with a nickname (e.g., "Admin Panel")
3. Copy the Firebase configuration object
4. Update the configuration in `/admin_panel/firebase-index.html`:

```javascript
const firebaseConfig = {
    apiKey: "your-actual-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-actual-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id"
};
```

## Step 4: Set up Firestore Security Rules

In Firestore Database > Rules, update the rules for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to tournaments collection
    match /tournaments/{tournamentId} {
      allow read, write: if true; // For development only
    }
    
    // Allow read/write access to users collection
    match /users/{userId} {
      allow read, write: if true; // For development only
    }
    
    // Allow read/write access to user's joined tournaments
    match /users/{userId}/joinedTournaments/{tournamentId} {
      allow read, write: if true; // For development only
    }
  }
}
```

**Note:** These rules are for development only. In production, implement proper authentication and authorization.

## Step 5: Initialize Firestore Collections

### Using the Admin Panel
1. Open `admin_panel/firebase-index.html` in a web browser
2. Create your first tournament using the "Add Tournament" button
3. This will automatically create the `tournaments` collection

### Manual Setup (Optional)
You can also create the collections manually in the Firestore console:

1. Go to Firestore Database
2. Click "Start collection"
3. Collection ID: `tournaments`
4. Add a document with these fields:

```json
{
  "title": "Sample Tournament",
  "subtitle": "Test tournament",
  "startDate": "2024-12-01T10:00:00",
  "duration": 3,
  "prizePool": 5000,
  "maxParticipants": 100,
  "participants": 0,
  "difficulty": "Medium",
  "language": "Any",
  "description": "Sample tournament for testing",
  "rules": ["Duration: 3 hours", "Language: Any"],
  "prizes": {
    "first": 50,
    "second": 30,
    "third": 20
  },
  "status": "open",
  "subscribers": [],
  "createdAt": "2024-11-01T00:00:00Z"
}
```

## Step 6: Test the Integration

### Admin Panel Testing
1. Open `admin_panel/firebase-index.html` in a web browser
2. Create, edit, and delete tournaments
3. Check that data appears in Firestore console

### Flutter App Testing
1. Run the Flutter app: `flutter run`
2. Navigate to the Leagues screen
3. Verify tournaments from Firestore are displayed
4. Test joining tournaments

## Step 7: Update Firebase Configuration

Replace the placeholder configuration in `admin_panel/firebase-index.html` with your actual Firebase project configuration:

```html
<!-- Update this section in firebase-index.html -->
<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
    import { getFirestore } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';
    
    // Replace with your actual Firebase configuration
    const firebaseConfig = {
        apiKey: "your-actual-api-key",
        authDomain: "your-project.firebaseapp.com",
        projectId: "your-actual-project-id",
        storageBucket: "your-project.appspot.com",
        messagingSenderId: "your-sender-id",
        appId: "your-app-id"
    };
    
    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    window.db = db;
</script>
```

## Data Structure

### Tournament Document Structure
```json
{
  "id": "auto-generated-id",
  "title": "Tournament Name",
  "subtitle": "Tournament Description",
  "startDate": "ISO-8601-datetime",
  "duration": 3,
  "prizePool": 5000,
  "maxParticipants": 100,
  "participants": 0,
  "difficulty": "Easy|Medium|Hard|Expert",
  "language": "Programming language",
  "description": "Detailed description",
  "rules": ["Rule 1", "Rule 2"],
  "prizes": {
    "first": 50,    // percentage
    "second": 30,   // percentage
    "third": 20     // percentage
  },
  "status": "open|closed|completed",
  "subscribers": ["userId1", "userId2"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### User Joined Tournaments Structure
```
users/{userId}/joinedTournaments/{tournamentId}
{
  "tournamentId": "tournament-id",
  "joinedAt": "timestamp"
}
```

## Security Considerations

For production deployment:

1. **Authentication**: Implement Firebase Auth for admin access
2. **Security Rules**: Restrict write access to authenticated admins only
3. **Data Validation**: Add server-side validation using Cloud Functions
4. **API Keys**: Secure your Firebase API keys appropriately

## Troubleshooting

### Common Issues:

1. **CORS Error**: Use a local server to serve the admin panel HTML file
2. **Permission Denied**: Check Firestore security rules
3. **Configuration Error**: Verify Firebase config is correct
4. **Import Errors**: Ensure Firebase SDK URLs are accessible

### Testing Locally:

```bash
# Serve admin panel locally
cd admin_panel
python -m http.server 8000
# Then open http://localhost:8000/firebase-index.html
```

## Next Steps

1. Set up Firebase Authentication for admin panel security
2. Implement Cloud Functions for server-side logic
3. Add real-time updates using Firestore listeners
4. Deploy admin panel to Firebase Hosting

---

**Note**: Remember to replace all placeholder values with your actual Firebase project configuration before testing.
