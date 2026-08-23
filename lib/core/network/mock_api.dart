// In-app mock API used by repository implementations. Returns canned responses with artificial delay.
import 'dart:async';

class MockApi {
  static Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String userType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'userId': 'user_${phone.substring(phone.length - 4)}',
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'userType': userType,
      'status': 'pending',
    };
  }

  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // accept any password for mocked user
    return {
      'accessToken': 'mock_access_token',
      'refreshToken': 'mock_refresh',
      'user': {
        'id': 'u_${phone.substring(phone.length - 4)}',
        'name': 'Utilisateur Test',
        'phone': phone,
        'userType': 'BOURSIER',
        'status': 'validated',
      },
    };
  }

  static Future<Map<String, dynamic>> procedures({
    int page = 1,
    int pageSize = 20,
    String? profileType,
    String? profileTypeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final allProcedures = <Map<String, dynamic>>[
      {
        'id': 'proc_1',
        'title': 'Enregistrement universitaire',
        'description': 'Procédure d\'inscription à l\'université hôte',
        'costAmount': 15000,
        'costCurrency': 'XOF',
        'profileType': 'External',
        'profileTypeId': 'ptype_external',
        'estimatedDurationDays': 7,
        'isActive': true,
        'locations': [
          {
            'id': 'loc_1_1',
            'name': 'Université de Lomé - Bureau des admissions',
            'street': 'Avenue de la Paix',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP1515',
            'country': 'TG',
            'latitude': 6.1725,
            'longitude': 1.2312,
            'phoneNumber': '+228 22 21 35 00',
            'website': 'https://univ-lome.tg',
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:00:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:00:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:00:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:00:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '12:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
          {
            'id': 'loc_1_2',
            'name': 'Cité Universitaire - Bâtiment A',
            'street': 'Rue de la Cité',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP1010',
            'country': 'TG',
            'latitude': 6.1783,
            'longitude': 1.2245,
            'phoneNumber': '+228 90 12 34 56',
            'website': null,
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '15:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
        ],
        'dependencyIds': <String>[],
        'requiredDocumentTypeIds': <String>[
          'doc_passport',
          'doc_diploma',
          'doc_transcript',
        ],
        'createdAt': '2026-09-01T00:00:00Z',
      },
      {
        'id': 'proc_2',
        'title': 'Renouvellement de titre de séjour',
        'description': 'Renouvellement du titre de séjour auprès des autorités locales',
        'costAmount': 5000,
        'costCurrency': 'XOF',
        'profileType': 'External',
        'profileTypeId': 'ptype_external',
        'estimatedDurationDays': 30,
        'isActive': true,
        'locations': [
          {
            'id': 'loc_2_1',
            'name': 'Préfecture de Lomé',
            'street': 'Boulevard du 13 Janvier',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP0001',
            'country': 'TG',
            'latitude': 6.1319,
            'longitude': 1.2227,
            'phoneNumber': '+228 22 21 00 01',
            'website': 'https://prefecture.gouv.tg',
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '07:30:00',
                'closeTime': '15:30:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '07:30:00',
                'closeTime': '15:30:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '07:30:00',
                'closeTime': '15:30:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '07:30:00',
                'closeTime': '15:30:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '07:30:00',
                'closeTime': '14:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
        ],
        'dependencyIds': <String>['proc_1'],
        'requiredDocumentTypeIds': <String>[
          'doc_passport',
          'doc_visa',
          'doc_residence_permit',
          'doc_bank_document',
        ],
        'createdAt': '2026-07-01T00:00:00Z',
      },
      {
        'id': 'proc_3',
        'title': 'Ouverture de compte bancaire',
        'description': 'Ouverture d\'un compte bancaire local pour les étudiants étrangers',
        'costAmount': 0,
        'costCurrency': 'XOF',
        'profileType': 'Internal',
        'profileTypeId': 'ptype_internal',
        'estimatedDurationDays': 3,
        'isActive': true,
        'locations': [
          {
            'id': 'loc_3_1',
            'name': 'Ecobank - Agence Centrale',
            'street': 'Avenue du Général de Gaulle',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP1280',
            'country': 'TG',
            'latitude': 6.1284,
            'longitude': 1.2195,
            'phoneNumber': '+228 22 21 72 14',
            'website': 'https://ecobank.com/tg',
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '17:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': false,
                'openTime': '09:00:00',
                'closeTime': '13:00:00',
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
          {
            'id': 'loc_3_2',
            'name': 'Orabank - Agence Université',
            'street': 'Rue de l\'Université',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP1515',
            'country': 'TG',
            'latitude': 6.1750,
            'longitude': 1.2290,
            'phoneNumber': '+228 22 21 80 00',
            'website': null,
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '08:00:00',
                'closeTime': '15:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
        ],
        'dependencyIds': <String>['proc_1'],
        'requiredDocumentTypeIds': <String>[
          'doc_passport',
          'doc_student_card',
          'doc_bank_document',
        ],
        'createdAt': '2026-08-15T00:00:00Z',
      },
      {
        'id': 'proc_4',
        'title': 'Demande de bourse d\'études',
        'description': 'Demande de bourse auprès de l\'ambassade pour l\'année universitaire en cours',
        'costAmount': 2500,
        'costCurrency': 'XOF',
        'profileType': 'External',
        'profileTypeId': 'ptype_external',
        'estimatedDurationDays': 45,
        'isActive': true,
        'locations': [
          {
            'id': 'loc_4_1',
            'name': 'Ambassade de France - Service culturel',
            'street': 'Avenue de la Libération',
            'city': 'Lomé',
            'state': 'Maritime',
            'postalCode': '01BP0002',
            'country': 'TG',
            'latitude': 6.1297,
            'longitude': 1.2181,
            'phoneNumber': '+228 22 23 46 00',
            'website': 'https://tg.ambafrance.org',
            'schedule': [
              {
                'day': 'Monday',
                'isClosed': false,
                'openTime': '08:30:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Tuesday',
                'isClosed': false,
                'openTime': '08:30:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Wednesday',
                'isClosed': false,
                'openTime': '08:30:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Thursday',
                'isClosed': false,
                'openTime': '08:30:00',
                'closeTime': '16:30:00',
              },
              {
                'day': 'Friday',
                'isClosed': false,
                'openTime': '08:30:00',
                'closeTime': '13:00:00',
              },
              {
                'day': 'Saturday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
              {
                'day': 'Sunday',
                'isClosed': true,
                'openTime': null,
                'closeTime': null,
              },
            ],
          },
        ],
        'dependencyIds': <String>['proc_1', 'proc_2', 'proc_3'],
        'requiredDocumentTypeIds': <String>[
          'doc_passport',
          'doc_diploma',
          'doc_transcript',
          'doc_insurance',
          'doc_bank_document',
        ],
        'createdAt': '2026-08-01T00:00:00Z',
      },
    ];

    var filtered = <Map<String, dynamic>>[];
    for (final p in allProcedures) {
      if (profileType != null && p['profileType'] != profileType) continue;
      if (profileTypeId != null && p['profileTypeId'] != profileTypeId) continue;
      filtered.add(p);
    }

    final totalCount = filtered.length;
    final totalPages = (totalCount / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final items = start < filtered.length
        ? filtered.sublist(start, end > filtered.length ? filtered.length : end)
        : <Map<String, dynamic>>[];

    return {
      'items': items,
      'pageNumber': page,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasPrevious': page > 1,
      'hasNext': page < totalPages,
    };
  }

  // Services (marketplace) - mocked
  // This mock keeps a tiny in-memory store for created services so that
  // create -> detail -> approve flows are consistent (tests relied on
  // the created item remaining in PENDING until approved).
  static final Map<String, Map<String, dynamic>> _createdServices = {};

  static Future<List<Map<String, dynamic>>> services({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final now = DateTime.now().toIso8601String();

    // base catalog
    final base = [
      {
        'id': 'svc_1',
        'providerId': 'prov_1',
        'title': 'Cours de français particulier',
        'description': 'Cours intensifs pour améliorer le français quotidien',
        'price': 5000,
        'currency': 'XOF',
        'priceType': 'PER_HOUR',
        'images': ['https://placekitten.com/400/200'],
        'scope': 'CITY_ONLY',
        'allowedDepartments': null,
        'rating': 4.8,
        'reviewCount': 21,
        'status': 'ACTIVE',
        'createdAt': now,
      },
      {
        'id': 'svc_2',
        'providerId': 'prov_2',
        'title': 'Aide administrative (documents)',
        'description': 'Assistance pour constituer des dossiers administratifs',
        'price': 0,
        'currency': 'XOF',
        'priceType': 'NEGOTIABLE',
        'images': [],
        'scope': 'COUNTRY_WIDE',
        'allowedDepartments': ['Lome', 'Sokode'],
        'rating': 4.2,
        'reviewCount': 8,
        'status': 'ACTIVE',
        'createdAt': now,
      },
    ];

    // append any recently-created (in-memory) services so tests see them
    final created = _createdServices.values.toList();
    return [...created, ...base];
  }

  static Future<Map<String, dynamic>> serviceDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // return from in-memory store if it exists (preserve status like PENDING)
    if (_createdServices.containsKey(id)) {
      return Map<String, dynamic>.from(_createdServices[id]!);
    }

    // simple deterministic detail based on id for catalog items
    return {
      'id': id,
      'providerId': 'prov_${id.split('_').last}',
      'title': 'Détail du service $id',
      'description': 'Description complète pour le service $id',
      'price': 7500,
      'currency': 'XOF',
      'priceType': 'FIXED',
      'images': [],
      'scope': 'CITY_ONLY',
      'allowedDepartments': null,
      'rating': 4.5,
      'reviewCount': 3,
      'status': 'ACTIVE',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> createService(
    Map<String, dynamic> payload,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = 'svc_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final entry = {
      'id': id,
      ...payload,
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _createdServices[id] = Map<String, dynamic>.from(entry);
    return Map<String, dynamic>.from(entry);
  }

  // Wallet mocks
  static Future<Map<String, dynamic>> walletBalance(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'userId': userId,
      'balances': {'XOF': 120000.0, 'EUR': 45.5},
    };
  }

  static Future<List<Map<String, dynamic>>> walletTransactions(
    String userId, {
    int page = 1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now().toIso8601String();
    return [
      {
        'id': 'tx_1',
        'userId': userId,
        'amount': -5000,
        'currency': 'XOF',
        'type': 'PAYMENT',
        'description': 'Paiement service administratif',
        'createdAt': now,
      },
      {
        'id': 'tx_2',
        'userId': userId,
        'amount': 20000,
        'currency': 'XOF',
        'type': 'RECEIPT',
        'description': 'Virement reçu',
        'createdAt': now,
      },
    ];
  }

  static Future<Map<String, dynamic>> walletTransfer(
    Map<String, dynamic> payload,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch % 100000}',
      ...payload,
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Approve or reject a service (admin flow)
  static Future<Map<String, dynamic>> approveService(
    String id,
    bool approved, [
    String? reason,
  ]) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // update in-memory entry when possible so subsequent detail/fetch
    // calls reflect the approved state (important for notifier tests)
    if (_createdServices.containsKey(id)) {
      _createdServices[id] = {
        ..._createdServices[id]!,
        'status': approved ? 'APPROVED' : 'REJECTED',
        'updatedAt': DateTime.now().toIso8601String(),
      };
      return Map<String, dynamic>.from(_createdServices[id]!);
    }

    return {
      'id': id,
      'approved': approved,
      'reason': reason,
      'status': approved ? 'APPROVED' : 'REJECTED',
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Simple notifications endpoint (dev): returns a page of notifications for a target
  static Future<List<Map<String, dynamic>>> notifications({
    required String target,
    int page = 1,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now().toIso8601String();
    return List.generate(
      3,
      (i) => {
        'id': 'notif_${target}_ ${page}_$i',
        'target': target,
        'title': 'Notification #${(page - 1) * 3 + i + 1}',
        'body': 'Message pour $target - item ${i + 1}',
        'meta': {'page': page},
        'read': false,
        'createdAt': now,
      },
    );
  }

  // Chat conversations
  static Future<List<Map<String, dynamic>>> conversations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      {
        'id': 'conv_1',
        'type': 'group',
        'title': 'Groupe Famille',
        'lastMessage': 'Comment ça va tout le monde?',
        'lastMessageTime':
            now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'unreadCount': 2,
        'participants': ['user_1', 'user_2', 'user_3'],
        'avatarUrl': null,
        'groupMembers': [
          {'id': 'user_1', 'name': 'Moi', 'role': 'Admin'},
          {'id': 'user_2', 'name': 'Maman', 'role': 'Membre'},
          {'id': 'user_3', 'name': 'Papa', 'role': 'Membre'},
        ],
      },
      {
        'id': 'conv_2',
        'type': 'direct',
        'title': 'Marie Dupont',
        'lastMessage': 'Merci pour l\'aide!',
        'lastMessageTime':
            now.subtract(const Duration(hours: 2)).toIso8601String(),
        'unreadCount': 0,
        'participants': ['user_1', 'user_4'],
        'avatarUrl': 'https://placekitten.com/100/100',
      },
      {
        'id': 'conv_3',
        'type': 'group',
        'title': 'Groupe Étudiants',
        'lastMessage': 'Réunion demain à 14h',
        'lastMessageTime':
            now.subtract(const Duration(days: 1)).toIso8601String(),
        'unreadCount': 1,
        'participants': ['user_1', 'user_5', 'user_6', 'user_7'],
        'avatarUrl': null,
        'groupMembers': [
          {'id': 'user_1', 'name': 'Moi', 'role': 'Admin'},
          {'id': 'user_5', 'name': 'Aminata', 'role': 'Membre'},
          {'id': 'user_6', 'name': 'Kossi', 'role': 'Membre'},
          {'id': 'user_7', 'name': 'Efua', 'role': 'Membre'},
        ],
      },
    ];
  }

  // Chat messages for a conversation
  static Future<List<Map<String, dynamic>>> messages(
    String conversationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    switch (conversationId) {
      case 'conv_1':
        return [
          {
            'id': 'msg_1',
            'conversationId': 'conv_1',
            'senderId': 'user_2',
            'senderName': 'Maman',
            'content': 'Bonne nuit mon fils ! Fais de beaux rêves 🌙',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 10)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_2',
            'conversationId': 'conv_1',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Merci maman, je vais me coucher',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 10)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_3',
            'conversationId': 'conv_1',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Oui tout va bien ! Je viens de finir le boulot',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 35)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_4',
            'conversationId': 'conv_1',
            'senderId': 'user_3',
            'senderName': 'Papa',
            'content': 'Comment ça va tout le monde?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 30)).toIso8601String(),
            'status': 'DELIVERED',
            'isRead': false,
          },
          {
            'id': 'msg_5',
            'conversationId': 'conv_1',
            'senderId': 'user_2',
            'senderName': 'Maman',
            'content': 'Tout va bien mon cher !',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 25)).toIso8601String(),
            'status': 'DELIVERED',
            'isRead': false,
          },
          {
            'id': 'msg_6',
            'conversationId': 'conv_1',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Ça va papa ! Et toi ?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
            'status': 'SENT',
            'isRead': false,
          },
        ];
      case 'conv_2':
        return [
          {
            'id': 'msg_7',
            'conversationId': 'conv_2',
            'senderId': 'user_4',
            'senderName': 'Marie Dupont',
            'content': 'Bonjour! J\'ai besoin d\'aide pour mes papiers',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_8',
            'conversationId': 'conv_2',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Bien sûr, je peux t\'aider. Quels documents?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 150)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_9',
            'conversationId': 'conv_2',
            'senderId': 'user_4',
            'senderName': 'Marie Dupont',
            'content': 'Il me faut mon passeport et mon visa. Je dois renouveler mon titre de séjour.',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 155)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_10',
            'conversationId': 'conv_2',
            'senderId': 'user_4',
            'senderName': 'Marie Dupont',
            'content': 'Tu connais un bon traducteur pour les documents ?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 90)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_11',
            'conversationId': 'conv_2',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Oui je connais quelqu\'un de fiable ! Je t\'envoie son contact',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 95)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_12',
            'conversationId': 'conv_2',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Je te conseille Ahmed, il est situé à Paris 13e et ses tarifs sont raisonnables',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 100)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_13',
            'conversationId': 'conv_2',
            'senderId': 'user_4',
            'senderName': 'Marie Dupont',
            'content': 'Super merci beaucoup! 😊',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 105)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_14',
            'conversationId': 'conv_2',
            'senderId': 'user_4',
            'senderName': 'Marie Dupont',
            'content': 'Je lui ai écrit, rdv pris pour demain ! Merci pour l\'aide!',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_15',
            'conversationId': 'conv_2',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Parfait ! Tiens-moi au courant 😊',
            'type': 'text',
            'timestamp': now.subtract(const Duration(minutes: 5)).toIso8601String(),
            'status': 'DELIVERED',
            'isRead': true,
          },
        ];
      case 'conv_3':
        return [
          {
            'id': 'msg_16',
            'conversationId': 'conv_3',
            'senderId': 'user_5',
            'senderName': 'Jean',
            'content': 'Salut à tous! Préparez vos présentations pour demain',
            'type': 'text',
            'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_17',
            'conversationId': 'conv_3',
            'senderId': 'user_6',
            'senderName': 'Sarah',
            'content': 'OK merci Jean ! J\'ai presque fini la mienne',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 19)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_18',
            'conversationId': 'conv_3',
            'senderId': 'user_7',
            'senderName': 'Kofi',
            'content': 'Est-ce qu\'on peut faire une visio avant pour répéter?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 20)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_19',
            'conversationId': 'conv_3',
            'senderId': 'user_5',
            'senderName': 'Jean',
            'content': 'Bonne idée ! 13h ça vous va?',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 21)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_20',
            'conversationId': 'conv_3',
            'senderId': 'user_1',
            'senderName': 'Vous',
            'content': 'Parfait pour moi aussi !',
            'type': 'text',
            'timestamp': now.subtract(const Duration(hours: 22)).toIso8601String(),
            'status': 'READ',
            'isRead': true,
          },
          {
            'id': 'msg_21',
            'conversationId': 'conv_3',
            'senderId': 'user_5',
            'senderName': 'Jean',
            'content': 'Réunion demain à 14h en salle 103',
            'type': 'text',
            'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
            'status': 'DELIVERED',
            'isRead': false,
          },
        ];
      default:
        return [];
    }
  }

  // Send message
  static Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'conversationId': conversationId,
      'senderId': 'user_1',
      'senderName': 'Vous',
      'content': data['content'],
      'type': data['type'] ?? 'text',
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sent',
      'isRead': false,
      'mediaUrl': data['mediaUrl'],
      'duration': data['duration'],
    };
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real app, this would update the database
  }

  // Community posts
  static Future<List<Map<String, dynamic>>> communityPosts({
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();

    return [
      {
        'id': 'post_1',
        'authorId': 'user_1',
        'authorName': 'Alice Dupont',
        'authorAvatar': 'https://placekitten.com/100/100',
        'title': 'Besoin d\'aide pour l\'inscription universitaire',
        'content':
            'Bonjour à tous ! Je suis nouvelle étudiante et j\'ai du mal à comprendre la procédure d\'inscription. Quelqu\'un peut m\'expliquer les étapes ? Merci d\'avance !',
        'images': [],
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updatedAt': null,
        'likesCount': 12,
        'commentsCount': 8,
        'isLiked': false,
        'type': 1, // PostType.question
      },
      {
        'id': 'post_2',
        'authorId': 'user_2',
        'authorName': 'Jean-Baptiste Koffi',
        'authorAvatar': null,
        'title': 'Événement: Rencontre des étudiants togolais à Paris',
        'content':
            'Salut la communauté ! Nous organisons une rencontre des étudiants togolais à Paris ce samedi. Au programme : échanges, networking et un peu de musique togolaise. Venez nombreux ! Lieu : Centre culturel togolais, 20h.',
        'images': ['https://placekitten.com/300/200'],
        'createdAt': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'updatedAt': null,
        'likesCount': 25,
        'commentsCount': 15,
        'isLiked': true,
        'type': 3, // PostType.event
      },
      {
        'id': 'post_3',
        'authorId': 'user_3',
        'authorName': 'Marie Yao',
        'authorAvatar': 'https://placekitten.com/101/101',
        'title': 'Conseils pour trouver un logement étudiant',
        'content':
            'Hello ! Je cherche des conseils pour trouver un bon logement étudiant à Lomé. Prix moyens, quartiers sûrs, etc. Partagez vos expériences !',
        'images': [],
        'createdAt': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'updatedAt': null,
        'likesCount': 18,
        'commentsCount': 22,
        'isLiked': false,
        'type': 1, // PostType.question
      },
      {
        'id': 'post_4',
        'authorId': 'user_4',
        'authorName': 'Paul Mensah',
        'authorAvatar': null,
        'title': 'Annonce importante: Changement des horaires d\'ouverture',
        'content':
            'Chers étudiants, veuillez noter que les horaires d\'ouverture du bureau des inscriptions changent à partir de lundi : 8h-12h et 14h-16h. Merci de votre compréhension.',
        'images': [],
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': null,
        'likesCount': 5,
        'commentsCount': 3,
        'isLiked': false,
        'type': 2, // PostType.announcement
      },
    ];
  }

  static Future<Map<String, dynamic>> communityPostById(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final posts = await communityPosts();
    return posts.firstWhere((post) => post['id'] == postId);
  }

  static Future<Map<String, dynamic>> createCommunityPost(
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now().toIso8601String();
    return {
      'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
      'authorId': 'user_1', // Current user
      'authorName': 'Utilisateur Test',
      'authorAvatar': null,
      ...data,
      'createdAt': now,
      'updatedAt': null,
      'likesCount': 0,
      'commentsCount': 0,
      'isLiked': false,
    };
  }

  // Community comments
  static Future<List<Map<String, dynamic>>> communityComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    switch (postId) {
      case 'post_1':
        return [
          {
            'id': 'comment_1',
            'postId': 'post_1',
            'authorId': 'user_5',
            'authorName': 'Sophie Agbo',
            'authorAvatar': 'https://placekitten.com/102/102',
            'content':
                'Bonjour ! Pour l\'inscription, tu dois d\'abord aller au bureau des étudiants avec ta carte d\'identité et ton certificat de bac.',
            'createdAt':
                now.subtract(const Duration(hours: 1)).toIso8601String(),
            'updatedAt': null,
            'likesCount': 3,
            'isLiked': false,
            'parentCommentId': null,
          },
          {
            'id': 'comment_2',
            'postId': 'post_1',
            'authorId': 'user_6',
            'authorName': 'Marc Dossou',
            'authorAvatar': null,
            'content':
                'N\'oublie pas de prendre rendez-vous en ligne avant d\'y aller !',
            'createdAt':
                now.subtract(const Duration(minutes: 45)).toIso8601String(),
            'updatedAt': null,
            'likesCount': 1,
            'isLiked': false,
            'parentCommentId': null,
          },
        ];
      case 'post_2':
        return [
          {
            'id': 'comment_3',
            'postId': 'post_2',
            'authorId': 'user_7',
            'authorName': 'Fatima Traoré',
            'authorAvatar': 'https://placekitten.com/103/103',
            'content':
                'Super idée ! Je viendrai avec plaisir. À quelle heure exactement ?',
            'createdAt':
                now.subtract(const Duration(hours: 3)).toIso8601String(),
            'updatedAt': null,
            'likesCount': 5,
            'isLiked': true,
            'parentCommentId': null,
          },
        ];
      default:
        return [];
    }
  }

  static Future<Map<String, dynamic>> createCommunityComment(
    String postId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now().toIso8601String();
    return {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'postId': postId,
      'authorId': 'user_1', // Current user
      'authorName': 'Utilisateur Test',
      'authorAvatar': null,
      ...data,
      'createdAt': now,
      'updatedAt': null,
      'likesCount': 0,
      'isLiked': false,
    };
  }

  static Future<Map<String, dynamic>> communityUser() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'id': 'user_1',
      'name': 'Utilisateur Test',
      'avatar': null,
      'bio':
          'Étudiant togolais en France, passionné par la tech et l\'entrepreneuriat.',
      'postsCount': 5,
      'followersCount': 23,
      'followingCount': 45,
      'joinedAt':
          DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> communityUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'id': userId,
      'name': 'Utilisateur $userId',
      'avatar': null,
      'bio': 'Membre de la communauté Diaspora.',
      'postsCount': 2,
      'followersCount': 10,
      'followingCount': 15,
      'joinedAt':
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    };
  }

  // Create conversation
  static Future<Map<String, dynamic>> createConversation(
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'conv_${DateTime.now().millisecondsSinceEpoch}',
      'title': data['title'],
      'lastMessage': '',
      'lastMessageTime': DateTime.now().toIso8601String(),
      'unreadCount': 0,
      'participants': data['participants'],
      'avatarUrl': null,
    };
  }

  // Committee mocks
  static Future<List<Map<String, dynamic>>> committees() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      {
        'id': 'committee_1',
        'name': 'Comité de Gouvernance',
        'description':
            'Comité responsable de la gouvernance communautaire et des décisions stratégiques',
        'purpose':
            'Superviser les procédures administratives et prendre des décisions importantes',
        'memberIds': ['user_1', 'user_2', 'user_3', 'user_4'],
        'chairpersonId': 'user_1',
        'createdAt': now.subtract(const Duration(days: 365)).toIso8601String(),
        'status': 'ACTIVE',
      },
      {
        'id': 'committee_2',
        'name': 'Comité des Procédures',
        'description':
            'Comité spécialisé dans l\'amélioration et la validation des procédures administratives',
        'purpose':
            'Examiner et approuver les nouvelles procédures pour les membres de la diaspora',
        'memberIds': ['user_2', 'user_5', 'user_6'],
        'chairpersonId': 'user_2',
        'createdAt': now.subtract(const Duration(days: 200)).toIso8601String(),
        'status': 'ACTIVE',
      },
    ];
  }

  static Future<Map<String, dynamic>> committeeDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final committees = await MockApi.committees();
    return committees.firstWhere(
      (c) => c['id'] == id,
      orElse: () => throw Exception('Committee not found'),
    );
  }

  static Future<List<Map<String, dynamic>>> committeeMembers(
    String committeeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final now = DateTime.now();
    if (committeeId == 'committee_1') {
      return [
        {
          'id': 'member_1',
          'userId': 'user_1',
          'committeeId': 'committee_1',
          'role': 'CHAIRPERSON',
          'joinedAt': now.subtract(const Duration(days: 365)).toIso8601String(),
          'status': 'ACTIVE',
        },
        {
          'id': 'member_2',
          'userId': 'user_2',
          'committeeId': 'committee_1',
          'role': 'SECRETARY',
          'joinedAt': now.subtract(const Duration(days: 300)).toIso8601String(),
          'status': 'ACTIVE',
        },
        {
          'id': 'member_3',
          'userId': 'user_3',
          'committeeId': 'committee_1',
          'role': 'MEMBER',
          'joinedAt': now.subtract(const Duration(days: 200)).toIso8601String(),
          'status': 'ACTIVE',
        },
        {
          'id': 'member_4',
          'userId': 'user_4',
          'committeeId': 'committee_1',
          'role': 'MEMBER',
          'joinedAt': now.subtract(const Duration(days: 150)).toIso8601String(),
          'status': 'ACTIVE',
        },
      ];
    } else if (committeeId == 'committee_2') {
      return [
        {
          'id': 'member_5',
          'userId': 'user_2',
          'committeeId': 'committee_2',
          'role': 'CHAIRPERSON',
          'joinedAt': now.subtract(const Duration(days: 200)).toIso8601String(),
          'status': 'ACTIVE',
        },
        {
          'id': 'member_6',
          'userId': 'user_5',
          'committeeId': 'committee_2',
          'role': 'MEMBER',
          'joinedAt': now.subtract(const Duration(days: 180)).toIso8601String(),
          'status': 'ACTIVE',
        },
        {
          'id': 'member_7',
          'userId': 'user_6',
          'committeeId': 'committee_2',
          'role': 'MEMBER',
          'joinedAt': now.subtract(const Duration(days: 160)).toIso8601String(),
          'status': 'ACTIVE',
        },
      ];
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> committeeMeetings(
    String committeeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    if (committeeId == 'committee_1') {
      return [
        {
          'id': 'meeting_1',
          'committeeId': 'committee_1',
          'title': 'Réunion mensuelle de gouvernance',
          'description':
              'Discussion des stratégies communautaires et validation des décisions',
          'scheduledAt': now.add(const Duration(days: 7)).toIso8601String(),
          'location': 'Salle de réunion virtuelle',
          'attendeeIds': ['user_1', 'user_2', 'user_3', 'user_4'],
          'status': 'SCHEDULED',
          'minutes': null,
          'actualStartTime': null,
          'actualEndTime': null,
        },
        {
          'id': 'meeting_2',
          'committeeId': 'committee_1',
          'title': 'Réunion extraordinaire - Budget 2025',
          'description': 'Discussion et approbation du budget annuel',
          'scheduledAt':
              now.subtract(const Duration(days: 14)).toIso8601String(),
          'location': 'Centre communautaire',
          'attendeeIds': ['user_1', 'user_2', 'user_3'],
          'status': 'COMPLETED',
          'minutes':
              'Budget approuvé à l\'unanimité. Prochaines étapes définies.',
          'actualStartTime':
              now
                  .subtract(const Duration(days: 14, hours: 2))
                  .toIso8601String(),
          'actualEndTime':
              now
                  .subtract(const Duration(days: 14, hours: 1))
                  .toIso8601String(),
        },
      ];
    } else if (committeeId == 'committee_2') {
      return [
        {
          'id': 'meeting_3',
          'committeeId': 'committee_2',
          'title': 'Révision des procédures d\'inscription',
          'description':
              'Examen des nouvelles procédures d\'inscription universitaire',
          'scheduledAt': now.add(const Duration(days: 3)).toIso8601String(),
          'location': 'Salle de réunion en ligne',
          'attendeeIds': ['user_2', 'user_5', 'user_6'],
          'status': 'SCHEDULED',
          'minutes': null,
          'actualStartTime': null,
          'actualEndTime': null,
        },
      ];
    }
    return [];
  }

  static Future<Map<String, dynamic>> committeeMeetingDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': id,
      'committeeId': 'committee_1',
      'title': 'Détail de la réunion $id',
      'description': 'Description détaillée pour la réunion $id',
      'scheduledAt':
          DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'location': 'Salle Virtuelle',
      'attendeeIds': ['user_1', 'user_2'],
      'status': 'SCHEDULED',
    };
  }

  static Future<List<Map<String, dynamic>>> committeeProposals(
    String committeeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final now = DateTime.now();
    if (committeeId == 'committee_1') {
      return [
        {
          'id': 'proposal_1',
          'committeeId': 'committee_1',
          'title': 'Extension du programme d\'aide sociale',
          'description':
              'Proposition d\'étendre le programme d\'aide sociale aux étudiants en difficulté financière',
          'proposerId': 'user_3',
          'submittedAt':
              now.subtract(const Duration(days: 30)).toIso8601String(),
          'status': 'APPROVED',
          'votes': [
            {
              'id': 'vote_1',
              'proposalId': 'proposal_1',
              'voterId': 'user_1',
              'vote': 'YES',
              'votedAt':
                  now.subtract(const Duration(days: 25)).toIso8601String(),
            },
            {
              'id': 'vote_2',
              'proposalId': 'proposal_1',
              'voterId': 'user_2',
              'vote': 'YES',
              'votedAt':
                  now.subtract(const Duration(days: 24)).toIso8601String(),
            },
            {
              'id': 'vote_3',
              'proposalId': 'proposal_1',
              'voterId': 'user_3',
              'vote': 'ABSTAIN',
              'votedAt':
                  now.subtract(const Duration(days: 23)).toIso8601String(),
            },
            {
              'id': 'vote_4',
              'proposalId': 'proposal_1',
              'voterId': 'user_4',
              'vote': 'YES',
              'votedAt':
                  now.subtract(const Duration(days: 22)).toIso8601String(),
            },
          ],
          'decision': 'Approuvé - Extension du programme validée',
          'decidedAt': now.subtract(const Duration(days: 20)).toIso8601String(),
        },
        {
          'id': 'proposal_2',
          'committeeId': 'committee_1',
          'title': 'Création d\'un fonds d\'urgence',
          'description':
              'Proposition de créer un fonds d\'urgence pour les situations critiques',
          'proposerId': 'user_4',
          'submittedAt':
              now.subtract(const Duration(days: 10)).toIso8601String(),
          'status': 'PENDING',
          'votes': [],
          'decision': null,
          'decidedAt': null,
        },
      ];
    } else if (committeeId == 'committee_2') {
      return [
        {
          'id': 'proposal_3',
          'committeeId': 'committee_2',
          'title': 'Simplification de la procédure de renouvellement de visa',
          'description':
              'Proposition de simplifier les étapes du renouvellement de titre de séjour',
          'proposerId': 'user_5',
          'submittedAt':
              now.subtract(const Duration(days: 15)).toIso8601String(),
          'status': 'UNDER_REVIEW',
          'votes': [
            {
              'id': 'vote_5',
              'proposalId': 'proposal_3',
              'voterId': 'user_2',
              'vote': 'YES',
              'votedAt':
                  now.subtract(const Duration(days: 12)).toIso8601String(),
            },
          ],
          'decision': null,
          'decidedAt': null,
        },
      ];
    }
    return [];
  }

  static Future<Map<String, dynamic>> committeeProposalDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': id,
      'committeeId': 'committee_1',
      'title': 'Détail de la proposition $id',
      'description': 'Description détaillée pour la proposition $id',
      'proposerId': 'user_3',
      'submittedAt':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'status': 'PENDING',
      'votes': [],
    };
  }

  static Future<Map<String, dynamic>> createCommitteeProposal(
    String committeeId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now().toIso8601String();
    return {
      'id': 'proposal_${DateTime.now().millisecondsSinceEpoch}',
      'committeeId': committeeId,
      'title': data['title'],
      'description': data['description'],
      'proposerId': 'user_1', // Current user
      'submittedAt': now,
      'status': 'PENDING',
      'votes': [],
      'decision': null,
      'decidedAt': null,
    };
  }

  static Future<Map<String, dynamic>> voteOnProposal(
    String proposalId,
    String vote,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now().toIso8601String();
    return {
      'id': 'vote_${DateTime.now().millisecondsSinceEpoch}',
      'proposalId': proposalId,
      'voterId': 'user_1', // Current user
      'vote': vote,
      'votedAt': now,
    };
  }

  // Document types
  static Future<List<Map<String, dynamic>>> documentTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'dt_1',
        'name': 'Passeport',
        'description': 'Passeport en cours de validité',
        'category': 'PASSPORT',
      },
      {
        'id': 'dt_2',
        'name': 'Carte d\'identité',
        'description': 'Carte nationale d\'identité',
        'category': 'ID',
      },
      {
        'id': 'dt_3',
        'name': 'Visa',
        'description': 'Visa étudiant ou de séjour',
        'category': 'VISA',
      },
      {
        'id': 'dt_4',
        'name': 'Diplôme',
        'description': 'Diplôme universitaire',
        'category': 'CERTIFICATE',
      },
      {
        'id': 'dt_5',
        'name': 'Contrat',
        'description': 'Contrat de location ou de travail',
        'category': 'CONTRACT',
      },
    ];
  }

  // Documents feature - mocked
  static final Map<String, Map<String, dynamic>> _uploadedDocuments = {};

  static Future<Map<String, dynamic>> documents({
    int page = 1,
    int pageSize = 20,
    int? profileType,
    String? profileId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final pid = profileId ?? 'u_test';

    final base = <Map<String, dynamic>>[
      {
        'Id': 'doc_1',
        'ProfileId': pid,
        'DocumentTypeId': 'dt_1',
        'DocumentTypeName': 'Passeport',
        'FileName': 'passeport.pdf',
        'FileUrl': 'https://via.placeholder.com/400x300?text=Passport',
        'FileSizeBytes': 2048000,
        'MimeType': 'application/pdf',
        'Status': 1,
        'UploadedAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'ExpiresAt': now.add(const Duration(days: 365)).toIso8601String(),
        'IsVerified': true,
        'ExtractedText': null,
      },
      {
        'Id': 'doc_2',
        'ProfileId': pid,
        'DocumentTypeId': 'dt_2',
        'DocumentTypeName': 'Carte d\'identité',
        'FileName': 'carte_identite.jpg',
        'FileUrl': 'https://via.placeholder.com/400x300?text=ID+Card',
        'FileSizeBytes': 1024000,
        'MimeType': 'image/jpeg',
        'Status': 1,
        'UploadedAt': now.subtract(const Duration(days: 60)).toIso8601String(),
        'ExpiresAt': now.add(const Duration(days: 730)).toIso8601String(),
        'IsVerified': true,
        'ExtractedText': null,
      },
      {
        'Id': 'doc_3',
        'ProfileId': pid,
        'DocumentTypeId': 'dt_4',
        'DocumentTypeName': 'Diplôme',
        'FileName': 'diplome.pdf',
        'FileUrl': 'https://via.placeholder.com/400x300?text=Certificate',
        'FileSizeBytes': 3072000,
        'MimeType': 'application/pdf',
        'Status': 0,
        'UploadedAt': now.subtract(const Duration(days: 15)).toIso8601String(),
        'ExpiresAt': null,
        'IsVerified': false,
        'ExtractedText': null,
      },
    ];

    final allDocs = [
      ..._uploadedDocuments.values.where((d) => d['ProfileId'] == pid).toList(),
      ...base,
    ];

    final totalCount = allDocs.length;
    final totalPages = (totalCount / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    final items = start < allDocs.length
        ? allDocs.sublist(start, end > allDocs.length ? allDocs.length : end)
        : <Map<String, dynamic>>[];

    return {
      'items': items,
      'pageNumber': page,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasPrevious': page > 1,
      'hasNext': page < totalPages,
    };
  }

  static Future<Map<String, dynamic>> documentDetail(String documentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_uploadedDocuments.containsKey(documentId)) {
      return Map<String, dynamic>.from(_uploadedDocuments[documentId]!);
    }

    return {
      'Id': documentId,
      'ProfileId': 'u_test',
      'DocumentTypeId': 'dt_5',
      'DocumentTypeName': 'Document',
      'FileName': 'document.pdf',
      'FileUrl': 'https://via.placeholder.com/400x300?text=Document',
      'FileSizeBytes': 2048000,
      'MimeType': 'application/pdf',
      'Status': 0,
      'UploadedAt': DateTime.now().toIso8601String(),
      'ExpiresAt': null,
      'IsVerified': false,
      'ExtractedText': null,
    };
  }

  static Future<Map<String, dynamic>> uploadDocument(
    Map<String, dynamic> payload,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final id = 'doc_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final entry = {
      'Id': id,
      'ProfileId': payload['ProfileId'] ?? payload['profileId'] ?? 'u_test',
      'DocumentTypeId': payload['DocumentTypeId'] ?? payload['documentTypeId'] ?? 'dt_5',
      'DocumentTypeName': 'Document uploadé',
      'FileName': payload['FileName'] ?? payload['fileName'] ?? 'uploaded_file',
      'FileUrl': 'https://via.placeholder.com/400x300?text=Uploaded',
      'FileSizeBytes': 1024000,
      'MimeType': 'application/pdf',
      'Status': 0,
      'UploadedAt': DateTime.now().toIso8601String(),
      'ExpiresAt': payload['ExpiresAt'] ?? payload['expiresAt'],
      'IsVerified': false,
      'ExtractedText': null,
    };
    _uploadedDocuments[id] = entry;
    return entry;
  }

  static Future<void> deleteDocument(String documentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _uploadedDocuments.remove(documentId);
  }

  static Future<Map<String, dynamic>> extractTextFromDocument(
    String documentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    const ocrText =
        'Extrait du texte reconnu par OCR.\nCette fonctionnalité utilise Google ML Kit.\n'
        'Le texte peut contenir des erreurs de reconnaissance.';

    if (_uploadedDocuments.containsKey(documentId)) {
      _uploadedDocuments[documentId]!['ExtractedText'] = ocrText;
    }

    final detail = await documentDetail(documentId);
    return {...detail, 'ExtractedText': ocrText};
  }

  static Future<void> verifyDocument(String documentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_uploadedDocuments.containsKey(documentId)) {
      _uploadedDocuments[documentId]!['IsVerified'] = true;
    }
  }

  // ==================== SETTINGS ENDPOINTS ====================

  static Future<Map<String, dynamic>> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'theme': 'light',
      'language': 'FR',
      'notificationsEnabled': true,
      'biometricAuthEnabled': false,
      'darkMode': false,
      'privacyLevel': 'PRIVATE',
    };
  }

  static Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {...settings, 'updatedAt': DateTime.now().toIso8601String()};
  }

  static Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock account deletion
  }

  static Future<Map<String, dynamic>> getProviderStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'serviceCount': 12,
      'clientCount': 45,
      'rating': 4.8,
      'totalEarnings': 1500.0,
      'activeSince': '2024-01-15',
    };
  }

  static Future<Map<String, dynamic>> updateProviderSettings(
    Map<String, dynamic> settings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {...settings, 'updatedAt': DateTime.now().toIso8601String()};
  }

  static Future<List<Map<String, dynamic>>> users({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'user_2',
        'name': 'Maman',
        'phone': '+33123456781',
        'userType': 'PARENT',
        'avatar': 'https://placekitten.com/102/102',
      },
      {
        'id': 'user_3',
        'name': 'Papa',
        'phone': '+33123456782',
        'userType': 'PARENT',
        'avatar': 'https://placekitten.com/103/103',
      },
      {
        'id': 'user_4',
        'name': 'Marie Dupont',
        'phone': '+33123456783',
        'userType': 'STUDENT',
        'avatar': 'https://placekitten.com/104/104',
      },
      {
        'id': 'user_5',
        'name': 'Jean Étudiant',
        'phone': '+33123456784',
        'userType': 'STUDENT',
        'avatar': 'https://placekitten.com/105/105',
      },
    ];
  }
}
