// Mock seed data for the Freelance module. Mirrors the shape returned by the
// Freelance API (PascalCase JSON keys) so the repository/models parse it the
// same way they parse real responses. All dates are UTC.

final mockJobCategories = <Map<String, dynamic>>[
  {'Id': 'cat_1', 'Name': 'Événementiel', 'Description': 'Missions pour événements ponctuels', 'IsActive': true},
  {'Id': 'cat_2', 'Name': 'Manutention', 'Description': 'Aide manuelle, déménagement', 'IsActive': true},
  {'Id': 'cat_3', 'Name': 'Cuisine', 'Description': 'Service traiteur, aide en cuisine', 'IsActive': true},
  {'Id': 'cat_4', 'Name': 'Livraison', 'Description': 'Courses et livraisons', 'IsActive': true},
  {'Id': 'cat_5', 'Name': 'Bureautique', 'Description': 'Saisie, assistance administrative', 'IsActive': true},
];

final mockJobTemplates = <Map<String, dynamic>>[
  {
    'Id': 'tpl_1',
    'EmployerId': 'emp_1',
    'Name': 'Serveur événementiel',
    'Description': 'Service et accueil pour un événement',
    'CategoryId': 'cat_1',
    'RequiredSkills': ['Accueil', 'Service'],
    'RequiredDocuments': [],
    'DefaultCapacity': 4,
    'DefaultAmount': 90.0,
    'DefaultCurrency': 'EUR',
    'DefaultPaymentType': 2, // perTask
    'DefaultPaymentTiming': 0, // payOnCompletion
    'DefaultCheckInMethod': 0, // qrCode
    'DefaultGeofenceRadiusMeters': null,
    'DefaultRequiresKyc': false,
  },
  {
    'Id': 'tpl_2',
    'EmployerId': 'emp_1',
    'Name': 'Aide déménagement',
    'Description': 'Chargement et déchargement',
    'CategoryId': 'cat_2',
    'RequiredSkills': ['Force', 'Prudence'],
    'RequiredDocuments': [],
    'DefaultCapacity': 2,
    'DefaultAmount': 25.0,
    'DefaultCurrency': 'EUR',
    'DefaultPaymentType': 1, // perDay
    'DefaultPaymentTiming': 1, // escrowUpfront
    'DefaultCheckInMethod': 1, // geoLocation
    'DefaultGeofenceRadiusMeters': 200,
    'DefaultRequiresKyc': false,
  },
];

