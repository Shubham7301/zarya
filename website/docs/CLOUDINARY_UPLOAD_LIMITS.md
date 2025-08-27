# 📏 Cloudinary Upload Limits & Restrictions

This document outlines all file upload limits and restrictions implemented in the Zarya booking platform for Cloudinary integration.

## 🔒 Security Model (August 2025)

As of August 2025, Cloudinary changed their security approach:
- **Client-side validation**: Required and enforced before upload
- **Server-side restrictions**: Applied via transformation parameters in upload preset
- **Preset UI restrictions**: No longer available (deprecated)

## 📋 Current Upload Limits

### **File Size Restrictions**
```dart
Maximum file size: 10 MB (10,485,760 bytes)
```

**Implementation:**
```dart
static const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
```

**Error message example:**
```
"File size 15.2MB exceeds maximum 10.0MB"
```

### **File Type Restrictions**
```dart
Allowed MIME types:
- image/jpeg
- image/jpg  
- image/png
- image/webp
- image/gif
```

**Implementation:**
```dart
static const List<String> allowedMimeTypes = [
  'image/jpeg',
  'image/jpg', 
  'image/png', 
  'image/webp', 
  'image/gif'
];
```

**Supported file extensions:**
```
.jpg, .jpeg, .png, .webp, .gif
```

**Error message example:**
```
"File type 'application/pdf' is not allowed. Allowed types: image/jpeg, image/jpg, image/png, image/webp, image/gif"
```

### **Image Dimension Restrictions**
```dart
Maximum width:  2048 pixels
Maximum height: 2048 pixels
```

**Implementation:**
```dart
static const int maxImageWidth = 2048;
static const int maxImageHeight = 2048;
```

**Server-side enforcement (Upload Preset Transformation):**
```
w_2048,h_2048,c_limit,q_auto:good,f_auto
```

## 🛡️ Validation Process

### **1. Client-Side Validation (Pre-Upload)**

All files are validated **before** being sent to Cloudinary:

```dart
static String? _validateFile(html.File file) {
  // Check file type
  if (!allowedMimeTypes.contains(file.type?.toLowerCase())) {
    return 'File type "${file.type}" is not allowed. '
           'Allowed types: ${allowedMimeTypes.join(', ')}';
  }
  
  // Check file size
  if (file.size > maxFileSize) {
    return 'File size ${formatFileSize(file.size)} exceeds maximum '
           '${formatFileSize(maxFileSize)}';
  }
  
  return null; // File is valid
}
```

### **2. Server-Side Transformation (Cloudinary)**

Applied automatically via upload preset:
- Limits image dimensions to 2048×2048
- Optimizes quality automatically
- Converts to best format for web delivery

## 📊 Upload Quotas & Performance

### **Concurrent Upload Limits**
```dart
Maximum concurrent uploads: 3 files
```

**Implementation:**
```dart
static Future<List<String>> uploadMultipleImages(
  List<html.File> files, {
  String? folder,
  int maxConcurrent = 3, // Configurable
}) async {
  // Processes files in batches of 3
}
```

### **Cloudinary Account Limits (Free Tier)**
```
Storage:        25 GB
Bandwidth:      25 GB/month  
Transformations: 25,000/month
API calls:      Unlimited
```

### **Rate Limiting**
- No artificial rate limiting imposed by our service
- Cloudinary's standard rate limits apply
- Batch processing prevents server overload

## 🔧 Configuration & Settings

### **Upload Service Configuration**
Location: `customer_web/lib/services/upload_service.dart`

```dart
class UploadService {
  // Configurable limits
  static const List<String> allowedMimeTypes = [/* ... */];
  static const int maxFileSize = 10 * 1024 * 1024;
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
}
```

### **Upload Preset Configuration**
Location: Cloudinary Console → Settings → Upload

```
Preset name: zarya_uploads
Signing mode: Unsigned
Folder: zarya/
Transformations: w_2048,h_2048,c_limit,q_auto:good,f_auto
```

## 📱 Usage Examples

