# Firebase Setup and Testing Guide

## Firebase Configuration Required

### 1. Firestore Security Rules
Add these rules to your Firestore database in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write posts
    match /posts/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Allow users to manage their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Authentication Setup
Make sure Firebase Authentication is enabled with:
- Email/Password provider enabled
- Google Sign-In provider enabled (optional)

## Testing Multi-User Functionality

### Real Firebase Testing (Recommended)
1. **Create Test Accounts**: Create 2-3 test accounts using the app's registration
2. **Multi-Browser Testing**: 
   - Open Chrome: Login as User A
   - Open Edge/Firefox: Login as User B
   - Create posts from User A - they should appear instantly for User B
   - Like posts from User B - likes should sync in real-time for User A

### What's Fixed Now
✅ **Real Firebase Authentication**: Uses actual Firebase Auth instead of mock system
✅ **Firestore Database**: Posts stored in cloud database, shared across all users
✅ **Real-time Updates**: Changes sync instantly across all browser instances
✅ **User Attribution**: Posts show actual user names from Firebase Auth
✅ **Cross-Browser Sharing**: Posts visible across different browsers/devices

### Key Changes Made
1. **PostService**: Completely rewritten to use Firestore instead of localStorage
2. **PostProvider**: Updated to use Firebase Auth and real-time Firestore streams
3. **Authentication**: Integrated with existing Firebase Auth system
4. **Real-time Sync**: Firestore streams provide instant updates across all clients

### Testing Instructions
1. Register/login with your Firebase account (choney account)
2. Create a post with an image
3. Open a new browser tab/window, login with admin account
4. The choney user's post should appear automatically
5. Like/interact with posts - changes sync in real-time

### Database Structure
Posts are stored in Firestore with this structure:
```
posts/
  - id (auto-generated)
  - title: string
  - caption: string
  - imageUrl: string
  - tags: array of strings
  - likes: array of user IDs
  - userId: string (creator's Firebase UID)
  - userName: string (creator's display name)
  - userEmail: string (creator's email)
  - createdAt: timestamp
  - updatedAt: timestamp
```

This structure ensures proper user attribution and real-time synchronization across all connected clients.