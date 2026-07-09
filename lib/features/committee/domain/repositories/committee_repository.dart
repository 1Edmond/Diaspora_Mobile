import '../entities/committee.dart';
import '../entities/committee_member.dart';
import '../entities/meeting.dart';
import '../entities/proposal.dart';

abstract class ICommitteeRepository {
  Future<List<Committee>> getCommittees();
  Future<Committee?> getCommitteeById(String id);
  Future<List<CommitteeMember>> getCommitteeMembers(String committeeId);
  Future<List<Meeting>> getMeetings(String committeeId);
  Future<List<Proposal>> getProposals(String committeeId);
  Future<Meeting?> getMeetingById(String id);
  Future<Proposal?> getProposalById(String id);
  Future<void> createProposal(
    String committeeId,
    String title,
    String description,
  );
  Future<void> voteOnProposal(String proposalId, String vote);
}
