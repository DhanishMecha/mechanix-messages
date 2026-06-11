import 'dart:io';
import 'package:mechanix_messages/core/exceptions/app_exception.dart';
import 'package:mechanix_messages/core/utils/app_logger.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/objectbox.g.dart';

class ObjectBoxService {
  static Store? _store;
  static String? _dbDirectoryPath;

  Store get store => _store!;
  String? get dbDirectoryPath => _dbDirectoryPath;

  static Future<ObjectBoxService> init() async {
    final service = ObjectBoxService();
    await service.ensureStoreConnected();
    return service;
  }

  Future<void> ensureStoreConnected() async {
    if (_store != null && _store!.isClosed() == false) return;

    try {
      await _initializeStore();
    } catch (e) {
      AppLogger.e('Failed to open ObjectBox store: $e');
      if (e is FileSystemException && e.message.contains('lock failed')) {
        throw AppAlreadyRunningException();
      }
      rethrow;
    }
  }

  Future<void> _initializeStore() async {
    try {
      final home = Platform.environment['HOME'];
      final appDir = Directory('$home/${Constants.dbPath}');
      final exists = await appDir.exists();

      if (!exists) {
        await appDir.create(recursive: true);
      }

      _store = openStore(directory: appDir.path);
      _dbDirectoryPath = appDir.path;

      AppLogger.i(
        '[ObjectBoxService] ObjectBox store opened at ${appDir.path}',
      );
    } catch (e) {
      AppLogger.e('Failed to initialize ObjectBox store: $e');
      rethrow;
    }
  }
}
