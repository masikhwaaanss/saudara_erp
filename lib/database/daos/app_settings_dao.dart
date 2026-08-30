import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/app_settings_table.dart';

class SettingsDao {
  final AppDatabase db;

  SettingsDao(this.db);

  /// Get setting by key
  Future<AppSetting?> getSettingByKey(String key) {
    return (db.select(db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
  }

  /// Get all settings
  Future<List<AppSetting>> getAllSettings() {
    return db.select(db.appSettings).get();
  }

  /// Update or create setting
  Future<void> upsertSetting(String key, String value, [String? description]) async {
    final existing = await getSettingByKey(key);
    if (existing != null) {
      await (db.update(db.appSettings)..where((s) => s.key.equals(key)))
          .write(AppSettingsCompanion(
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ));
    } else {
      await db.into(db.appSettings).insert(AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
        description: Value(description),
      ));
    }
  }

  /// Get setting value as string
  Future<String> getStringValue(String key, [String defaultValue = '']) async {
    final setting = await getSettingByKey(key);
    return setting?.value ?? defaultValue;
  }

  /// Get setting value as int
  Future<int> getIntValue(String key, [int defaultValue = 0]) async {
    final setting = await getSettingByKey(key);
    return int.tryParse(setting?.value ?? '') ?? defaultValue;
  }

  /// Get setting value as bool
  Future<bool> getBoolValue(String key, [bool defaultValue = false]) async {
    final setting = await getSettingByKey(key);
    return setting?.value?.toLowerCase() == 'true' ? true : defaultValue;
  }
}
