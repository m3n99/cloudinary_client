import 'package:cloudinary_client/cloudinary_client_export.dart';
import 'package:cross_file/cross_file.dart';

void main() async {
  // Initialize the client
  final cloudinary = Cloudinary(
    cloudName: 'my-cloud-name',
    apiKey: 'my-api-key',
    apiSecret: 'my-api-secret',
    uploadPreset: 'my-upload-preset',
    baseUrlType: CloudinaryBaseUrlType.def,
  );

  // --------------------------------------------------------------------------
  // Build a folder path (optional utility)
  // --------------------------------------------------------------------------
  final folder = buildFolderPath(
    domainName: 'acme',
    envName: 'production',
    category: 'avatars',
    folderName: 'user-123',
  );
  // → 'acme/production/avatars/user-123'

  // --------------------------------------------------------------------------
  // Upload an image (unsigned)
  // --------------------------------------------------------------------------
  final imageFile = XFile('/path/to/photo.jpg');

  final uploadResult = await cloudinary.uploadImageUnsigned(
    file: imageFile,
    folder: folder,
  );

  print('Uploaded URL : ${uploadResult.secureUrl}');
  print('Public ID   : ${uploadResult.publicId}');

  // --------------------------------------------------------------------------
  // Upload an image (signed — needs apiKey + apiSecret)
  // --------------------------------------------------------------------------
  final signedResult = await cloudinary.uploadImageWithSignature(
    file: imageFile,
    folder: folder,
    additionalParams: {'tags': 'profile,avatar'},
  );

  print('Signed upload: ${signedResult.secureUrl}');

  // --------------------------------------------------------------------------
  // Upload a raw file (PDF, CSV, etc.)
  // --------------------------------------------------------------------------
  final pdfFile = XFile('/path/to/document.pdf');

  final rawResult = await cloudinary.uploadRawUnsigned(
    file: pdfFile,
    folder: 'acme/production/documents',
  );

  print('Raw upload: ${rawResult.secureUrl}');

  // --------------------------------------------------------------------------
  // Delete an image (signed)
  // --------------------------------------------------------------------------
  final deleted = await cloudinary.deleteImageSigned(
    publicId: uploadResult.publicId ?? '',
  );

  print('Deleted: $deleted');

  // --------------------------------------------------------------------------
  // Delete any asset via Admin API (requires apiKey + apiSecret)
  // --------------------------------------------------------------------------
  final adminDeleted = await cloudinary.deleteAsset(
    publicId: signedResult.publicId ?? '',
    resourceType: CloudinaryResourceType.image,
  );

  print('Admin deleted: $adminDeleted');
}
