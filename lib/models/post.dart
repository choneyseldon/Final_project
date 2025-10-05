class Post {
  final String id;
  final String title;
  final String caption;
  final String imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String userId;
  final String userEmail;
  final String userName;
  int likes;
  List<String> likedBy;
  
  Post({
    required this.id,
    required this.title,
    required this.caption,
    required this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.likes = 0,
    List<String>? likedBy,
  }) : likedBy = likedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // Handle different timestamp formats (Firestore Timestamp vs DateTime string)
    DateTime parsedCreatedAt;
    final createdAtValue = json['createdAt'];
    
    if (createdAtValue == null) {
      parsedCreatedAt = DateTime.now();
    } else if (createdAtValue is String) {
      parsedCreatedAt = DateTime.parse(createdAtValue);
    } else {
      // Handle Firestore Timestamp
      try {
        parsedCreatedAt = (createdAtValue as dynamic).toDate();
      } catch (e) {
        parsedCreatedAt = DateTime.now();
      }
    }

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: parsedCreatedAt,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  Post copyWith({
    String? id,
    String? title,
    String? caption,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    String? userId,
    String? userEmail,
    String? userName,
    int? likes,
    List<String>? likedBy,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}