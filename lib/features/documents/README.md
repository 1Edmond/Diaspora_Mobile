# Document Management Feature - Implementation Guide

## Overview
The Document Management feature provides diaspora members with a secure, organized system to store, manage, and access important administrative documents. This feature is critical for managing essential documents like IDs, passports, visas, certificates, and contracts.

## Architecture

### Directory Structure
```
lib/features/documents/
├── domain/
│   ├── entities/
│   │   ├── document.dart           # Main Document entity with utilities
│   │   ├── document_category.dart  # DocumentCategory enum
│   │   └── document_metadata.dart  # DocumentMetadata entity
│   └── repositories/
│       └── document_repository.dart # IDocumentRepository interface
├── data/
│   ├── repositories/
│   │   └── document_repository_impl.dart # Repository implementation
│   └── local_storage/
│       └── document_local_storage.dart   # Hive local storage adapter
└── presentation/
    ├── controllers/
    │   └── document_providers.dart       # Riverpod providers & notifiers
    ├── screens/
    │   ├── documents_list_screen.dart    # Documents list with search & filter
    │   ├── document_detail_screen.dart   # Document detail & OCR
    │   └── upload_document_screen.dart   # Document upload form
    └── widgets/
        └── document_card.dart             # Reusable document card component
```

## Features Implemented

### 1. Core Functionality
- **Upload Documents**: File picker integration with file validation
- **List Documents**: Display all documents with pagination support
- **View Details**: Full document information with preview
- **Delete Documents**: Safe deletion with confirmation
- **Search & Filter**: By title, description, and category

### 2. Document Categories
- **ID**: Carte d'identité (National ID)
- **Passport**: Travel passport
- **Visa**: Visa documents
- **Certificate**: Educational/professional certificates
- **Contract**: Legal contracts and agreements
- **Other**: Miscellaneous documents

### 3. Advanced Features
- **OCR Text Extraction**: Google ML Kit integration for text recognition
- **Expiration Tracking**: Automatic expiration date management
- **PDF Preview**: Built-in PDF viewer using `pdf` and `printing` packages
- **Document Verification**: Admin verification status
- **Metadata**: Rich document information (size, upload date, description)

### 4. Storage
- **Local Storage**: Hive database for offline access and caching
- **Network Storage**: Mock API for cloud synchronization
- **Encryption Ready**: Document metadata encrypted at local level

## API Endpoints

All endpoints are mocked in `MockApi` class:

### Documents List
```
GET /documents?userId={userId}&category={CATEGORY}
```
Returns paginated list of user's documents

### Document Detail
```
GET /documents/{documentId}
```
Returns full document information

### Upload Document
```
POST /documents/upload
Body: {
  userId: string,
  title: string,
  category: enum,
  description?: string,
  expiresAt?: datetime,
  filePath: string
}
```

### Search Documents
```
GET /documents/search?userId={userId}&query={query}
```

### Extract Text (OCR)
```
POST /documents/{documentId}/extract-text
```

### Verify Document
```
PUT /documents/{documentId}/verify
```

### Delete Document
```
DELETE /documents/{documentId}
```

### Get Expired Documents
```
GET /documents/expired?userId={userId}
```

## State Management (Riverpod)

### Providers
- `documentRepositoryProvider`: Repository instance
- `documentsByUserProvider`: List of user's documents
- `documentsByCategoryProvider`: Filtered documents by category
- `documentDetailProvider`: Single document detail
- `documentSearchProvider`: Search results
- `expiredDocumentsProvider`: Expired documents list
- `documentUploadProvider`: Upload state notifier
- `documentDeleteProvider`: Delete state notifier
- `textExtractionProvider`: OCR text extraction notifier
- `selectedFileProvider`: File picker state

### Usage Example
```dart
// Watch documents list
final documents = ref.watch(documentsByUserProvider(userId));

// Trigger upload
ref.read(documentUploadProvider.notifier).uploadDocument(
  userId: userId,
  filePath: filePath,
  title: title,
  category: category,
);

// Search documents
final results = ref.watch(documentSearchProvider((
  userId: userId,
  query: query,
)));
```

## Routes

```dart
/documents                    # List screen
/documents/:id                # Detail screen  
/documents/upload             # Upload form
```

Routes are integrated into the main router in `lib/core/config/routes.dart`

## Dependency Injection

Register document repository in `lib/core/di/injection.dart`:
```dart
getIt.registerLazySingleton<IDocumentRepository>(
  () => DocumentRepositoryImpl(client: getIt<DioClient>()),
);
```

## Local Storage

Documents are cached locally using Hive for offline access:

```dart
// Save documents
await DocumentLocalStorage.saveDocuments(documents);

// Retrieve documents
final cachedDocs = DocumentLocalStorage.getAllDocuments();

// Get by category
final certificates = DocumentLocalStorage.getDocumentsByCategory(
  DocumentCategory.certificate
);
```

## Error Handling

All screens handle:
- Loading states with progress indicators
- Error states with retry buttons
- Empty states with helpful messaging
- Network failures gracefully
- File picker cancellations

## Mock Data

Sample documents in `MockApi.documents()`:
- Passeport (verified, expires in 1 year)
- Carte d'identité (verified, expires in 2 years)
- Certificat d'études (not verified, no expiration)

## Integration with Home Screen

Documents are accessible from the home screen via a grid menu card that navigates to `/documents`.

## Usage in App

### Access Documents
```dart
// From home screen
context.go('/documents');

// Programmatically
ref.read(documentsByUserProvider(userId));
```

### Upload a Document
```dart
// From documents list screen FAB
context.push('/documents/upload');
```

### View Document
```dart
// From list, tap on document card
context.push('/documents/${document.id}');
```

## Testing

Mock API provides deterministic responses:
- Upload returns new document with ID
- Search filters by title/description
- OCR returns sample extracted text
- Verification marks document as verified
- Delete removes from in-memory store

## Performance Considerations

1. **Pagination**: List screens can be enhanced with pagination
2. **Lazy Loading**: Images and PDFs loaded on demand
3. **Local Caching**: Hive stores frequently accessed documents
4. **Search Optimization**: Indexed search in local storage
5. **Memory**: Large file handling with streaming

## Security Considerations

1. **File Validation**: File type and size checks
2. **Encryption Ready**: Metadata can be encrypted
3. **Secure Storage**: Sensitive paths handled locally
4. **User Context**: All operations tied to userId
5. **Deletion**: Permanent removal with confirmation

## Future Enhancements

- [ ] Share documents with family members
- [ ] Document expiration notifications
- [ ] Bulk document operations
- [ ] Document templates
- [ ] Email document copies
- [ ] Automatic backup to cloud
- [ ] Document scanning from camera
- [ ] Barcode/QR code recognition
- [ ] Document signature
- [ ] Encrypted cloud backup

## Dependencies Used

```yaml
file_picker: ^8.0.0              # File selection
google_mlkit_text_recognition: ^0.11.0  # OCR
pdf: ^3.10.8                     # PDF handling
printing: ^5.12.0                # PDF viewing
hive: ^2.2.3                     # Local storage
hive_flutter: ^1.1.0             # Flutter Hive
flutter_riverpod: ^2.5.1         # State management
dio: ^5.4.0                      # Networking
```

## Notes

- All endpoints are mocked using `MockApi` - ready for backend integration
- The feature follows the app's existing clean architecture pattern
- Riverpod state management ensures proper async handling
- Hive provides offline-first caching capability
- Error handling includes user feedback and recovery options
