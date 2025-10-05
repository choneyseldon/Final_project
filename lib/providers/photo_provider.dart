import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Photo {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class PhotoProvider with ChangeNotifier {
  List<Photo> _photos = [];
  final List<Photo> _favoritePhotos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Photo> get photos => _photos;
  List<Photo> get favoritePhotos => _favoritePhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/photos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _photos = jsonData.take(50).map((json) => Photo.fromJson(json)).toList(); // Limit to 50 photos
      } else {
        _errorMessage = 'Failed to load photos';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleFavorite(Photo photo) {
    if (_favoritePhotos.any((p) => p.id == photo.id)) {
      _favoritePhotos.removeWhere((p) => p.id == photo.id);
    } else {
      _favoritePhotos.add(photo);
    }
    notifyListeners();
  }

  bool isFavorite(Photo photo) {
    return _favoritePhotos.any((p) => p.id == photo.id);
  }

  List<Photo> searchPhotos(String query) {
    if (query.isEmpty) return _photos;
    return _photos.where((photo) => 
      photo.title.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}