# 🌤️ Cloudinary Setup Guide - Step by Step

This guide will walk you through setting up Cloudinary for the Zarya booking platform, replacing Firebase hosting with a more flexible solution.

## 📋 Prerequisites

Before starting, make sure you have:
- ✅ A working Flutter development environment
- ✅ The Zarya project cloned to your machine
- ✅ Internet connection for account creation

## 🚀 Step 1: Create Your Cloudinary Account

### 1.1 Visit Cloudinary Website
1. Open your browser and go to [https://cloudinary.com/](https://cloudinary.com/)
2. Click the **"Sign Up for Free"** button

### 1.2 Choose Signup Method
You can sign up using:
- **Email and Password** (recommended)
- **GitHub Account**
- **Google Account**

### 1.3 Fill Out Registration Form
```
Full Name: [Your Name]
Email: [your-email@example.com]
Company: [Optional - can put "Personal Project"]
Password: [Create a strong password]
```

### 1.4 Verify Your Email
1. Check your email inbox for verification message
2. Click the verification link
3. Return to Cloudinary console

## ⚙️ Step 2: Complete Account Setup

### 2.1 Choose Your Cloud Name
This is **VERY IMPORTANT** - your cloud name will be part of all your image URLs:

```
Examples:
✅ Good: zarya-booking, my-salon-app, booking-platform
❌ Bad: test123, temp, myapp (too generic)
```

**Important Notes:**
- Cloud name must be **unique across all Cloudinary users**
- Can only contain letters, numbers, and hyphens
- **Cannot be changed later** - choose carefully!
- Write it down - you'll need it later

### 2.2 Select Use Case
- Choose **"Web and mobile development"**
- This optimizes your dashboard for app development

### 2.3 Complete Survey
Fill out the brief survey about your intended usage:
- **Primary use case**: Image management for mobile/web app
- **Team size**: Individual or Small team
- **Monthly image uploads**: Start with "Less than 1000"

## 🔑 Step 3: Get Your API Credentials

### 3.1 Access Your Dashboard
1. After signup, you'll be redirected to the Cloudinary Console
2. If not, login at [https://console.cloudinary.com/](https://console.cloudinary.com/)
3. Go to **Dashboard** (should be the default page)

### 3.2 Find Your Credentials
On the dashboard, you'll see a section like this:

```
Account Details
Cloud name: your-chosen-cloud-name
API Key: 123456789012345
API Secret: abcdefghijklmnopqrstuvwxyz123456 [Hidden]
```

### 3.3 Copy Your Credentials
**IMPORTANT**: Write these down in a secure place:

```
Cloud Name: ____________________
API Key: _______________________
API Secret: ____________________
```

**⚠️ Security Warning**: 
- Your API Secret is like a password - keep it secure!
- Never commit it to public code repositories
- Only use it in backend code, never in frontend

## 📁 Step 4: Configure Upload Settings

### 4.1 Navigate to Upload Settings
1. In Cloudinary Console, click **Settings** (gear icon) in the top menu
2. Click **Upload** tab on the left sidebar
3. Scroll down to **Upload presets** section

### 4.2 Create an Upload Preset
1. Click **Add upload preset** button
2. Configure the preset:

```
Preset name: zarya_uploads
Signing mode: Unsigned (important for client uploads)
Folder: zarya/
Use filename or externally defined Public ID: ✓ Checked
Unique filename: ✓ Checked
Overwrite: ✓ Checked
```

### 4.3 Set File Restrictions
In the same preset, set:

```
Allowed formats: jpg,png,webp,gif,jpeg
Max file size: 10000000 (10MB)
Max image width: 2048
Max image height: 2048
```

### 4.4 Add Transformations (Optional)
For automatic optimization:

```
Quality: auto:good
Format: auto
```

### 4.5 Save the Preset
1. Click **Save** at the bottom
2. Note down the preset name: `zarya_uploads`

## 💻 Step 5: Update Your Flutter Project

### 5.1 Navigate to Your Project
```bash
cd /path/to/zarya/customer_web
```

### 5.2 Create Configuration File
Create a new file `lib/config/cloudinary_config.dart`:

```dart
class CloudinaryConfig {
  // Replace with YOUR actual cloud name from Step 3
  static const String cloudName = 'your-cloud-name-here';
  
  // This will be your API key from Step 3 (for backend use only)
  static const String apiKey = 'your-api-key-here';
  
  // Upload preset name from Step 4
  static const String uploadPreset = 'zarya_uploads';
  
  // Base URLs for image delivery
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName';
}
```

**Replace the placeholder values:**
- Change `your-cloud-name-here` to your actual cloud name
- Change `your-api-key-here` to your actual API key

### 5.3 Update API Service
Open `lib/services/api_service.dart` and update it:

```dart
import '../config/cloudinary_config.dart';

class ApiService {
  static Future<void> initialize() async {
    // Initialize any required services
    print('API Service initialized with Cloudinary');
    print('Cloud Name: ${CloudinaryConfig.cloudName}');
  }

  // Helper method to get optimized image URLs
  static String getImageUrl(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');
    
    final transformation = transformations.join(',');
    return '${CloudinaryConfig.baseUrl}/image/upload/$transformation/$publicId';
  }

  // Sample merchants with Cloudinary image URLs
  static List<Map<String, dynamic>> getSampleMerchants() {
    return [
      {
        'id': '1',
        'name': 'Glamour Salon',
        'description': 'Premium beauty and hair services',
        'category': 'Beauty',
        'rating': 4.8,
        'reviewCount': 124,
        'address': '123 Beauty Street, City Center',
        'phone': '+1 (555) 123-4567',
        'email': 'info@glamoursalon.com',
        'images': ['zarya/sample/salon1'], // Cloudinary public ID
        'services': ['1', '2', '3'],
        'workingHours': {
          'monday': {'open': '09:00', 'close': '18:00'},
          'tuesday': {'open': '09:00', 'close': '18:00'},
          'wednesday': {'open': '09:00', 'close': '18:00'},
          'thursday': {'open': '09:00', 'close': '18:00'},
          'friday': {'open': '09:00', 'close': '19:00'},
          'saturday': {'open': '08:00', 'close': '17:00'},
          'sunday': {'open': '10:00', 'close': '16:00'},
        },
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      // Add more sample merchants as needed
    ];
  }

  // Sample services
  static List<Map<String, dynamic>> getSampleServices() {
    return [
      {
        'id': '1',
        'merchantId': '1',
        'name': 'Hair Cut & Style',
        'description': 'Professional haircut with styling',
        'price': 45.0,
        'duration': 60,
        'category': 'Hair',
        'isActive': true,
        'images': ['zarya/sample/haircut'], // Cloudinary public ID
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      // Add more services
    ];
  }
}
```

## 🧪 Step 6: Test Your Setup

### 6.1 Build the Project
```bash
flutter clean
flutter pub get
flutter build web
```

### 6.2 Run the Project
```bash
flutter run -d chrome
```

### 6.3 Check Console Output
You should see:
```
API Service initialized with Cloudinary
Cloud Name: your-cloud-name
```

## 📤 Step 7: Add Image Upload Functionality (Optional)

If you want to allow users to upload images, create `lib/services/upload_service.dart`:

```dart
import 'dart:html' as html;
import 'dart:convert';
import '../config/cloudinary_config.dart';

class UploadService {
  static Future<String?> uploadImage(html.File file) async {
    try {
      final formData = html.FormData();
      formData.append('file', file);
      formData.append('upload_preset', CloudinaryConfig.uploadPreset);
      formData.append('folder', 'zarya/user-uploads');

      final request = html.HttpRequest();
      request.open('POST', '${CloudinaryConfig.uploadUrl}/image/upload');
      
      // Wait for upload to complete
      await request.onLoad.first;
      
      if (request.status == 200) {
        final response = jsonDecode(request.responseText!);
        return response['public_id']; // Return the public ID
      } else {
        print('Upload failed: ${request.status}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
```

## 🔒 Step 8: Security Best Practices

### 8.1 Environment Variables (Production)
For production, use environment variables:

```dart
class CloudinaryConfig {
  static const String cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const String apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  // ... etc
}
```

### 8.2 Backend Integration
For production apps, handle uploads through your backend:

```dart
// Instead of direct upload, send to your backend
static Future<String?> uploadImageViaBackend(html.File file) async {
  // Your backend handles Cloudinary upload with signed URLs
  // This is more secure than client-side uploads
}
```

## 📊 Step 9: Monitor Usage

### 9.1 Check Dashboard
Regularly monitor your Cloudinary dashboard:
- **Storage usage**: How much space you're using
- **Bandwidth**: Monthly transfer
- **Transformations**: Image processing usage

### 9.2 Set Up Alerts
1. Go to **Settings** → **Notifications**
2. Set alerts for:
   - 80% storage usage
   - 80% bandwidth usage
   - Monthly spend limits

## 🆘 Troubleshooting

### Common Issues:

**🔴 "Cloud name not found" error:**
- Double-check your cloud name in `cloudinary_config.dart`
- Make sure it matches exactly what's in your Cloudinary dashboard

**🔴 "Upload preset not found":**
- Verify the preset name in Cloudinary console
- Make sure it's set to "Unsigned" mode

**🔴 "Access denied" error:**
- Check that your upload preset allows the file type
- Verify file size limits

**🔴 Images not loading:**
- Check the public_id exists in Cloudinary
- Verify the URL structure is correct

## ✅ Completion Checklist

Mark each item as you complete it:

- [ ] Created Cloudinary account
- [ ] Chose and noted cloud name
- [ ] Copied API credentials securely
- [ ] Created upload preset "zarya_uploads"
- [ ] Created `cloudinary_config.dart` file
- [ ] Updated `api_service.dart` with Cloudinary URLs
- [ ] Successfully built the Flutter project
- [ ] Tested the app runs without errors
- [ ] Set up monitoring alerts
- [ ] Planned security measures for production

## 🎉 Next Steps

Now that Cloudinary is set up:

1. **Upload sample images** to test your setup
2. **Configure your backend** to handle image operations
3. **Set up image optimization** for better performance
4. **Plan your folder structure** for organizing images
5. **Consider implementing** signed uploads for security

## 📞 Need Help?

- **Cloudinary Documentation**: [https://cloudinary.com/documentation](https://cloudinary.com/documentation)
- **Flutter Integration**: [https://cloudinary.com/documentation/flutter_integration](https://cloudinary.com/documentation/flutter_integration)
- **Support**: [https://support.cloudinary.com](https://support.cloudinary.com)

---

**Congratulations!** 🎊 You've successfully set up Cloudinary for your Zarya booking platform. Your app now has powerful image management capabilities with automatic optimization and global CDN delivery!
