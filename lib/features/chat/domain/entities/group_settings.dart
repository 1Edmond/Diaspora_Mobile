class GroupSettings {
  final bool canMemberPost;
  final bool canMemberAdd;
  final bool isPublic;
  final bool isMuted;

  GroupSettings({
    this.canMemberPost = true,
    this.canMemberAdd = false,
    this.isPublic = false,
    this.isMuted = false,
  });
}