final mockJobPostings = <Map<String, dynamic>>[
  {
    'Id': 'job_1',
    'EmployerId': 'emp_1',
    'EmployerName': 'Agence Événementielle Togo',
    'TemplateId': 'tpl_1',
    'CategoryId': 'cat_1',
    'CategoryName': 'Événementiel',
    'Title': 'Serveurs pour gala de bienfaisance',
    'Description': 'Accueil, service à table et vestiaire lors d\'un gala caritatif.',
    'Capacity': 4,
    'AcceptedCount': 2,
    'Amount': 90.0,
    'Currency': 'EUR',
    'PaymentType': 2, // perTask
    'PaymentTiming': 0, // payOnCompletion
    'CheckInMethod': 0, // qrCode
    'GeofenceRadiusMeters': null,
    'RequiresKycVerification': false,
    'EventStartAt': '2026-09-12T18:00:00Z',
    'EventEndAt': '2026-09-12T23:00:00Z',
    'City': 'Paris',
    'Country': 'France',
    'Latitude': 48.8566,
    'Longitude': 2.3522,
    'IsRemote': false,
    'RequiredSkills': ['Accueil', 'Service'],
    'RequiredDocuments': [],
    'RegistrationDeadline': '2026-09-10T23:59:00Z',
    'Status': 1, // open
    'CreatedAt': '2026-08-20T10:00:00Z',
  },
  {
    'Id': 'job_2',
    'EmployerId': 'emp_1',
    'EmployerName': 'Agence Événementielle Togo',
    'TemplateId': null,
    'CategoryId': 'cat_2',
    'CategoryName': 'Manutention',
    'Title': 'Déménagement studio étudiant',
    'Description': 'Aide pour déplacer cartons et mobilier léger sur 3 heures.',
    'Capacity': 2,
    'AcceptedCount': 0,
    'Amount': 25.0,
    'Currency': 'EUR',
    'PaymentType': 1, // perDay
    'PaymentTiming': 1, // escrowUpfront
    'CheckInMethod': 1, // geoLocation
    'GeofenceRadiusMeters': 200,
    'RequiresKycVerification': false,
    'EventStartAt': '2026-09-05T09:00:00Z',
    'EventEndAt': '2026-09-05T12:00:00Z',
    'City': 'Lyon',
    'Country': 'France',
    'Latitude': 45.7640,
    'Longitude': 4.8357,
    'IsRemote': false,
    'RequiredSkills': ['Force', 'Prudence'],
    'RequiredDocuments': [],
    'RegistrationDeadline': '2026-09-03T18:00:00Z',
    'Status': 1, // open
    'CreatedAt': '2026-08-22T09:00:00Z',
  },
  {
    'Id': 'job_3',
    'EmployerId': 'emp_2',
    'EmployerName': 'Traiteur Lomé Services',
    'TemplateId': null,
    'CategoryId': 'cat_3',
    'CategoryName': 'Cuisine',
    'Title': 'Aide en cuisine pour mariage',
    'Description': 'Préparation et dressage des plats en renfort de l\'équipe.',
    'Capacity': 3,
    'AcceptedCount': 1,
    'Amount': 80.0,
    'Currency': 'EUR',
    'PaymentType': 2, // perTask
    'PaymentTiming': 0, // payOnCompletion
    'CheckInMethod': 4, // any
    'GeofenceRadiusMeters': null,
    'RequiresKycVerification': false,
    'EventStartAt': '2026-09-19T08:00:00Z',
    'EventEndAt': '2026-09-19T20:00:00Z',
    'City': 'Lomé',
    'Country': 'Togo',
    'Latitude': 6.1319,
    'Longitude': 1.2228,
    'IsRemote': false,
    'RequiredSkills': ['Cuisine', 'Hygiène'],
    'RequiredDocuments': [],
    'RegistrationDeadline': '2026-09-15T18:00:00Z',
    'Status': 1, // open
    'CreatedAt': '2026-08-18T14:00:00Z',
  },
  {
    'Id': 'job_4',
    'EmployerId': 'emp_3',
    'EmployerName': 'Bureautique Plus',
    'TemplateId': null,
    'CategoryId': 'cat_5',
    'CategoryName': 'Bureautique',
    'Title': 'Saisie de données à distance',
    'Description': 'Saisie et mise en forme d\'un fichier de contacts.',
    'Capacity': 1,
    'AcceptedCount': 1,
    'Amount': 60.0,
    'Currency': 'EUR',
    'PaymentType': 3, // fixed
    'PaymentTiming': 0, // payOnCompletion
    'CheckInMethod': 4, // any
    'GeofenceRadiusMeters': null,
    'RequiresKycVerification': false,
    'EventStartAt': '2026-09-01T09:00:00Z',
    'EventEndAt': '2026-09-05T18:00:00Z',
    'City': null,
    'Country': null,
    'Latitude': null,
    'Longitude': null,
    'IsRemote': true,
    'RequiredSkills': ['Excel', 'Rigueur'],
    'RequiredDocuments': [],
    'RegistrationDeadline': '2026-08-30T18:00:00Z',
    'Status': 2, // registrationClosed
    'CreatedAt': '2026-08-15T10:00:00Z',
  },
  {
    'Id': 'job_5',
    'EmployerId': 'emp_1',
    'EmployerName': 'Agence Événementielle Togo',
    'TemplateId': null,
    'CategoryId': 'cat_1',
    'CategoryName': 'Événementiel',
    'Title': 'Briefing serveurs (brouillon)',
    'Description': 'Offre en préparation, pas encore publiée.',
    'Capacity': 5,
    'AcceptedCount': 0,
    'Amount': 75.0,
    'Currency': 'EUR',
    'PaymentType': 2,
    'PaymentTiming': 0,
    'CheckInMethod': 0,
    'GeofenceRadiusMeters': null,
    'RequiresKycVerification': false,
    'EventStartAt': '2026-10-01T18:00:00Z',
    'EventEndAt': '2026-10-01T22:00:00Z',
    'City': 'Paris',
    'Country': 'France',
    'Latitude': 48.8566,
    'Longitude': 2.3522,
    'IsRemote': false,
    'RequiredSkills': [],
    'RequiredDocuments': [],
    'RegistrationDeadline': null,
    'Status': 0, // draft
    'CreatedAt': '2026-08-25T11:00:00Z',
  },
];

