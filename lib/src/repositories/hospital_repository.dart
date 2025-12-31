import '../core/result.dart';
import '../core/logger.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Repository for hospital data operations
class HospitalRepository {
  /// Get all hospitals
  Future<Result<List<Hospital>>> getHospitals() async {
    try {
      final response = await SupabaseService.client
          .from('hospitals')
          .select()
          .order('name');

      final hospitals = (response as List)
          .map((json) => Hospital.fromJson(json))
          .toList();

      return Success(hospitals);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch hospitals', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to load hospitals',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get hospital by ID
  Future<Result<Hospital>> getHospitalById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('hospitals')
          .select()
          .eq('id', id)
          .single();

      return Success(Hospital.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch hospital: $id', e, stackTrace);
      return Failure(
        NotFoundException(
          'Hospital not found',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Get hospital by code
  Future<Result<Hospital>> getHospitalByCode(String code) async {
    try {
      final response = await SupabaseService.client
          .from('hospitals')
          .select()
          .eq('code', code)
          .single();

      return Success(Hospital.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to fetch hospital by code: $code', e, stackTrace);
      return Failure(
        NotFoundException(
          'Hospital not found',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Create new hospital (Super Admin only)
  Future<Result<Hospital>> createHospital(Hospital hospital) async {
    try {
      final response = await SupabaseService.client
          .from('hospitals')
          .insert(hospital.toJson())
          .select()
          .single();

      AppLogger.i('Hospital created: ${hospital.code}');
      return Success(Hospital.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to create hospital', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to create hospital',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Update hospital status (Super Admin only)
  Future<Result<Hospital>> updateHospitalStatus(
    String id,
    HospitalStatus status, {
    String? reason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        if (status == HospitalStatus.suspended) ...{
          'suspended_at': DateTime.now().toIso8601String(),
          'suspension_reason': reason,
        },
      };

      final response = await SupabaseService.client
          .from('hospitals')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      AppLogger.i('Hospital status updated: $id -> ${status.name}');
      return Success(Hospital.fromJson(response));
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update hospital status', e, stackTrace);
      return Failure(
        NetworkException(
          'Failed to update hospital status',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
