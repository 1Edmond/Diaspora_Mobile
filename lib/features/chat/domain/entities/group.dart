import 'package:diaspora_app/core/constants/enums.dart';
import 'bot.dart';
import 'group_settings.dart';

class Group {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final GroupType type;
  final List<String> admins;
  final List<String> members;
  final List<Bot> bots;
  final GroupSettings settings;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    required this.type,
    required this.admins,
    required this.members,
    this.bots = const [],
    required this.settings,
    required this.createdAt,
  });
}
