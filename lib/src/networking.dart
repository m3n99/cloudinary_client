import 'package:dio/dio.dart';

class CloudinaryHttpClient {
  final Dio _dio;

  CloudinaryHttpClient({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          responseType: ResponseType.json,
        ));

  Future<Response> postMultipart(String path, Map<String, dynamic> data) {
    return _dio.post(
      path,
      data: FormData.fromMap(data),
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<Response> post(String path, Map<String, dynamic> data) {
    return _dio.post(path, data: data);
  }

  Future<Response> delete(String url, {Map<String, dynamic>? data}) {
    return _dio.delete(url, data: data);
  }
}
