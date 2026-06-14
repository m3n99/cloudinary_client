enum CloudinaryResourceType {
  image('image'),
  raw('raw'),
  video('video'),
  auto('auto');

  const CloudinaryResourceType(this.value);
  final String value;
}

extension CloudinaryResourceTypeX on String? {
  CloudinaryResourceType toCloudinaryResourceType() {
    switch (this?.toLowerCase()) {
      case 'image':
        return CloudinaryResourceType.image;
      case 'raw':
        return CloudinaryResourceType.raw;
      case 'video':
        return CloudinaryResourceType.video;
      default:
        return CloudinaryResourceType.auto;
    }
  }
}
