import 'package:flutter/foundation.dart';

class MockUser {
  final String uid;
  final String email;
  final String? displayName;

  MockUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  static List<MockUser> get testUsers => [
    MockUser(uid: 'user1', email: 'alice@example.com', displayName: 'Alice Johnson'),
    MockUser(uid: 'user2', email: 'bob@example.com', displayName: 'Bob Smith'),
    MockUser(uid: 'user3', email: 'charlie@example.com', displayName: 'Charlie Brown'),
    MockUser(uid: 'user4', email: 'diana@example.com', displayName: 'Diana Prince'),
    MockUser(uid: 'user5', email: 'eve@example.com', displayName: 'Eve Wilson'),
  ];
}

class MockAuthService {
  static MockUser? _currentUser;
  static int _currentUserIndex = 0;

  static MockUser? get currentUser => _currentUser;

  static void switchToNextTestUser() {
    final users = MockUser.testUsers;
    _currentUserIndex = (_currentUserIndex + 1) % users.length;
    _currentUser = users[_currentUserIndex];
    if (kDebugMode) {
      print('Switched to user: ${_currentUser?.displayName} (${_currentUser?.email})');
    }
  }

  static void switchToUser(int index) {
    final users = MockUser.testUsers;
    if (index >= 0 && index < users.length) {
      _currentUserIndex = index;
      _currentUser = users[index];
      if (kDebugMode) {
        print('Switched to user: ${_currentUser?.displayName} (${_currentUser?.email})');
      }
    }
  }

  static void initializeWithFirstUser() {
    if (_currentUser == null) {
      _currentUser = MockUser.testUsers.first;
    }
  }
}