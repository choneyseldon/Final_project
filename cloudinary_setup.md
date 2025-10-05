# Cloudinary Setup for Looma App

## 1. Sign up for free at [cloudinary.com](https://cloudinary.com)

## 2. Get your credentials:
```
Cloud Name: your-cloud-name
API Key: your-api-key  
API Secret: your-api-secret
```

## 3. Add to pubspec.yaml:
```yaml
dependencies:
  cloudinary_public: ^0.21.0
  http: ^1.1.0
```

## 4. Usage in Flutter:
```dart
import 'package:cloudinary_public/cloudinary_public.dart';

final cloudinary = CloudinaryPublic('your-cloud-name', 'your-upload-preset');

// Upload image
CloudinaryResponse result = await cloudinary.uploadFile(
  CloudinaryFile.fromFile(imageFile.path, folder: 'looma-photos')
);

String imageUrl = result.secureUrl;
```

## 5. Features:
- ✅ 25GB free storage
- ✅ Auto image optimization  
- ✅ Resizing on-the-fly
- ✅ CDN delivery
- ✅ Perfect for photo apps