### **Single File Upload with Validation**
```dart
Future<void> uploadProfilePicture() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp,image/gif'
    ..multiple = false;
  
  input.click();
  
  input.onChange.listen((e) async {
    final files = input.files;
    if (files!.isEmpty) return;
    
    final file = files[0];
    
    // Validation happens automatically
    final publicId = await UploadService.uploadImage(file, folder: 'zarya/profiles');
    
    if (publicId != null) {
      print('Upload successful: $publicId');
      // Update UI with new image
    } else {
      // Check console for validation error
      _showErrorMessage('Upload failed. Please check file size and type.');
    }
  });
}
```

### **Multiple File Upload with Progress**
```dart
Future<void> uploadGalleryImages() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png,image/webp,image/gif'
    ..multiple = true;
  
  input.click();
  
  input.onChange.listen((e) async {
    final files = input.files;
    if (files!.isEmpty) return;
    
    // Upload up to 5 images concurrently
    final publicIds = await UploadService.uploadMultipleImages(
      files, 
      folder: 'zarya/gallery',
      maxConcurrent: 5,
    );
    
    print('Uploaded ${publicIds.length} of ${files.length} files');
    // Update gallery with new images
  });
}
```

### **File Picker Configuration**
```dart
// Configure file input for image uploads
final input = html.FileUploadInputElement();
input.configureForImageUpload(); // Extension method

// For multiple images
input.configureForMultipleImageUpload();
```

## 🚨 Error Handling

### **Common Validation Errors**

| Error Type | Message | Solution |
|------------|---------|----------|
| **File too large** | "File size 15.2MB exceeds maximum 10.0MB" | Compress image or choose smaller file |
| **Invalid type** | "File type 'application/pdf' is not allowed" | Use JPEG, PNG, WebP, or GIF only |
| **Upload failed** | "Upload error: Network timeout" | Check internet connection, retry |
| **Preset error** | "Upload preset not found" | Verify preset exists and is unsigned |

### **Error Handling Best Practices**
```dart
try {
  final publicId = await UploadService.uploadImage(file);
  if (publicId != null) {
    // Success
  } else {
    // Validation failed - error already logged to console
    _showUserFriendlyError();
  }
} catch (e) {
  // Network or server error
  _showRetryOption();
}
```

## 🔄 Updating Limits

### **To Change File Size Limit:**
1. Update `maxFileSize` in `upload_service.dart`
2. Test with files near the new limit
3. Update this documentation

### **To Add New File Types:**
1. Add MIME type to `allowedMimeTypes` array
2. Update file picker `accept` attribute
3. Test upload and display functionality
4. Update documentation

### **To Change Image Dimensions:**
1. Update `maxImageWidth` and `maxImageHeight`
2. Update Cloudinary upload preset transformation
3. Test with high-resolution images
4. Update documentation

## 📊 Monitoring & Analytics

### **Upload Success Tracking**
Monitor via console logs:
```dart
// Success
Upload successful: zarya/profiles/user_123_1640995200000

// Validation failure  
Upload validation failed: File size 15.2MB exceeds maximum 10.0MB

// Network error
Upload error: SocketException: Failed to connect
```

### **Cloudinary Dashboard Monitoring**
Track usage in Cloudinary Console:
- **Storage usage**: Monitor approaching limits
- **Bandwidth consumption**: Track monthly transfer
- **Transformation usage**: API processing calls
- **Error rates**: Failed upload attempts

## 🔮 Future Considerations

### **Potential Enhancements**
- **Progressive upload**: For large files with resume capability
- **Image compression**: Client-side before upload
- **Preview generation**: Thumbnails before upload confirmation
- **Drag & drop**: Enhanced user experience
- **Upload queue**: Background processing with status

### **Scalability Options**
- **Increase limits**: For premium merchants
- **Custom presets**: Per merchant type restrictions
- **CDN optimization**: Region-specific upload endpoints
- **Background jobs**: Server-side processing queue

---

**Last Updated**: December 2024  
**Version**: 1.0  
**Compatibility**: Cloudinary August 2025 Security Model
