import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:image_cropper/image_cropper.dart';  // Commented out due to web compatibility
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../config/cloudinary_config.dart';

/// Upload service for Cloudinary with mobile-specific implementation
/// 
/// Key features:
/// - Image picking from camera and gallery
/// - Image cropping before upload
/// - Client-side file validation
/// - Progress tracking
/// - Multiple image upload support
class UploadService {
  static final Dio _dio = Dio();
  static final ImagePicker _picker = ImagePicker();
  
  // Client-side restrictions (using config values)
  static List<String> get allowedMimeTypes => CloudinaryConfig.allowedMimeTypes;
  static int get maxFileSize => CloudinaryConfig.maxFileSize;
  static int get maxImageWidth => CloudinaryConfig.maxImageWidth;
  static int get maxImageHeight => CloudinaryConfig.maxImageHeight;
  
  /// Pick an image from camera or gallery
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    bool allowEditing = true,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      File imageFile = File(image.path);
      
      // Crop image if editing is allowed (disabled for web compatibility)
      // if (allowEditing) {
      //   final croppedFile = await _cropImage(imageFile);
      //   if (croppedFile != null) {
      //     imageFile = croppedFile;
      //   }
      // }
      
      return imageFile;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
  
  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    int maxImages = 10,
    bool allowEditing = true,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: 85,
      );
      
      if (images.isEmpty) return [];
      
      List<File> imageFiles = [];
      
      for (XFile image in images.take(maxImages)) {
        File imageFile = File(image.path);
        
        // Crop image if editing is allowed (disabled for web compatibility)
        // if (allowEditing) {
        //   final croppedFile = await _cropImage(imageFile);
        //   if (croppedFile != null) {
        //     imageFile = croppedFile;
        //   }
        // }
        
        imageFiles.add(imageFile);
      }
      
      return imageFiles;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
  
  /// Crop an image using image_cropper (disabled for web compatibility)
  // static Future<File?> _cropImage(File imageFile) async {
  //   try {
  //     final croppedFile = await ImageCropper().cropImage(
  //       sourcePath: imageFile.path,
  //       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //       uiSettings: [
  //         AndroidUiSettings(
  //           toolbarTitle: 'Crop Image',
  //           toolbarColor: const Color(0xFF2196F3),
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.square,
  //           lockAspectRatio: false,
  //         ),
  //         IOSUiSettings(
  //           title: 'Crop Image',
  //           aspectRatioLockEnabled: false,
  //         ),
  //       ],
  //     );
  //     
  //     return croppedFile != null ? File(croppedFile.path) : null;
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //     return null;
  //   }
  // }
  
  /// Upload an image file to Cloudinary
  /// 
  /// Returns the public_id of the uploaded image, or null if upload fails
  static Future<String?> uploadImage(
    File file, {
    String? folder,
    Function(double)? onProgress,
  }) async {
    // Client-side validation
    final validationError = _validateFile(file);
    if (validationError != null) {
      print('Upload validation failed: $validationError');
      return null;
    }
    
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': folder ?? CloudinaryConfig.merchantProfileFolder,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      final response = await _dio.post(
        '${CloudinaryConfig.uploadUrl}/image/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onProgress != null && total > 0) {
            final progress = (sent / total) * 100;
            onProgress(progress);
          }
        },
      );
      
      if (response.statusCode == 200) {
        final publicId = response.data['public_id'] as String;
        print('Upload successful: $publicId');
        return publicId;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
  
  /// Upload multiple images concurrently
  static Future<List<String>> uploadMultipleImages(
    List<File> files, {
    String? folder,
    int maxConcurrent = 3,
    Function(double)? onProgress,
  }) async {
    final results = <String>[];
    int completedUploads = 0;
    
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
        completedUploads++;
        
        // Update overall progress
        if (onProgress != null) {
          final progress = (completedUploads / files.length) * 100;
          onProgress(progress);
        }
      }
    }
    
    return results;
  }
  
  /// Client-side file validation
  /// Returns null if valid, error message if invalid
  static String? _validateFile(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      return 'File does not exist';
    }
    
    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxFileSize) {
      return 'File size ${formatFileSize(fileSize)} exceeds maximum '
             '${formatFileSize(maxFileSize)}';
    }
    
    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    if (!allowedExtensions.contains(extension)) {
      return 'File extension ".$extension" is not allowed. '
             'Allowed extensions: ${allowedExtensions.join(', ')}';
    }
    
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
  
  /// Get Cloudinary URL for an image
  static String getImageUrl(String publicId, {
    int? width,
    int? height,
    String? transformation,
  }) {
    String url = '${CloudinaryConfig.baseUrl}/image/upload';
    
    if (transformation != null) {
      url += '/$transformation';
    } else if (width != null || height != null) {
      final params = <String>[];
      if (width != null) params.add('w_$width');
      if (height != null) params.add('h_$height');
      url += '/${params.join(',')}';
    }
    
    url += '/$publicId';
    return url;
  }
  
  /// Delete an image from Cloudinary (requires server-side implementation)
  static Future<bool> deleteImage(String publicId) async {
    // Note: This requires server-side implementation with API key
    // For now, we'll return false as this should be handled by backend
    print('Image deletion should be handled server-side for security');
    return false;
  }
}
