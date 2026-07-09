enum UserType { BOURSIER, CONTRACTUEL }

enum ProfileStatus { PENDING, VALIDATED, REJECTED }

// Wallet Enums
enum TransactionType {
  RECEIVE,
  SEND,
  EXCHANGE,
  SCHOLARSHIP,
  SERVICE_PAYMENT,
  WITHDRAWAL,
}

enum TransactionStatus { PENDING, COMPLETED, FAILED, REFUNDED }

// Community Enums
enum PostType { TEXT, IMAGE, VIDEO, POLL, EVENT_SHARE }

enum EventType { MEETUP, WEBINAR, CELEBRATION, WORKSHOP }

enum MentorshipStatus { PENDING, ACTIVE, COMPLETED }

// Chat Enums
enum ConversationType { DIRECT, GROUP, CITY_GROUP }

enum MessageType { TEXT, IMAGE, VIDEO, AUDIO, DOCUMENT, LOCATION }

enum MessageStatus { SENDING, SENT, DELIVERED, READ, FAILED }

enum GroupType { REGULAR, CITY_AUTO, COMMITTEE }

enum BotType { WELCOME, MODERATION, NOTIFICATION, CUSTOM }

enum CallType { AUDIO, VIDEO }

enum CallStatus { RINGING, ONGOING, ENDED, MISSED }
