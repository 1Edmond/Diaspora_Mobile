import 'package:hive/hive.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_category.dart';

/// Local Hive adapter for persisting documents
class DocumentLocalStorage {
  static const String boxName = 'documents';

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Map<String, dynamic>>(boxName);
    }
  }

  static Future<void> saveDocument(Document document) async {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    await box.put(document.id, document.toJson());
  }

  static Future<void> saveDocuments(List<Document> documents) async {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    for (final doc in documents) {
      await box.put(doc.id, doc.toJson());
    }
  }

  static Document? getDocument(String documentId) {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    final data = box.get(documentId);
    if (data == null) return null;
    return Document.fromJson(Map<String, dynamic>.from(data));
  }

  static List<Document> getAllDocuments() {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    return box.values
        .map((data) => Document.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  static List<Document> getDocumentsByCategory(DocumentCategory category) {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    return box.values
        .where((data) => data['category'] == category.value)
        .map((data) => Document.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  static Future<void> deleteDocument(String documentId) async {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    await box.delete(documentId);
  }

  static Future<void> clearAll() async {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    await box.clear();
  }

  static int getDocumentCount() {
    final box = Hive.box<Map<String, dynamic>>(boxName);
    return box.length;
  }
}
