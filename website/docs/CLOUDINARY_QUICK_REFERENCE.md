# 🌤️ Cloudinary Quick Reference

Quick commands and configuration for Zarya + Cloudinary setup.

## 🔧 Essential Configuration

### 1. Update Cloudinary Config
Edit `customer_web/lib/config/cloudinary_config.dart`:

```dart
class CloudinaryConfig {
  static const String cloudName = 'YOUR_CLOUD_NAME_HERE';
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String uploadPreset = 'zarya_uploads';
  
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName';
}
```

### 2. Create Upload Preset in Cloudinary Console (Updated Aug 2025)
- **Name**: `zarya_uploads`
- **Mode**: Unsigned
- **Folder**: `zarya/`
- **Transformations**: `w_2048,h_2048,c_limit,q_auto:good,f_auto`
- **Note**: File restrictions are now client-side only (see upload code below)

## 📷 Image URL Generation

### Basic Usage
```dart
// Get optimized image
String imageUrl = ApiService.getOptimizedImageUrl(
  'zarya/sample/salon1',
  width: 400,
  height: 300,
  quality: 'auto',
  format: 'webp',
);

// Pre-defined sizes
String thumbnail = ApiService.getThumbnailUrl('zarya/sample/salon1');
String hero = ApiService.getHeroImageUrl('zarya/sample/salon1');
```

### In Widgets
```dart
CachedNetworkImage(
  imageUrl: ApiService.getThumbnailUrl(merchant.images.first),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

## 📤 Image Upload (Client-side - Updated Aug 2025)

### Create Upload Service with Validation
Create `customer_web/lib/services/upload_service.dart`:

```dart
import 'dart:html' as html;
import 'dart:convert';
import '../config/cloudinary_config.dart';

class UploadService {
  // Client-side restrictions (new approach as of Aug 2025)
  static const List<String> allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  static Future<String?> uploadImage(html.File file) async {
    // Client-side validation (required as of Aug 2025)
    if (!_validateFile(file)) return null;
    
    try {
      final formData = html.FormData();
      formData.append('file', file);
      formData.append('upload_preset', CloudinaryConfig.uploadPreset);
      formData.append('folder', 'zarya/user-uploads');

      final request = html.HttpRequest();
      request.open('POST', '${CloudinaryConfig.uploadUrl}/image/upload');
      
      await request.onLoad.first;
      
      if (request.status == 200) {
        final response = jsonDecode(request.responseText!);
        return response['public_id'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
  
  static bool _validateFile(html.File file) {
    if (!allowedTypes.contains(file.type)) {
      print('Error: File type ${file.type} not allowed');
      return false;
    }
    if (file.size > maxFileSize) {
      print('Error: File too large (${file.size} > $maxFileSize bytes)');
      return false;
    }
    return true;
  }
}
```

### Usage in Widget
```dart
Future<void> _pickAndUploadImage() async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  
  input.onChange.listen((e) async {
    final files = input.files;
    if (files!.isEmpty) return;
    
    final file = files[0];
    final publicId = await UploadService.uploadImage(file);
    
    if (publicId != null) {
      setState(() {
        imageUrl = ApiService.getThumbnailUrl(publicId);
      });
    }
  });
}
```

## 🔗 Common Transformations

| Transformation | Code | Result |
|---------------|------|---------|
| Thumbnail | `w_300,h_200,c_fill,q_auto,f_auto` | 300x200 optimized |
| Card Image | `w_400,h_250,c_fill,q_auto,f_auto` | 400x250 optimized |
| Hero Image | `w_800,h_400,c_fill,q_auto,f_auto` | 800x400 optimized |
| Profile Pic | `w_150,h_150,c_fill,r_max,q_auto,f_auto` | 150x150 circle |
| Blur Effect | `e_blur:300` | Blurred image |
| Grayscale | `e_grayscale` | Black & white |

## ⚡ Build Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web

# Run locally
flutter run -d chrome

# Check for issues
flutter analyze
flutter test
```

## 🔍 Troubleshooting

### "Cloud name not found"
- Verify `CloudinaryConfig.cloudName` matches your Cloudinary dashboard
- Check for typos or case sensitivity

### "Upload preset not found"
- Ensure preset is created in Cloudinary console
- Verify preset name matches `CloudinaryConfig.uploadPreset`
- Check that preset is set to "Unsigned"

### "File upload rejected" (New as of Aug 2025)
- Verify client-side validation is implemented in your upload service
- Check file type is in the allowedTypes array
- Ensure file size doesn't exceed maxFileSize limit
- Server-side restrictions are now in transformation field, not preset UI

### Images not loading
- Verify public_id exists in Cloudinary Media Library
- Check network connectivity
- Inspect console for CORS errors

### Build failures
- Run `flutter clean` before building
- Check for missing dependencies in `pubspec.yaml`
- Verify all imports are correct

## 📱 Next Steps

1. **Upload test images** to Cloudinary
2. **Update sample data** with real public IDs
3. **Test image loading** in your app
4. **Implement upload feature** if needed
5. **Configure production settings** for security

## 🔗 Useful Links

- [Cloudinary Console](https://console.cloudinary.com/)
- [Transformation Reference](https://cloudinary.com/documentation/image_transformation_reference)
- [Upload API](https://cloudinary.com/documentation/image_upload_api_reference)
- [Flutter Integration](https://cloudinary.com/documentation/flutter_integration)
