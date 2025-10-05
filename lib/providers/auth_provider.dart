import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithEmail(email, password);
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signUpWithEmail(email, password, fullName);
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithGoogle();
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signInWithFacebook() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithFacebook();
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Bio-related methods
  Future<String> getUserBio() async {
    if (_user == null) return '';
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['bio'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting user bio: $e');
      return '';
    }
  }

  Future<void> updateUserBio(String bio) async {
    if (_user == null) return;
    
    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        'bio': bio,
        'email': _user!.email,
        'displayName': _user!.displayName,
        'photoURL': _user!.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      notifyListeners();
    } catch (e) {
      print('Error updating user bio: $e');
      throw Exception('Failed to update bio');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    if (_user == null) return {};
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
      return {};
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  // Profile picture methods
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    if (_user == null) {
      print('Error: User is null when trying to upload profile picture');
      return null;
    }
    
    try {
      _setLoading(true);
      print('Starting profile picture upload for user: ${_user!.uid}');
      
      if (kIsWeb) {
        print('Web platform detected, using base64 encoding');
        // Handle web file upload using bytes
        final bytes = await imageFile.readAsBytes();
        print('Image bytes loaded: ${bytes.length} bytes');
        
        // For web, store base64 in Firestore and use a reference URL pattern
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64String';
        print('Base64 data URL created');
        
        // Store the actual image data in Firestore
        await _updateUserProfile({
          'photoURL': 'firestore:profile_image', // Reference marker
          'profileImageData': dataUrl, // Actual base64 data
        });
        print('Firestore user profile updated with base64 data');
        
        // Set a simple reference URL in Firebase Auth (within length limits)
        await _user!.updatePhotoURL('firestore:profile_image');
        print('Firebase Auth profile photo reference updated');
        
        // Refresh user to get updated photo URL
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        print('User profile reloaded');
        
        _setLoading(false);
        notifyListeners(); // Notify listeners to refresh UI
        return 'firestore:profile_image'; // Return reference URL
      } else {
        print('Mobile platform detected, using Firebase Storage');
        // Handle mobile file upload to Firebase Storage
        final file = File(imageFile.path);
        final storageRef = _storage.ref().child('profile_pictures/${_user!.uid}');
        print('Uploading to Firebase Storage...');
        
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('Firebase Storage upload complete: $downloadUrl');
        
        // Update both Firebase Auth profile and Firestore
        await _user!.updatePhotoURL(downloadUrl);
        print('Firebase Auth profile photo updated');
        
        await _updateUserProfile({'photoURL': downloadUrl});
        print('Firestore user profile updated');
        
        // Refresh user to get updated photo URL
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        print('User profile reloaded');
        
        _setLoading(false);
        notifyListeners(); // Notify listeners to refresh UI
        return downloadUrl;
      }
    } catch (e) {
      _setLoading(false);
      print('Error uploading profile picture: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  // Display name update method
  Future<void> updateDisplayName(String displayName) async {
    if (_user == null) return;
    
    try {
      _setLoading(true);
      
      // Update Firebase Auth profile
      await _user!.updateDisplayName(displayName);
      
      // Update Firestore user document
      await _updateUserProfile({'displayName': displayName});
      
      // Refresh user to get updated display name
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print('Error updating display name: $e');
      throw Exception('Failed to update display name');
    }
  }

  // Helper method to update user profile in Firestore
  Future<void> _updateUserProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    
    final updateData = {
      ...data,
      'email': _user!.email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    await _firestore.collection('users').doc(_user!.uid).set(
      updateData,
      SetOptions(merge: true),
    );
  }

  // Get profile picture URL
  String? get profilePictureUrl {
    // First try to get from Firebase Auth
    if (_user?.photoURL != null && _user!.photoURL!.isNotEmpty) {
      return _user!.photoURL;
    }
    return null;
  }

  // Get actual profile picture data from Firestore (for base64 images)
  Future<String?> getProfileImageData() async {
    if (_user == null) return null;
    
    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['profileImageData'] as String?;
      }
    } catch (e) {
      print('Error getting profile image data: $e');
    }
    return null;
  }
}