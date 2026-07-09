import '../../domain/repositories/committee_repository.dart';
import '../../domain/entities/committee.dart';
import '../../domain/entities/committee_member.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/proposal.dart';
import '../models/committee_model.dart';
import '../models/committee_member_model.dart';
import '../models/meeting_model.dart';
import '../models/proposal_model.dart';
import '../../../../core/network/dio_client.dart';

class CommitteeRepositoryImpl implements ICommitteeRepository {
  final DioClient _client;
  CommitteeRepositoryImpl({DioClient? client})
    : _client = client ?? DioClient();

  @override
  Future<List<Committee>> getCommittees() async {
    final res = await _client.get<List<dynamic>>('/committees');
    return res
        .map((e) => CommitteeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Committee?> getCommitteeById(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/committees/$id');
      return CommitteeModel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CommitteeMember>> getCommitteeMembers(String committeeId) async {
    final res = await _client.get<List<dynamic>>(
      '/committees/$committeeId/members',
    );
    return res
        .map((e) => CommitteeMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Meeting>> getMeetings(String committeeId) async {
    final res = await _client.get<List<dynamic>>(
      '/committees/$committeeId/meetings',
    );
    return res
        .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Proposal>> getProposals(String committeeId) async {
    final res = await _client.get<List<dynamic>>(
      '/committees/$committeeId/proposals',
    );
    return res
        .map((e) => ProposalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Meeting?> getMeetingById(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/meetings/$id');
      return MeetingModel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Proposal?> getProposalById(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/proposals/$id');
      return ProposalModel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createProposal(
    String committeeId,
    String title,
    String description,
  ) async {
    await _client.post(
      '/committees/$committeeId/proposals',
      data: {'title': title, 'description': description},
    );
  }

  @override
  Future<void> voteOnProposal(String proposalId, String vote) async {
    await _client.post('/proposals/$proposalId/vote', data: {'vote': vote});
  }
}
