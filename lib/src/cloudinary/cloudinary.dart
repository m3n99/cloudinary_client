import 'dart:developer';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../networking.dart';
import 'enums/cloudinary_base_url_type.dart';
import 'enums/cloudinary_resource_type.dart';
import 'models/cloudinary_response.dart';
import 'utils.dart';

/// Builds a Cloudinary folder path from its component parts.
///
/// Example:
/// ```dart
/// buildFolderPath(
///   domainName: 'acme',
///   envName: 'production',
///   category: 'avatars',
///   folderName: 'user-123',
/// ); // → 'acme/production/avatars/user-123'
/// ```
String buildFolderPath({
  required String domainName,
  required String envName,
  required String category,
  required String folderName,
}) {
  return '$domainName/$envName/$category/$folderName';
}

/// A lightweight Cloudinary client for uploading and deleting assets.
///
/// Supports both signed and unsigned upload flows for images and raw files.
/// Signed operations require [apiKey] and [apiSecret]; unsigned operations
/// only need an [uploadPreset] configured in your Cloudinary dashboard.
///
/// ```dart
/// final cloudinary = Cloudinary(
///   cloudName: 'my-cloud',
///   apiKey: 'key',
///   apiSecret: 'secret',
///   uploadPreset: 'my-preset',
///   baseUrlType: CloudinaryBaseUrlType.def,
/// );
/// ```
class Cloudinary {
  /// Your Cloudinary API key (required for signed operations).
  final String? apiKey;

  /// Your Cloudinary API secret (required for signed operations).
  final String? apiSecret;

  /// The Cloudinary cloud name (e.g. `my-cloud-name`).
  final String cloudName;

  /// The unsigned upload preset configured in your Cloudinary dashboard.
  final String? uploadPreset;

  /// The regional base URL to use for API calls.
  final CloudinaryBaseUrlType baseUrlType;

  late final CloudinaryHttpClient _httpClient;

  Cloudinary({
    this.apiKey,
    this.apiSecret,
    this.uploadPreset,
    required this.cloudName,
    required this.baseUrlType,
  }) {
    _httpClient = CloudinaryHttpClient(baseUrl: baseUrl);
  }

  /// The resolved Cloudinary API base URL, e.g.
  /// `https://api.cloudinary.com/v1_1/my-cloud-name`.
  String get baseUrl => baseUrlType.value + cloudName;

  /// Uploads an image using a **signed** request.
  ///
  /// A signature is generated locally from [apiSecret] before sending,
  /// so no upload preset is required — but [apiKey] and [apiSecret] must
  /// be set.
  ///
  /// [folder] is the destination folder path inside your Cloudinary media
  /// library. Use [buildFolderPath] to construct it from parts.
  Future<CloudinaryResponse> uploadImageWithSignature({
    required XFile file,
    required String folder,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final params = {
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'folder': folder,
        ...?additionalParams,
      };

      final signature = CloudinaryUtils().generateSignature(
        params: params,
        apiSecret: apiSecret ?? '',
      );

      final fileMultipart = await dio.MultipartFile.fromFile(
        file.path,
        filename: file.name,
      );

      final data = {
        'file': fileMultipart,
        'api_key': apiKey,
        'timestamp': params['timestamp'],
        'signature': signature,
        'folder': folder,
        if (uploadPreset != null) 'upload_preset': uploadPreset,
        ...?additionalParams,
      };

      final response = await _httpClient.postMultipart(
        '/${CloudinaryResourceType.image.value}/upload',
        data,
      );

      return CloudinaryResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Signed image upload failed: $e');
    }
  }

  /// Uploads an image using an **unsigned** request.
  ///
  /// Requires [uploadPreset] to be set. No secret is needed, making this
  /// safe to call directly from client-side code.
  ///
  /// Handles both web (reads bytes) and native (reads from file path)
  /// automatically via [kIsWeb].
  Future<CloudinaryResponse> uploadImageUnsigned({
    required XFile file,
    String? folder,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final dio.MultipartFile fileMultipart;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        fileMultipart = dio.MultipartFile.fromBytes(bytes, filename: file.name);
      } else {
        fileMultipart =
            await dio.MultipartFile.fromFile(file.path, filename: file.name);
      }

      final data = {
        'file': fileMultipart,
        if (uploadPreset != null) 'upload_preset': uploadPreset,
        if (apiKey != null) 'api_key': apiKey,
        'folder': ?folder,
        ...?additionalParams,
      };

      final response = await _httpClient.postMultipart(
        '/${CloudinaryResourceType.image.value}/upload',
        data,
      );

      log(response.toString(), name: 'Cloudinary.uploadImageUnsigned');
      return CloudinaryResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Unsigned image upload failed: $e');
    }
  }

  /// Uploads a raw file (PDF, CSV, etc.) using an **unsigned** request.
  ///
  /// Uses the `raw` Cloudinary resource type, which accepts any file format
  /// without transcoding. Suitable for documents and arbitrary binary files.
  ///
  /// Handles both web and native platforms automatically.
  Future<CloudinaryResponse> uploadRawUnsigned({
    required XFile file,
    String? folder,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final dio.MultipartFile fileMultipart;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        fileMultipart = dio.MultipartFile.fromBytes(bytes, filename: file.name);
      } else {
        fileMultipart = await dio.MultipartFile.fromFile(
          file.path,
          filename: file.name,
          contentType: dio.DioMediaType('application', 'octet-stream'),
        );
      }

      final data = {
        'file': fileMultipart,
        if (uploadPreset != null) 'upload_preset': uploadPreset,
        if (apiKey != null) 'api_key': apiKey,
        'folder': ?folder,
        ...?additionalParams,
      };

      final response = await _httpClient.postMultipart(
        '/${CloudinaryResourceType.raw.value}/upload',
        data,
      );

      log(response.toString(), name: 'Cloudinary.uploadRawUnsigned');
      return CloudinaryResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      log('Upload error: $e', name: 'Cloudinary.uploadRawUnsigned');
      throw Exception('Unsigned raw upload failed: $e');
    }
  }

  /// Deletes an image using a **signed** destroy request.
  ///
  /// Calls the `/image/destroy` endpoint, which requires [apiKey] and
  /// [apiSecret] to generate the signature. Returns `true` on success.
  Future<bool> deleteImageSigned({required String publicId}) async {
    try {
      final params = {
        'public_id': publicId,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      final signature = CloudinaryUtils().generateSignature(
        params: params,
        apiSecret: apiSecret ?? '',
      );

      final data = {
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': params['timestamp'],
        'signature': signature,
      };

      final response = await _httpClient.post(
        '/${CloudinaryResourceType.image.value}/destroy',
        data,
      );

      log(response.toString(), name: 'Cloudinary.deleteImageSigned');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Signed image deletion failed: $e');
    }
  }

  /// Deletes any asset via the Cloudinary **Admin API**.
  ///
  /// Uses HTTP Basic Auth with [apiKey] and [apiSecret] embedded in the URL.
  /// Supports any [resourceType] (defaults to [CloudinaryResourceType.image]).
  /// Returns `true` on success.
  Future<bool> deleteAsset({
    required String publicId,
    CloudinaryResourceType resourceType = CloudinaryResourceType.image,
  }) async {
    try {
      final response = await _httpClient.delete(
        'https://$apiKey:$apiSecret@api.cloudinary.com/v1_1/$cloudName/resources/${resourceType.value}/upload',
        data: {'public_id': publicId},
      );

      log(response.toString(), name: 'Cloudinary.deleteAsset');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Asset deletion failed: $e');
    }
  }
}
