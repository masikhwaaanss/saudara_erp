import 'package:saudara_erp/database/app_database.dart';
import 'package:saudara_erp/database/tables/audit_logs_table.dart';

class AuditLogsDao {
  final AppDatabase db;

  AuditLogsDao(this.db);

  /// Get audit log by ID
  Future<AuditLog?> getAuditLogById(int id) {
    return (db.select(db.auditLogs)..where((al) => al.id.equals(id))).getSingleOrNull();
  }

  /// Get all audit logs
  Future<List<AuditLog>> getAllAuditLogs() {
    return (db.select(db.auditLogs)
          ..orderBy([(al) => OrderingTerm(expression: al.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get audit logs for user
  Future<List<AuditLog>> getAuditLogsForUser(int userId) {
    return (db.select(db.auditLogs)
          ..where((al) => al.userId.equals(userId))
          ..orderBy([(al) => OrderingTerm(expression: al.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get audit logs for entity
  Future<List<AuditLog>> getAuditLogsForEntity(String entityType, int entityId) {
    return (db.select(db.auditLogs)
          ..where((al) => al.entityType.equals(entityType) & al.entityId.equals(entityId))
          ..orderBy([(al) => OrderingTerm(expression: al.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create audit log
  Future<int> createAuditLog(AuditLogsCompanion auditLog) {
    return db.into(db.auditLogs).insert(auditLog);
  }
}
