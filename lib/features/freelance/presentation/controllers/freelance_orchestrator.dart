import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/repositories/freelance_repository.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/job_application_model.dart';
import '../../domain/entities/enums.dart';

/// Coordinates the cross-service flows the Freelance backend expects the
/// mobile app to orchestrate in a strict order (§4 of the plan):
///   - accept with escrow hold (escrowUpfront)
///   - complete with release/pay
///   - chat-thread linking
/// These are NOT simple isolated API calls — order matters.
class FreelanceOrchestrator {
  final IFreelanceRepository _freelance;
  final IWalletRepository _wallet;
  final IChatRepository _chat;

  FreelanceOrchestrator({
    required IFreelanceRepository freelance,
    required IWalletRepository wallet,
    required IChatRepository chat,
  })  : _freelance = freelance,
        _wallet = wallet,
        _chat = chat;

  /// §4.1 — Accept an application, holding escrow first when the associated
  /// posting uses `escrowUpfront`. Returns [true] on success; throws on any
  /// step failure (insufficient balance aborts BEFORE accept).
  Future<void> acceptApplication({
    required JobPostingModel posting,
    required JobApplicationModel application,
  }) async {
    String? escrowTransactionId;
    if (posting.paymentTiming == PaymentTiming.escrowUpfront) {
      escrowTransactionId = await _wallet.freelanceHold(
        employerExternalProfileId: posting.employerId,
        jobApplicationId: application.id,
        amount: posting.amount,
        description: posting.title,
      );
    }
    await _freelance.acceptApplication(
      application.id,
      escrowTransactionId: escrowTransactionId,
    );
  }

  /// §4.2 — Complete an application, then release or pay the funds.
  Future<void> completeApplication({
    required JobPostingModel posting,
    required JobApplicationModel application,
  }) async {
    await _freelance.completeApplication(application.id);

    if (posting.paymentTiming == PaymentTiming.escrowUpfront) {
      await _wallet.freelanceRelease(
        employerExternalProfileId: posting.employerId,
        workerExternalProfileId: application.workerId,
        jobApplicationId: application.id,
        amount: posting.amount,
        description: posting.title,
      );
    } else {
      await _wallet.freelancePay(
        employerExternalProfileId: posting.employerId,
        workerExternalProfileId: application.workerId,
        jobApplicationId: application.id,
        amount: posting.amount,
        description: posting.title,
      );
    }
  }

  /// §4.3 — Refund escrow for an accepted application that is withdrawn or
  /// whose posting is cancelled. Only meaningful when an escrow was held.
  Future<void> refundEscrow({
    required JobPostingModel posting,
    required JobApplicationModel application,
  }) async {
    if (application.escrowTransactionId == null) return;
    await _wallet.freelanceRefund(
      employerExternalProfileId: posting.employerId,
      jobApplicationId: application.id,
      amount: posting.amount,
      description: posting.title,
    );
  }

  /// §4.4 — Ensure a direct chat thread exists between employer & worker,
  /// link it on the application, and return the conversation id for
  /// navigation.
  Future<String> linkChatThread({
    required JobPostingModel posting,
    required JobApplicationModel application,
  }) async {
    if (application.chatThreadId != null &&
        application.chatThreadId!.isNotEmpty) {
      return application.chatThreadId!;
    }

    final employerChatId =
        await _chat.resolveChatProfileByExternal(posting.employerId);
    final workerChatId =
        await _chat.resolveChatProfileByExternal(application.workerId);
    final conversation =
        await _chat.createDirectConversation(employerChatId, workerChatId);
    await _freelance.linkApplicationChatThread(application.id, conversation.id);
    return conversation.id;
  }
}

final freelanceOrchestratorProvider = Provider<FreelanceOrchestrator>((ref) {
  return FreelanceOrchestrator(
    freelance: GetIt.instance<IFreelanceRepository>(),
    wallet: GetIt.instance<IWalletRepository>(),
    chat: GetIt.instance<IChatRepository>(),
  );
});