enum CloudinaryBaseUrlType {
  eu('https://api-eu.cloudinary.com/v1_1/'),
  ap('https://api-ap.cloudinary.com/v1_1/'),
  def('https://api.cloudinary.com/v1_1/');

  const CloudinaryBaseUrlType(this.value);
  final String value;
}

extension CloudinaryBaseUrlTypeX on String? {
  CloudinaryBaseUrlType toCloudinaryBaseUrlType() {
    switch (this?.toLowerCase()) {
      case 'eu':
        return CloudinaryBaseUrlType.eu;
      case 'ap':
        return CloudinaryBaseUrlType.ap;
      default:
        return CloudinaryBaseUrlType.def;
    }
  }
}
