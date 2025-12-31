import '../core/result.dart';
import '../core/logger.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Repository for audit log operations (Super Admin only)
class AuditRepository {
  /// Get all audit logs with pagination
  Future<Result<List<AuditLog>>> getAuditLogs({
    AuditAction? action,
    String? hospitalId,
    String? actorId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseService.client.from('audit_logs').select();

      if (action != null) {
        query = query.eq('action', action.name);
      }
      if (hospitalId != null) {
        query = query.eq('hospital_id', hospitalId);
      }
      if (actorId != null) {
        query = query.eq('actor_id', actorId);
      }
      if (fromDate != null) {
        query = query.gte('timestamp', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('timestamp', toDate.toIso8601String());
      }

      final response = await query
          .order('timestamp', ascending: false)
          .range(offset, offset + limit - 1);

      final logs = (response as List)
          .map((json) => AuditLog.fromJson(json))
          .toList();

      return Success(logs);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch audit logs', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to load audit logs',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Create audit log entry
  Future<Result<AuditLog>> createAuditLog({
    required AuditAction action,
    required String actorId,
    required String actorName,
    String? hospitalId,
    String? hospitalName,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
    String? ipAddress,
  }) async {
    try {
      final logData = {
        'action': action.name,
        'actor_id': actorId,
        'actor_name': actorName,
        'hospital_id': hospitalId,
        'hospital_name': hospitalName,
        'target_id': targetId,
        'target_type': targetType,
        'metadata': metadata,
        'ip_address': ipAddress,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseService.client
          .from('audit_logs')
          .insert(logData)
          .select()
          .single();

      AppLogger.i('Audit log created: ${action.name}');
      return Success(AuditLog.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create audit log', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to create audit log',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get audit log by ID
  Future<Result<AuditLog>> getAuditLogById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('audit_logs')
          .select()
          .eq('id', id)
          .single();

      return Success(AuditLog.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch audit log: $id', e, stackTrace);
      return Failure(
        NotFoundException(
          'Audit log not found',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
