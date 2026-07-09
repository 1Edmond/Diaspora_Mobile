// Mock Chat Data
import '../../features/chat/domain/entities/group.dart';
import '../../features/chat/domain/entities/bot.dart';
import '../../features/chat/domain/entities/call.dart';
import '../../core/constants/enums.dart'; // Ensure enums are imported

final mockGroups = <Group>[];
final mockBots = <Bot>[
  Bot(
    id: 'wel_01',
    name: 'Welcome Bot',
    type: BotType.WELCOME,
    permissions: ['SEND_MESSAGES'],
    isActive: true,
  ),
];
final mockCalls = <Call>[];
