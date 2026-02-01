import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/encryption_service.dart';
import '../../infrastructure/services/encryption_service_impl.dart';

part 'encryption_providers.g.dart';

@riverpod
EncryptionService encryptionService(Ref ref) {
  return EncryptionServiceImpl();
}
