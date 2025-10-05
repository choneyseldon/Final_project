import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isOnboardingCompleted = false;
  List<String> _selectedCategories = [];
  bool _isFirstTimeUser = true;

  int get currentIndex => _currentIndex;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  List<String> get selectedCategories => _selectedCategories;
  bool get isFirstTimeUser => _isFirstTimeUser;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    _isFirstTimeUser = false;
    notifyListeners();
  }

  void setFirstTimeUser(bool isFirstTime) {
    _isFirstTimeUser = isFirstTime;
    notifyListeners();
  }
}