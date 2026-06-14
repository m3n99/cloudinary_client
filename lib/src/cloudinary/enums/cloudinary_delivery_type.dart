enum CloudinaryDeliveryType {
  upload('upload'),
  private('private'),
  fetch('fetch'),
  authenticated('authenticated'),
  auto('auto');

  const CloudinaryDeliveryType(this.value);
  final String value;
}

extension CloudinaryDeliveryTypeX on String? {
  CloudinaryDeliveryType toCloudinaryDeliveryType() {
    switch (this?.toLowerCase()) {
      case 'upload':
        return CloudinaryDeliveryType.upload;
      case 'private':
        return CloudinaryDeliveryType.private;
      case 'fetch':
        return CloudinaryDeliveryType.fetch;
      case 'authenticated':
        return CloudinaryDeliveryType.authenticated;
      default:
        return CloudinaryDeliveryType.auto;
    }
  }
}