final mockJobApplications = <Map<String, dynamic>>[
  {
    'Id': 'app_1',
    'JobPostingId': 'job_1',
    'JobPostingTitle': 'Serveurs pour gala de bienfaisance',
    'WorkerId': 'worker_1',
    'WorkerName': 'Jean Mensah',
    'Message': 'Expérience en service événementiel, disponible le soir.',
    'Status': 1, // accepted
    'DecidedAt': '2026-08-21T09:00:00Z',
    'DecidedBy': 'emp_1',
    'RejectionReason': null,
    'ChatThreadId': 'conv_1001',
    'EscrowTransactionId': null,
    'CreatedAt': '2026-08-20T12:00:00Z',
  },
  {
    'Id': 'app_2',
    'JobPostingId': 'job_1',
    'JobPostingTitle': 'Serveurs pour gala de bienfaisance',
    'WorkerId': 'worker_2',
    'WorkerName': 'Amina Diallo',
    'Message': 'Serveuse expérimentée, je parle français et anglais.',
    'Status': 1, // accepted
    'DecidedAt': '2026-08-21T10:00:00Z',
    'DecidedBy': 'emp_1',
    'RejectionReason': null,
    'ChatThreadId': null,
    'EscrowTransactionId': null,
    'CreatedAt': '2026-08-20T13:00:00Z',
  },
  {
    'Id': 'app_3',
    'JobPostingId': 'job_1',
    'JobPostingTitle': 'Serveurs pour gala de bienfaisance',
    'WorkerId': 'worker_3',
    'WorkerName': 'Marc Dossou',
    'Message': 'Disponible et motivé, première expérience.',
    'Status': 0, // pending
    'DecidedAt': null,
    'DecidedBy': null,
    'RejectionReason': null,
    'ChatThreadId': null,
    'EscrowTransactionId': null,
    'CreatedAt': '2026-08-21T08:00:00Z',
  },
  {
    'Id': 'app_4',
    'JobPostingId': 'job_2',
    'JobPostingTitle': 'Déménagement studio étudiant',
    'WorkerId': 'worker_4',
    'WorkerName': 'Fatou Bamba',
    'Message': 'Habituée aux déménagements, ponctuelle.',
    'Status': 2, // rejected
    'DecidedAt': '2026-08-23T10:00:00Z',
    'DecidedBy': 'emp_1',
    'RejectionReason': 'Équipe déjà complète',
    'ChatThreadId': null,
    'EscrowTransactionId': null,
    'CreatedAt': '2026-08-22T15:00:00Z',
  },
  {
    'Id': 'app_5',
    'JobPostingId': 'job_3',
    'JobPostingTitle': 'Aide en cuisine pour mariage',
    'WorkerId': 'worker_5',
    'WorkerName': 'Yao Kossi',
    'Message': 'Cuistot expérimenté en cuisine togolaise.',
    'Status': 4, // completed
    'DecidedAt': '2026-09-19T21:00:00Z',
    'DecidedBy': 'emp_2',
    'RejectionReason': null,
    'ChatThreadId': 'conv_1002',
    'EscrowTransactionId': null,
    'CreatedAt': '2026-09-10T09:00:00Z',
  },
];

final mockJobCheckIns = <Map<String, dynamic>>[
  {
    'Id': 'ci_1',
    'JobApplicationId': 'app_5',
    'WorkerId': 'worker_5',
    'CheckInAt': '2026-09-19T07:55:00Z',
    'CheckOutAt': '2026-09-19T20:10:00Z',
    'CheckInLatitude': 6.1319,
    'CheckInLongitude': 1.2228,
    'Method': 3, // pinCode
    'Status': 1, // checkedOut
  },
];

final mockReputations = <Map<String, dynamic>>[
  {
    'SubjectId': 'worker_5',
    'Role': 0, // worker
    'AverageRating': 4.7,
    'AveragePunctuality': 4.8,
    'AverageQuality': 4.6,
    'AverageCommunication': 4.7,
    'TotalRatings': 12,
    'TotalJobsCompleted': 9,
  },
  {
    'SubjectId': 'emp_2',
    'Role': 1, // employer
    'AverageRating': 4.5,
    'AveragePunctuality': 4.4,
    'AverageQuality': 4.6,
    'AverageCommunication': 4.5,
    'TotalRatings': 8,
    'TotalJobsCompleted': 8,
  },
];

final mockWorkerJobPreferences = <Map<String, dynamic>>[
  {
    'Id': 'pref_1',
    'WorkerId': 'worker_1',
    'CategoryId': 'cat_1',
    'City': 'Paris',
    'MaxDistanceKm': null,
  },
];