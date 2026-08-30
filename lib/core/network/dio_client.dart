import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../constants/env.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

/// Builds the single Dio instance used for every API call: injects the
/// bearer token, unwraps the `{success,message,data}` / `{success,message,
/// errors}` envelope into [ApiException], and reports 401s so the caller
/// can clear the session and bounce to /home.
class DioClient {
  DioClient({required SecureStorageService storage, required void Function() onUnauthorized})
    : _storage = storage,
      _onUnauthorized = onUnauthorized {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.clear();
            _onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  final void Function() _onUnauthorized;
  late final Dio dio;
}

/// Unwraps `response.data` (already the decoded JSON envelope) into the
/// `data` payload, or throws [ApiException] built from the envelope /
/// DioException. Call this from every service method around its request.
Future<T> unwrap<T>(
  Future<Response<dynamic>> Function() request,
  T Function(dynamic data) onData,
) async {
  try {
    final response = await request();
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      return onData(body['data']);
    }
    throw ApiException(
      message: body['message'] as String? ?? 'Something went wrong',
      errors: body['errors'] as Map<String, dynamic>?,
      statusCode: response.statusCode,
    );
  } on DioException catch (e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final status = e.response?.statusCode;
      final serverMessage = data['message'] as String? ?? 'Something went wrong';
      throw ApiException(
        message: kDebugMode && status != null ? '[$status] $serverMessage' : serverMessage,
        errors: data['errors'] as Map<String, dynamic>?,
        statusCode: status,
      );
    }
    throw ApiException(message: _messageFor(e), statusCode: e.response?.statusCode);
  }
}

/// Maps a [DioException] that carried no parseable JSON body (connection
/// refused, timeout, CORS/network error, or a non-JSON 4xx/5xx) to a message.
/// In debug builds this includes the real exception type/detail instead of
/// the generic "could not connect" string, so the actual cause is visible
/// while developing (e.g. `10.0.2.2` unreachable from a browser, backend
/// down, or a blocked CORS preflight).
String _messageFor(DioException e) {
  final detail = e.error?.toString() ?? e.message ?? e.type.name;
  final status = e.response?.statusCode;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return kDebugMode
          ? 'Request timed out calling ${e.requestOptions.uri}. Detail: $detail'
          : 'The server took too long to respond. Please try again.';
    case DioExceptionType.connectionError:
      return kDebugMode
          ? 'Could not reach ${e.requestOptions.uri}. The server may be down, unreachable '
                'from this device/browser (e.g. 10.0.2.2 does not work from a web browser), '
                'or the request was blocked by CORS. Detail: $detail'
          : 'Could not connect to the server. Please check your internet connection.';
    case DioExceptionType.badResponse:
      if (status != null && status >= 500) {
        return kDebugMode ? 'Server error [$status] at ${e.requestOptions.uri}. Detail: $detail' : 'Something went wrong on our end. Please try again later.';
      }
      return kDebugMode ? 'Request error [$status] at ${e.requestOptions.uri}. Detail: $detail' : 'Something went wrong. Please try again.';
    case DioExceptionType.badCertificate:
      return kDebugMode ? 'Bad certificate for ${e.requestOptions.uri}. Detail: $detail' : 'A secure connection could not be established.';
    case DioExceptionType.cancel:
      return 'Request cancelled.';
    case DioExceptionType.unknown:
      return kDebugMode ? 'Network error calling ${e.requestOptions.uri}. Detail: $detail' : 'Something went wrong. Please try again.';
  }
}
