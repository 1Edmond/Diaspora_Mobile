import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/committee.dart';
import '../../domain/entities/committee_member.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/committee_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/realtime/mock_realtime_service.dart';
import 'dart:async';

final committeesProvider =
    StateNotifierProvider<CommitteesNotifier, AsyncValue<List<Committee>>>((
      ref,
    ) {
      return CommitteesNotifier(getIt<ICommitteeRepository>());
    });

final committeeMembersProvider = StateNotifierProvider.family<
  CommitteeMembersNotifier,
  AsyncValue<List<CommitteeMember>>,
  String
>((ref, committeeId) {
  return CommitteeMembersNotifier(getIt<ICommitteeRepository>(), committeeId);
});

final committeeMeetingsProvider = StateNotifierProvider.family<
  CommitteeMeetingsNotifier,
  AsyncValue<List<Meeting>>,
  String
>((ref, committeeId) {
  return CommitteeMeetingsNotifier(getIt<ICommitteeRepository>(), committeeId);
});

final committeeProposalsProvider = StateNotifierProvider.family<
  CommitteeProposalsNotifier,
  AsyncValue<List<Proposal>>,
  String
>((ref, committeeId) {
  return CommitteeProposalsNotifier(
    getIt<ICommitteeRepository>(),
    committeeId,
    getIt<MockRealtimeService>(),
  );
});

class CommitteesNotifier extends StateNotifier<AsyncValue<List<Committee>>> {
  final ICommitteeRepository repository;
  CommitteesNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchCommittees();
  }

  Future<void> fetchCommittees() async {
    state = const AsyncValue.loading();
    try {
      final committees = await repository.getCommittees();
      state = AsyncValue.data(committees);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class CommitteeMembersNotifier
    extends StateNotifier<AsyncValue<List<CommitteeMember>>> {
  final ICommitteeRepository repository;
  final String committeeId;
  CommitteeMembersNotifier(this.repository, this.committeeId)
    : super(const AsyncValue.loading()) {
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    state = const AsyncValue.loading();
    try {
      final members = await repository.getCommitteeMembers(committeeId);
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class CommitteeMeetingsNotifier
    extends StateNotifier<AsyncValue<List<Meeting>>> {
  final ICommitteeRepository repository;
  final String committeeId;
  CommitteeMeetingsNotifier(this.repository, this.committeeId)
    : super(const AsyncValue.loading()) {
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    state = const AsyncValue.loading();
    try {
      final meetings = await repository.getMeetings(committeeId);
      state = AsyncValue.data(meetings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class CommitteeProposalsNotifier
    extends StateNotifier<AsyncValue<List<Proposal>>> {
  final ICommitteeRepository repository;
  final String committeeId;
  final MockRealtimeService _realtime;
  StreamSubscription<Map<String, dynamic>>? _committeeSub;
  CommitteeProposalsNotifier(this.repository, this.committeeId, this._realtime)
    : super(const AsyncValue.loading()) {
    _committeeSub = _realtime.committeeEvents.listen((payload) {
      final event = payload['event'] as String? ?? '';
      if (event == 'proposal_created') {
        final cId = payload['committeeId']?.toString();
        if (cId == committeeId) {
          final proposal = Proposal(
            id:
                payload['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            committeeId: committeeId,
            title: payload['title']?.toString() ?? '',
            description: payload['description']?.toString() ?? '',
            proposerId: payload['proposerId']?.toString() ?? 'unknown',
            submittedAt: DateTime.now(),
            status: payload['status']?.toString() ?? 'PENDING',
            votes: [],
          );

          state = state.maybeWhen(
            data: (proposals) => AsyncValue.data([proposal, ...proposals]),
            orElse: () => AsyncValue.data([proposal]),
          );
        }
      } else if (event == 'vote_updated') {
        final proposalId = payload['proposalId']?.toString();
        if (proposalId != null) {
          state = state.maybeWhen(
            data:
                (proposals) => AsyncValue.data(
                  proposals.map((p) {
                    if (p.id == proposalId) {
                      // For simplicity, do a refresh of proposals later; here we update status if provided
                      return Proposal(
                        id: p.id,
                        committeeId: p.committeeId,
                        title: p.title,
                        description: p.description,
                        proposerId: p.proposerId,
                        submittedAt: p.submittedAt,
                        status: payload['status']?.toString() ?? p.status,
                        votes: p.votes,
                        decision: p.decision,
                        decidedAt: p.decidedAt,
                      );
                    }
                    return p;
                  }).toList(),
                ),
            orElse: () => state,
          );
        }
      }
    });

    fetchProposals();
  }

  @override
  void dispose() {
    _committeeSub?.cancel();
    super.dispose();
  }

  Future<void> fetchProposals() async {
    state = const AsyncValue.loading();
    try {
      final proposals = await repository.getProposals(committeeId);
      state = AsyncValue.data(proposals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProposal(String title, String description) async {
    try {
      await repository.createProposal(committeeId, title, description);
      // Refresh proposals after creating
      await fetchProposals();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> voteOnProposal(String proposalId, String vote) async {
    try {
      await repository.voteOnProposal(proposalId, vote);
      // Refresh proposals after voting
      await fetchProposals();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
