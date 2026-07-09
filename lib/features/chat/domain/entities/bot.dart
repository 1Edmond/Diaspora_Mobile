import 'package:diaspora_app/core/constants/enums.dart';

class Bot {
  final String id;
  final String name;
  final BotType type;
  final List<String> permissions; // READ_MESSAGES, SEND_MESSAGES, etc.
  final bool isActive;

  Bot({
    required this.id,
    required this.name,
    required this.type,
    required this.permissions,
    required this.isActive,
  });
}
