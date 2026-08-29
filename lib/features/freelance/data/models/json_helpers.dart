// Shared JSON parsing helpers for the Freelance module models. The helper
// signatures mirror the private helpers used across the Marketplace models
// (PascalCase-first, camelCase fallback), but are shared to avoid triplicating
// the same ~40 lines in every model file.

String jstr(Map<String, dynamic> json, String pascal, String camel) =>
    (json[pascal] ?? json[camel] ?? '') as String;

String? jstrOrNull(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return null;
  return val as String;
}

int jint(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return 0;
  return (val as num).toInt();
}

int? jintOrNull(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return null;
  return (val as num).toInt();
}

double jdouble(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return 0.0;
  return (val as num).toDouble();
}

double? jdoubleOrNull(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return null;
  return (val as num).toDouble();
}

bool jbool(Map<String, dynamic> json, String pascal, String camel) {
  final val = json[pascal] ?? json[camel];
  if (val == null) return false;
  if (val is bool) return val;
  if (val is String) return val.toLowerCase() == 'true';
  return val == 1;
}

List<String> jstringList(Map<String, dynamic> json, String pascal, String camel) {
  final raw = json[pascal] ?? json[camel];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  return [];
}

DateTime? jDateTime(Map<String, dynamic> json, String pascal, String camel) {
  final raw = json[pascal] ?? json[camel];
  if (raw is String) return DateTime.tryParse(raw);
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  return null;
}