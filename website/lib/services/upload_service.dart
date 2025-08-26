import 'dart:html' as html;
import 'dart:convert';
import '../config/cloudinary_config.dart';

/// Upload service for Cloudinary with August 2025 security updates
/// 
/// Key changes:
/// - Client-side file validation is now required
/// - Server-side restrictions are set via transformations in upload preset
/// - File type and size limits are enforced client-side
class UploadService {
  // Client-side restrictions (new approach as of Aug 2025)
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png', 
    'image/webp', 
    'image/gif'
  ];
  
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  
  /// Upload an image file to Cloudinary with client-side validation
  /// 
  /// Returns the public_id of the uploaded image, or null if upload fails
  static Future<String?> uploadImage(html.File file, {String? folder}) async {
    // Client-side validation (required as of Aug 2025)
    final validationError = _validateFile(file);
    if (validationError != null) {
      print('Upload validation failed: $validationError');
      return null;
    }
    
    try {
      final formData = html.FormData();
      formData.append('file', file);
      formData.append('upload_preset', CloudinaryConfig.uploadPreset);
      
      // Use custom folder or default
      final uploadFolder = folder ?? 'zarya/user-uploads';
      formData.append('folder', uploadFolder);
      
      // Add timestamp for uniqueness
      formData.append('timestamp', DateTime.now().millisecondsSinceEpoch.toString());

      final request = html.HttpRequest();
      request.open('POST', '${CloudinaryConfig.uploadUrl}/image/upload');
      
      // Set up progress tracking (optional)
      request.upload.onProgress.listen((event) {
        if (event.lengthComputable!) {
          final progress = (event.loaded! / event.total!) * 100;
          print('Upload progress: ${progress.toStringAsFixed(1)}%');
        }
      });
      
      // Wait for upload to complete
      await request.onLoad.first;
      
      if (request.status == 200) {
        final response = jsonDecode(request.responseText!);
        final publicId = response['public_id'] as String;
        print('Upload successful: $publicId');
        return publicId;
      } else {
        print('Upload failed with status: ${request.status}');
        print('Response: ${request.responseText}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
  
  /// Upload multiple images concurrently
  static Future<List<String>> uploadMultipleImages(
    List<html.File> files, {
    String? folder,
    int maxConcurrent = 3,
  }) async {
    final results = <String>[];
    
    // Process files in batches to avoid overwhelming the server
    for (int i = 0; i < files.length; i += maxConcurrent) {
      final batch = files.skip(i).take(maxConcurrent).toList();
      final futures = batch.map((file) => uploadImage(file, folder: folder));
      final batchResults = await Future.wait(futures);
      
      // Add successful uploads to results
      for (final result in batchResults) {
        if (result != null) {
          results.add(result);
        }
      }
    }
    
    return results;
  }
  
  /// Client-side file validation (required as of Aug 2025)
  /// Returns null if valid, error message if invalid
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
    
    // Additional checks can be added here
    return null; // File is valid
  }
  
  /// Helper method to format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  /// Check if a file type is supported
  static bool isFileTypeSupported(String? mimeType) {
    return mimeType != null && allowedMimeTypes.contains(mimeType.toLowerCase());
  }
  
  /// Get maximum allowed file size in bytes
  static int getMaxFileSize() => maxFileSize;
  
  /// Get list of supported file extensions
  static List<String> getSupportedExtensions() {
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  }
}

/// Extension to help with file picking
extension FilePickerExtension on html.FileUploadInputElement {
  /// Configure file input for image uploads with proper restrictions
  void configureForImageUpload() {
    accept = 'image/jpeg,image/jpg,image/png,image/webp,image/gif';
    multiple = false;
  }
  
  /// Configure file input for multiple image uploads
  void configureForMultipleImageUpload() {
    accept = 'image/jpeg,image/jpg,image/png,image/webp,image/gif';
    multiple = true;
  }
}
