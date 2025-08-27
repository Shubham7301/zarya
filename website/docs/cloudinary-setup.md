# 🌤️ Cloudinary Setup Guide for Zarya Platform

## Overview

Cloudinary is a comprehensive cloud-based media management platform that provides:
- **Image and Video Storage** - Secure cloud storage
- **Real-time Image Optimization** - Automatic format conversion and compression  
- **CDN Delivery** - Fast global content delivery
- **Image Transformations** - Resize, crop, filters on-the-fly
- **Web Hosting** - Static website hosting capabilities

## 🚀 Step 1: Create Cloudinary Account

### 1.1 Sign Up for Free Account
1. Go to [https://cloudinary.com/](https://cloudinary.com/)
2. Click **"Sign Up for Free"**
3. Choose signup method:
   - Email and password
   - GitHub account
   - Google account
4. Verify your email address

### 1.2 Complete Account Setup
1. Choose your **Cloud Name** (this will be part of your URLs)
   - Example: `zarya-booking`
   - Must be unique across all Cloudinary users
   - Can only contain letters, numbers, and hyphens
2. Select your **primary use case**: "Web and mobile development"
3. Complete the onboarding survey

## 🔧 Step 2: Get Your Credentials

### 2.1 Access Dashboard
1. Login to [Cloudinary Console](https://console.cloudinary.com/)
2. Go to **Dashboard** (home page)

### 2.2 Copy Your Credentials
You'll see your account details:
```
Cloud name: your-cloud-name
API Key: 123456789012345
API Secret: abcdefghijklmnopqrstuvwxyz123456
```

**⚠️ Important**: Keep your API Secret secure - never expose it in client-side code!

## 📱 Step 3: Configure Flutter Web App

### 3.1 Update API Service
Edit `customer_web/lib/services/api_service.dart`:

```dart
class ApiService {
  // Replace with your actual Cloudinary cloud name
  static const String cloudinaryBaseUrl = 'https://res.cloudinary.com/your-cloud-name';
  static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/your-cloud-name';
  
  // Add your upload preset (created in step 4)
  static const String uploadPreset = 'zarya_uploads';
}
```

### 3.2 Update Environment Configuration
Create `customer_web/lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String cloudinaryCloudName = 'your-cloud-name';
  static const String cloudinaryApiKey = '123456789012345';
  static const String cloudinaryUploadPreset = 'zarya_uploads';
  
  // Base URLs
  static const String cloudinaryBaseUrl = 'https://res.cloudinary.com/$cloudinaryCloudName';
  static const String backendApiUrl = 'https://your-backend-api.com/api';
}
```

## ⚙️ Step 4: Configure Upload Settings

### 4.1 Create Upload Preset
1. In Cloudinary Console, go to **Settings** → **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Configure preset:
   - **Preset name**: `zarya_uploads`
   - **Signing Mode**: `Unsigned` (for client uploads)
   - **Folder**: `zarya/` (organizes uploads)
   - **Allowed formats**: `jpg,png,webp,gif`
   - **Max file size**: `10MB`
   - **Max image dimensions**: `2048x2048`

### 4.2 Configure Transformations (Optional)
Add default transformations:
- **Quality**: `auto:good`
- **Format**: `auto`
- **Fetch format**: `auto`

## 🖼️ Step 5: Image Optimization Setup

### 5.1 Create Image Helper Service
Create `customer_web/lib/services/image_service.dart`:

```dart
import '../config/app_config.dart';

class ImageService {
  // Generate optimized image URLs
  static String getOptimizedUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('c_$crop');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    final transformation = transformations.join(',');
    return '${AppConfig.cloudinaryBaseUrl}/image/upload/$transformation/$publicId';
  }

  // Predefined image sizes
  static String getThumbnail(String publicId) => getOptimizedUrl(
    publicId,
    width: 300,
    height: 200,
    quality: 'auto',
  );

  static String getCardImage(String publicId) => getOptimizedUrl(
    publicId,
    width: 400,
    height: 250,
    quality: 'auto',
  );

  static String getHeroImage(String publicId) => getOptimizedUrl(
    publicId,
    width: 800,
    height: 400,
    quality: 'auto',
  );

  static String getFullImage(String publicId) => getOptimizedUrl(
    publicId,
    width: 1200,
    height: 800,
    quality: 'auto',
  );
}
```

## 📤 Step 6: File Upload Implementation

### 6.1 Create Upload Service
Create `customer_web/lib/services/upload_service.dart`:

```dart
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UploadService {
  static Future<String?> uploadImage(html.File file) async {
    try {
      final formData = html.FormData();
      formData.append('file', file);
      formData.append('upload_preset', AppConfig.cloudinaryUploadPreset);
      formData.append('folder', 'zarya');

      final request = html.HttpRequest();
      request.open('POST', '${AppConfig.cloudinaryUploadUrl}/image/upload');
      
      final completer = Completer<String?>();
      
      request.onLoad.listen((event) {
        if (request.status == 200) {
          final response = jsonDecode(request.responseText!);
          completer.complete(response['public_id']);
        } else {
          completer.complete(null);
        }
      });
      
      request.onError.listen((event) {
        completer.complete(null);
      });
      
      request.send(formData);
      return await completer.future;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
```

## 🌐 Step 7: Web Hosting Setup (Optional)

### 7.1 Enable Web Hosting
1. In Cloudinary Console, go to **Add-ons**
2. Find **"Website Speed & SEO"** or **"Static Website Hosting"**
3. Enable the add-on (may require plan upgrade)

### 7.2 Configure Hosting
1. Go to **Settings** → **Website**
2. Configure:
   - **Domain**: `your-site.cloudinary.app` or custom domain
   - **Index document**: `index.html`
   - **Error document**: `index.html` (for SPA routing)

### 7.3 Deploy Flutter Web
```bash
# Build the Flutter web app
cd customer_web
flutter build web

# Upload build files to Cloudinary
# You can use their CLI or web interface
cloudinary upload_dir build/web --resource_type raw
```

## 🔒 Step 8: Security Configuration

### 8.1 Set Up Signed URLs (Production)
For production, use signed uploads:

```dart
// In your backend API
import 'package:cloudinary/cloudinary.dart';

class CloudinaryService {
  static final cloudinary = Cloudinary.signedConfig(
    cloudName: 'your-cloud-name',
    apiKey: 'your-api-key',
    apiSecret: 'your-api-secret',
  );

  static Future<String> generateSignature({
    required String publicId,
    required int timestamp,
  }) async {
    // Generate signed URL for secure uploads
    return cloudinary.api.signRequest(
      parameters: {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      },
    );
  }
}
```

### 8.2 Configure CORS (if needed)
1. Go to **Settings** → **Security**
2. Add your domain to **Allowed fetch domains**:
   - `localhost:3000` (development)
   - `your-domain.com` (production)

## 📊 Step 9: Monitor Usage

### 9.1 Dashboard Analytics
Monitor your usage in **Dashboard**:
- **Storage**: Total images and videos stored
- **Bandwidth**: Monthly transfer usage
- **Transformations**: Image processing usage
- **Requests**: API calls made

### 9.2 Set Up Alerts
1. Go to **Settings** → **Notifications**
2. Configure alerts for:
   - Storage limits (80% of quota)
   - Bandwidth limits (80% of quota)
   - Monthly billing thresholds

## 💰 Step 10: Pricing Plans

### Free Plan Includes:
- **25 GB** storage
- **25 GB** monthly bandwidth
- **25,000** monthly transformations
- Basic features

### Paid Plans Start at:
- **$99/month** for Pro plan
- Increased storage and bandwidth
- Advanced features like video processing
- Priority support

## 🔧 Step 11: Update Zarya Implementation

### 11.1 Update Sample Data URLs
Edit `customer_web/lib/services/api_service.dart`:

```dart
// Update sample merchant images
static List<Map<String, dynamic>> getSampleMerchants() {
  return [
    {
      'id': '1',
      'name': 'Glamour Salon',
      'images': ['zarya/merchants/glamour-salon-hero'], // Cloudinary public_id
      // ... other fields
    },
    // ... other merchants
  ];
}
```

### 11.2 Update Image Widgets
Use `CachedNetworkImage` for better performance:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_service.dart';

CachedNetworkImage(
  imageUrl: ImageService.getCardImage(merchant.images.first),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

## ✅ Quick Setup Checklist

- [ ] Create Cloudinary account
- [ ] Copy cloud name, API key, API secret
- [ ] Create unsigned upload preset
- [ ] Update `app_config.dart` with credentials
- [ ] Implement `ImageService` for URL generation
- [ ] Test image loading in your app
- [ ] Set up upload functionality (if needed)
- [ ] Configure security settings
- [ ] Monitor usage and set alerts

## 🆘 Troubleshooting

### Common Issues:

**Images not loading:**
- Check cloud name in URLs
- Verify public_id exists in Cloudinary
- Check CORS settings

**Upload fails:**
- Verify upload preset exists and is unsigned
- Check file size limits
- Verify allowed formats

**URLs not optimizing:**
- Check transformation syntax
- Verify format support
- Test different quality settings

## 📚 Additional Resources

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Integration Guide](https://cloudinary.com/documentation/flutter_integration)
- [Image Optimization Best Practices](https://cloudinary.com/guides/image-optimization)
- [API Reference](https://cloudinary.com/documentation/image_upload_api_reference)

---

**Next Steps**: After completing this setup, you'll have a powerful image management system with automatic optimization and global CDN delivery for your Zarya platform!
