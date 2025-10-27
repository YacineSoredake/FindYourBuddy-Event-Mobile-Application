import 'package:dio/dio.dart';
import 'constants.dart';
import 'storage.dart';

class Api {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await Storage.getAccessToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
            onResponse: (response, handler) {
              return handler.next(response);
            },
            onError: (DioException e, handler) {
              if (e.response?.statusCode == 401) {
                print("⚠️ Unauthorized: Token may be expired");
              }
              return handler.next(e);
            },
          ),
        );
}
