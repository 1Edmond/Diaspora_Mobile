# Document Management Feature - Quick Reference Guide

## 🎯 Quick Start

### Access the Feature
1. Run the app: `flutter run`
2. Navigate to **Home Screen**
3. Click the **Documents** card

### Main Routes
- `/documents` - View all documents
- `/documents/upload` - Upload new document
- `/documents/{id}` - View document details

## 📋 File Structure

### Domain Layer
- `document.dart` - Main Document entity with utilities
- `document_category.dart` - 6 document categories with labels
- `document_metadata.dart` - Document metadata tracking
- `document_repository.dart` - Repository interface

### Data Layer
- `document_repository_impl.dart` - Repository implementation
- `document_local_storage.dart` - Hive caching

### Presentation Layer
- `document_providers.dart` - 10 Riverpod providers/notifiers
- `documents_list_screen.dart` - Main list with search/filter
- `document_detail_screen.dart` - Full details with OCR
- `upload_document_screen.dart` - Upload form
- `document_card.dart` - Reusable widgets

## 🚀 Key Classes & Methods

### Document Entity
```dart
class Document {
  final String id;
  final String userId;
  final String title;
  final DocumentCategory category;
  final String url;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final String? extractedText;
  final bool isVerified;
  
  // Utility methods
  bool get isExpired // Check if expired
  int get expiresInDays // Days until expiration
  String get formattedFileSize // "2.5 MB"
  bool get isPdf // Check if PDF
  bool get isImage // Check if image
}
```

### DocumentCategory
```dart
enum DocumentCategory {
  id,           // Carte d'identité
  passport,     // Passeport
  visa,         // Visa
  certificate,  // Certificat
  contract,     // Contrat
  other         // Other
}
```

### Repository Methods
```dart
Future<List<Document>> getDocuments(String userId, {DocumentCategory? category})
Future<Document?> getDocumentById(String documentId)
Future<Document> uploadDocument({...})
Future<void> deleteDocument(String documentId)
Future<List<Document>> searchDocuments(String userId, String query)
Future<Document> extractTextFromDocument(String documentId)
Future<void> verifyDocument(String documentId)
Future<List<Document>> getExpiredDocuments(String userId)
```

## 🧠 Riverpod Usage

### Watching Document List
```dart
final documents = ref.watch(documentsByUserProvider(userId));

documents.when(
  loading: () => CircularProgressIndicator(),
  error: (err, st) => ErrorWidget(),
  data: (docs) => ListView(...)
)
```

### Upload Document
```dart
ref.read(documentUploadProvider.notifier).uploadDocument(
  userId: userId,
  filePath: filePath,
  title: title,
  category: category,
  expiresAt: expiresAt,
);
```

### Search Documents
```dart
final results = ref.watch(documentSearchProvider((
  userId: userId,
  query: searchTerm,
)));
```

### Extract Text (OCR)
```dart
ref.read(textExtractionProvider.notifier)
  .extractText(documentId);
```

## 📡 Mock API Endpoints

All endpoints return realistic mock data:

```
GET /documents?userId={id}&category={CATEGORY}
GET /documents/{id}
GET /documents/search?userId={id}&query={q}
GET /documents/expired?userId={id}
POST /documents/upload
POST /documents/{id}/extract-text
PUT /documents/{id}/verify
DELETE /documents/{id}
```

## 💾 Local Storage

Access Hive cache directly:

```dart
// Save documents
await DocumentLocalStorage.saveDocuments(documents);

// Get all documents
final all = DocumentLocalStorage.getAllDocuments();

// Get by category
final certs = DocumentLocalStorage.getDocumentsByCategory(
  DocumentCategory.certificate
);

// Delete
await DocumentLocalStorage.deleteDocument(docId);

// Clear all
await DocumentLocalStorage.clearAll();
```

## 🎨 UI Components

### DocumentCard
```dart
DocumentCard(
  document: document,
  onTap: () => context.push('/documents/${document.id}'),
  onDelete: () => deletionConfirmation(),
)
```

### DocumentCategoryBadge
```dart
DocumentCategoryBadge(
  category: document.category,
)
```

### DocumentEmptyState
```dart
DocumentEmptyState(
  onAddDocument: () => context.push('/documents/upload'),
)
```

## 🔍 Features Breakdown

### Upload Screen
- File picker (PDF, images, documents)
- Title input (required)
- Category selection (required)
- Description (optional)
- Expiration date (optional)
- File preview before upload
- Loading state during upload

### List Screen
- All user documents
- Search by title/description
- Filter by category
- Category chips for quick filtering
- File size display
- Upload date (relative)
- Expiration warning
- Delete with confirmation
- Empty state with helpful message

### Detail Screen
- Document preview (PDF/image)
- Full metadata display
- Verification status
- OCR text extraction
- Expiration status
- Easy navigation to list
- Safe delete option

## 🧪 Testing

### Test Data
The mock API includes:
- Passeport (verified, expires in 365 days)
- Carte d'identité (verified, expires in 730 days)
- Certificat d'études (unverified, no expiration)

### Testing Searches
Search for documents by:
- Title: "passeport", "identité"
- Description: "personnel", "universitaire"

## 🐛 Debugging

### Enable Debug Logging
```dart
// In DioClient, logging is enabled in debug mode
if (kDebugMode) {
  dio.interceptors.add(LogInterceptor(...));
}
```

### Common Issues

**Issue**: Document not appearing after upload
- Check: Category filter (might be filtering it out)
- Solution: Click "Tous" to see all documents

**Issue**: OCR text not extracting
- Check: Network connection (mocked as delay)
- Try: Wait for the loading to complete

**Issue**: Expiration date not showing
- Check: Did you set an expiration date during upload?
- Solution: Edit document metadata if needed

## 🔐 Security Notes

- All operations check user context
- Hive storage is local only
- File types validated
- File sizes checked
- Deletion requires confirmation
- BuildContext lifecycle properly managed

## 📚 Integration Points

### In main.dart
```dart
import 'features/documents/data/local_storage/document_local_storage.dart';

// In main()
await DocumentLocalStorage.initialize();
```

### In routes.dart
```dart
GoRoute(
  path: '/documents',
  builder: (c, s) => const DocumentsListScreen(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (c, s) => DocumentDetailScreen(
        documentId: s.pathParameters['id']!
      ),
    ),
    GoRoute(
      path: 'upload',
      builder: (c, s) => const UploadDocumentScreen(),
    ),
  ],
),
```

### In DI (injection.dart)
```dart
getIt.registerLazySingleton<IDocumentRepository>(
  () => DocumentRepositoryImpl(client: getIt<DioClient>()),
);
```

### In MockInterceptor (dio_client.dart)
Documents endpoints are already mocked with proper routing

### In Home Screen
Documents card added to navigation grid

## 🚀 Next Steps

1. **Test the feature** - Navigate to /documents in the app
2. **Upload a document** - Click the FAB on the list screen
3. **Search documents** - Use the search bar
4. **View details** - Click any document to see full info
5. **Extract text** - Click "Extraire le texte" button
6. **Delete document** - Use the menu on any card

## 📞 Support

For issues or questions:
1. Check the error message in the snackbar
2. Review the console logs
3. Check [Feature README](./lib/features/documents/README.md)
4. Review this quick reference guide

---

**Feature Status**: ✅ Complete and Ready to Use!
