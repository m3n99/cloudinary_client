import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';

class CloudinaryUtils {
  static const List<String> _excludeKeys = [
    'resource_type',
    'unsigned',
    'filename',
    'cloud_name',
    'api_key',
    'file',
  ];

  String generateSignature({
    Map<String, dynamic>? params,
    required String apiSecret,
  }) {
    String? signature;
    try {
      final signatureParams = Map<String, dynamic>.from(params ?? {});

      signatureParams['timestamp'] =
          (DateTime.now().millisecondsSinceEpoch / 1000).round();

      signatureParams.removeWhere(
          (key, value) => value == null || _excludeKeys.contains(key));

      final paramsList = <String>[];
      signatureParams.forEach((key, value) {
        if (value != null) {
          paramsList.add(value is List
              ? '$key=${value.join(",")}'
              : '$key=$value');
        }
      });

      paramsList.sort();

      final paramsString = '${paramsList.join('&')}$apiSecret';
      final bytes = utf8.encode(paramsString.trim());
      signature = sha1.convert(bytes).toString();
    } catch (e) {
      log('Error generating signature: $e', name: 'CloudinaryUtils');
    }
    return signature ?? '';
  }
}
