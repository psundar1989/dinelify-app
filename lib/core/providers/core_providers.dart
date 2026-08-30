import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../network/unauthorized_signal.dart';
import '../storage/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final unauthorizedSignalProvider = Provider<UnauthorizedSignal>((ref) => UnauthorizedSignal());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    storage: ref.watch(secureStorageProvider),
    onUnauthorized: () => ref.read(unauthorizedSignalProvider).fire(),
  );
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);
