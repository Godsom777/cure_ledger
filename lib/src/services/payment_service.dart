import '../core/result.dart';
import '../core/logger.dart';

/// Paystack payment service
/// Handles payment initialization and verification
class PaymentService {
  /// Initialize a payment transaction
  /// Returns a Paystack access code for the payment modal
  Future<Result<PaymentInitResponse>> initializePayment({
    required String email,
    required double amount,
    required String invoiceId,
    required String hospitalSubaccountCode,
    required String hospitalCode,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.i(
        'Initializing payment for invoice: $invoiceId, amount: $amount',
      );

      // Amount in kobo (Paystack uses smallest currency unit)
      final amountInKobo = (amount * 100).toInt();

      // Bank narration format: CURE-[HOSPITALCODE]-[INVOICEID]
      final reference =
          'CURE-$hospitalCode-$invoiceId-${DateTime.now().millisecondsSinceEpoch}';

      // TODO: Call backend API to initialize Paystack transaction
      // In production, this should be done via your backend for security
      // The backend would:
      // 1. Validate the invoice exists and amount matches
      // 2. Call Paystack initialize transaction API with split config
      // 3. Return the access code and authorization URL
      //
      // Example backend request:
      // POST /api/payments/initialize
      // { invoice_id, amount: amountInKobo, subaccount: hospitalSubaccountCode }

      AppLogger.d(
        'Payment reference: $reference, amount in kobo: $amountInKobo',
      );

      // For now, return placeholder that would come from backend
      return Success(
        PaymentInitResponse(
          accessCode: '', // Would come from Paystack
          reference: reference,
          authorizationUrl: '', // Would come from Paystack
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Payment initialization failed', e, stackTrace);
      return Failure(
        PaymentException(
          'Failed to initialize payment: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Verify payment transaction
  Future<Result<PaymentVerifyResponse>> verifyPayment(String reference) async {
    try {
      AppLogger.i('Verifying payment: $reference');

      // TODO: Call your backend to verify with Paystack
      // The backend would:
      // 1. Call Paystack verify transaction API
      // 2. Update invoice payment status in database
      // 3. Return verification result

      // Placeholder response
      return const Failure(
        PaymentException(
          'Payment verification requires backend integration',
          code: 'NOT_IMPLEMENTED',
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Payment verification failed', e, stackTrace);
      return Failure(
        PaymentException(
          'Failed to verify payment: ${e.toString()}',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Calculate payment split
  /// Returns (hospitalAmount, platformFee)
  (double, double) calculateSplit(
    double amount, {
    double platformFeePercent = 5.0,
  }) {
    final platformFee = amount * (platformFeePercent / 100);
    final hospitalAmount = amount - platformFee;
    return (hospitalAmount, platformFee);
  }
}

/// Payment initialization response
class PaymentInitResponse {
  final String accessCode;
  final String reference;
  final String authorizationUrl;

  const PaymentInitResponse({
    required this.accessCode,
    required this.reference,
    required this.authorizationUrl,
  });
}

/// Payment verification response
class PaymentVerifyResponse {
  final bool success;
  final String reference;
  final double amount;
  final String status;
  final DateTime paidAt;
  final String? channel;
  final String? bankNarration;

  const PaymentVerifyResponse({
    required this.success,
    required this.reference,
    required this.amount,
    required this.status,
    required this.paidAt,
    this.channel,
    this.bankNarration,
  });
}
