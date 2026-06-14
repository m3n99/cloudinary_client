import '../enums/cloudinary_resource_type.dart';
import '../enums/cloudinary_delivery_type.dart';

class CloudinaryResponse {
  final String? publicId;
  final String? assetId;
  final String? secureUrl;
  final String? url;
  final String? version;
  final CloudinaryDeliveryType? type;
  final CloudinaryResourceType? resourceType;
  final String? createdAt;
  final String? displayName;
  final String? signature;

  const CloudinaryResponse({
    this.publicId,
    this.assetId,
    this.secureUrl,
    this.url,
    this.version,
    this.type,
    this.resourceType,
    this.createdAt,
    this.displayName,
    this.signature,
  });

  factory CloudinaryResponse.fromJson(Map<String, dynamic> json) => CloudinaryResponse(
        publicId: json['public_id'] as String?,
        assetId: json['asset_id'] as String?,
        secureUrl: json['secure_url'] as String?,
        url: json['url'] as String?,
        version: json['version_id'] as String?,
        type: (json['type'] as String?).toCloudinaryDeliveryType(),
        resourceType: (json['resource_type'] as String?).toCloudinaryResourceType(),
        createdAt: json['created_at'] as String?,
        displayName: json['display_name'] as String?,
        signature: json['signature'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'public_id': publicId,
        'asset_id': assetId,
        'secure_url': secureUrl,
        'url': url,
        'version_id': version,
        'type': type?.value,
        'resource_type': resourceType?.value,
        'created_at': createdAt,
        'display_name': displayName,
        'signature': signature,
      };

  CloudinaryResponse copyWith({
    String? publicId,
    String? assetId,
    String? secureUrl,
    String? url,
    String? version,
    CloudinaryDeliveryType? type,
    CloudinaryResourceType? resourceType,
    String? createdAt,
    String? displayName,
    String? signature,
  }) {
    return CloudinaryResponse(
      publicId: publicId ?? this.publicId,
      assetId: assetId ?? this.assetId,
      secureUrl: secureUrl ?? this.secureUrl,
      url: url ?? this.url,
      version: version ?? this.version,
      type: type ?? this.type,
      resourceType: resourceType ?? this.resourceType,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      signature: signature ?? this.signature,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloudinaryResponse &&
        other.publicId == publicId &&
        other.assetId == assetId &&
        other.secureUrl == secureUrl &&
        other.url == url &&
        other.version == version &&
        other.type == type &&
        other.resourceType == resourceType &&
        other.createdAt == createdAt &&
        other.displayName == displayName &&
        other.signature == signature;
  }

  @override
  int get hashCode => Object.hash(
        publicId,
        assetId,
        secureUrl,
        url,
        version,
        type,
        resourceType,
        createdAt,
        displayName,
        signature,
      );
}
