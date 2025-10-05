# Supabase Setup for Looma App

## 1. Sign up for free at [supabase.com](https://supabase.com)

## 2. Create new project and get:
```
Project URL: https://your-project.supabase.co
API Key: your-anon-key
```

## 3. Add to pubspec.yaml:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

## 4. Usage in Flutter:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Upload image
final file = File(imagePath);
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
  .from('photos')
  .upload('public/$fileName', file);

String imageUrl = supabase.storage
  .from('photos')
  .getPublicUrl('public/$fileName');
```

## 5. Features:
- ✅ 1GB free storage
- ✅ Real-time database
- ✅ Built-in authentication
- ✅ PostgreSQL backend
- ✅ Great for social features