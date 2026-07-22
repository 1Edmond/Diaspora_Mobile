class DocumentTypeModel {
  final String id;
  final String name;
  final String? description;
  final String? category;

  DocumentTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
  });

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      id: (json['Id'] ?? json['id'] ?? '') as String,
      name: (json['Name'] ?? json['name'] ?? '') as String,
      description: (json['Description'] ?? json['description']) as String?,
      category: (json['Category'] ?? json['category']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
  };
}
