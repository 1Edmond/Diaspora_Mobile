import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'mock_api.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class DioClient {
  final Dio dio;

  DioClient({Dio? client}) : dio = client ?? Dio(_defaultOptions()) {
    // Mock interceptor routes HTTP calls to in-app MockApi so the app
    // can use a realistic network surface while remaining offline.
    dio.interceptors.add(_MockInterceptor());

    // Pass errors through (Dio 5 uses DioException). Keep default behaviour
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) {
          handler.next(err);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  static BaseOptions _defaultOptions() => BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 50),
    receiveTimeout: const Duration(seconds: 50),
    headers: {'Content-Type': 'application/json'},
  );

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final r = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    final data = r.data;
    // provide a clearer error when the runtime type doesn't match the generic T
    if (data is List && T.toString().contains('Map')) {
      throw StateError(
        'GET $path returned ${data.runtimeType} but caller expected $T.\nResponse (truncated): ${data.length} items',
      );
    }
    return data as T;
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final r = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return r.data as T;
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final r = await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return r.data as T;
  }

  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    final r = await dio.delete(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
    );
    return r.data as T;
  }
}

/// Internal: maps HTTP requests to in-app MockApi implementations so we can
/// exercise the networking layer without an external backend.
class _MockInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // normalize to the URI path (handles absolute & relative paths uniformly)
      String path = options.uri.path;
      if (path.startsWith('/api')) {
        path = path.substring(4);
      }
      final method = options.method.toUpperCase();
      // debug aid for flaky matching in tests
      // ignore: avoid_print
      print('MockInterceptor: normalized $method $path');

      // Services: specific detail route must be checked BEFORE the collection
      if (method == 'GET' && _matches(path, r'^/services/')) {
        final id = path.split('/').last;
        final data = await MockApi.serviceDetail(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Services collection (only exact /services or /services/)
      if (method == 'GET' && _matches(path, r'^/services(?:\\/?)?$')) {
        final city = options.queryParameters['city'] as String?;
        final data = await MockApi.services(city: city);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Handle POST /services via exact-match fallback (some Dio RequestOptions
      // present absolute paths in tests — be resilient).
      if (path == '/services' && method == 'POST') {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createService(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'POST' && _matches(path, r'^/services(?:\\/?)$')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createService(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Services: approve/reject (admin)
      if (method == 'POST' && _matches(path, r'^/services/.+?/approve')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.approveService(
          id,
          body['approved'] as bool? ?? false,
          body['reason'] as String?,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Notifications
      if (method == 'GET' && _matches(path, r'^/notifications')) {
        final target =
            options.queryParameters['target'] as String? ?? 'unknown';
        final data = await MockApi.notifications(
          target: target,
          page: options.queryParameters['page'] as int? ?? 1,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Auth routes are NOT mocked — they go to the real API
      // (handled by AuthRepositoryImpl's own Dio instance)

      if (method == 'GET' && _matches(path, r'^/users')) {
        final page = options.queryParameters['page'] as int? ?? 1;
        final data = await MockApi.users(page: page);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Procedures (paginated)
      if (method == 'GET' && _matches(path, r'^/procedures')) {
        final rawPage = options.queryParameters['pageNumber'];
        final rawPageSize = options.queryParameters['pageSize'];
        final page = rawPage is int
            ? rawPage
            : int.tryParse(rawPage?.toString() ?? '') ?? 1;
        final pageSize = rawPageSize is int
            ? rawPageSize
            : int.tryParse(rawPageSize?.toString() ?? '') ?? 20;
        final data = await MockApi.procedures(
          page: page,
          pageSize: pageSize,
          profileType: options.queryParameters['profileType'] as String?,
          profileTypeId: options.queryParameters['profileTypeId'] as String?,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Committees collection
      if (method == 'GET' && _matches(path, r'^/committees$')) {
        final data = await MockApi.committees();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Committee Detail
      if (method == 'GET' && _matches(path, r'^/committees/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.committeeDetail(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Committee Members
      if (method == 'GET' && _matches(path, r'^/committees/[^/]+/members$')) {
        final id = path.split('/')[2];
        final data = await MockApi.committeeMembers(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Committee Meetings
      if (method == 'GET' && _matches(path, r'^/committees/[^/]+/meetings$')) {
        final id = path.split('/')[2];
        final data = await MockApi.committeeMeetings(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Committee Proposals
      if (method == 'GET' && _matches(path, r'^/committees/[^/]+/proposals$')) {
        final id = path.split('/')[2];
        final data = await MockApi.committeeProposals(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Create Proposal
      if (method == 'POST' &&
          _matches(path, r'^/committees/[^/]+/proposals$')) {
        final data = {
          'id': 'p_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'PENDING',
        };
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Meetings Detail
      if (method == 'GET' && _matches(path, r'^/meetings/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.committeeMeetingDetail(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Proposals Detail
      if (method == 'GET' && _matches(path, r'^/proposals/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.committeeProposalDetail(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Wallet
      if (method == 'GET' && _matches(path, r'^/wallet/balance')) {
        final userId =
            options.queryParameters['userId'] as String? ?? 'unknown';
        final data = await MockApi.walletBalance(userId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'GET' && _matches(path, r'^/wallet/transactions')) {
        final userId =
            options.queryParameters['userId'] as String? ?? 'unknown';
        final data = await MockApi.walletTransactions(
          userId,
          page: options.queryParameters['page'] as int? ?? 1,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/wallet/transfer')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.walletTransfer(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Chat conversations
      if (method == 'GET' && _matches(path, r'^/chat/conversations')) {
        final data = await MockApi.conversations();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Create conversation
      if (method == 'POST' && _matches(path, r'^/chat/conversations')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createConversation(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Chat messages (/chat/conversations/:id/messages)
      if (method == 'GET' &&
          _matches(path, r'^/chat/conversations/[^/]+/messages')) {
        final conversationId = path.split('/')[3];
        final data = await MockApi.messages(conversationId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Chat messages (/chat/messages/:id — alternative route used by some repos)
      if (method == 'GET' && _matches(path, r'^/chat/messages/[^/]+')) {
        final conversationId = path.split('/').last;
        final data = await MockApi.messages(conversationId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Send message
      if (method == 'POST' &&
          _matches(path, r'^/chat/conversations/[^/]+/messages')) {
        final conversationId = path.split('/')[3];
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.sendMessage(conversationId, payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Mark messages as read
      if (method == 'POST' &&
          _matches(path, r'^/chat/conversations/[^/]+/read')) {
        final conversationId = path.split('/')[3];
        await MockApi.markMessagesAsRead(conversationId);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // Community posts
      if (method == 'GET' && _matches(path, r'^/community/posts$')) {
        final page = options.queryParameters['page'] as int? ?? 1;
        final limit = options.queryParameters['limit'] as int? ?? 20;
        final data = await MockApi.communityPosts(page: page, limit: limit);
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'posts': data},
            statusCode: 200,
          ),
        );
      }

      // Community post by ID
      if (method == 'GET' && _matches(path, r'^/community/posts/[^/]+$')) {
        final postId = path.split('/').last;
        final data = await MockApi.communityPostById(postId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Create community post
      if (method == 'POST' && _matches(path, r'^/community/posts$')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createCommunityPost(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Update community post
      if (method == 'PUT' && _matches(path, r'^/community/posts/[^/]+$')) {
        final postId = path.split('/').last;
        final payload = options.data as Map<String, dynamic>? ?? {};
        final existingPost = await MockApi.communityPostById(postId);
        final updatedPost = {
          ...existingPost,
          ...payload,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        return handler.resolve(
          Response(requestOptions: options, data: updatedPost, statusCode: 200),
        );
      }

      // Delete community post
      if (method == 'DELETE' && _matches(path, r'^/community/posts/[^/]+$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // Like/unlike post
      if (method == 'POST' &&
          _matches(path, r'^/community/posts/[^/]+/like$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'DELETE' &&
          _matches(path, r'^/community/posts/[^/]+/like$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // Share post
      if (method == 'POST' &&
          _matches(path, r'^/community/posts/[^/]+/share$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // Community comments
      if (method == 'GET' &&
          _matches(path, r'^/community/posts/[^/]+/comments$')) {
        final postId = path.split('/')[3];
        final page = options.queryParameters['page'] as int? ?? 1;
        final limit = options.queryParameters['limit'] as int? ?? 20;
        final data = await MockApi.communityComments(
          postId,
          page: page,
          limit: limit,
        );
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'comments': data},
            statusCode: 200,
          ),
        );
      }

      // Create community comment
      if (method == 'POST' &&
          _matches(path, r'^/community/posts/[^/]+/comments$')) {
        final postId = path.split('/')[3];
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createCommunityComment(postId, payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Update community comment
      if (method == 'PUT' && _matches(path, r'^/community/comments/[^/]+$')) {
        final commentId = path.split('/').last;
        final payload = options.data as Map<String, dynamic>? ?? {};
        // For simplicity, just return the payload as updated comment
        final updatedComment = {
          'id': commentId,
          ...payload,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        return handler.resolve(
          Response(
            requestOptions: options,
            data: updatedComment,
            statusCode: 200,
          ),
        );
      }

      // Delete community comment
      if (method == 'DELETE' &&
          _matches(path, r'^/community/comments/[^/]+$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // Like/unlike comment
      if (method == 'POST' &&
          _matches(path, r'^/community/comments/[^/]+/like$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'DELETE' &&
          _matches(path, r'^/community/comments/[^/]+/like$')) {
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // Community user
      if (method == 'GET' && _matches(path, r'^/community/user$')) {
        final data = await MockApi.communityUser();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Document types
      if (method == 'GET' && _matches(path, r'^/document-types$')) {
        final data = await MockApi.documentTypes();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Documents: paginated list
      if (method == 'GET' && _matches(path, r'^/documents$')) {
        final rawPage = options.queryParameters['pageNumber'];
        final rawPageSize = options.queryParameters['pageSize'];
        final page = rawPage is int
            ? rawPage
            : int.tryParse(rawPage?.toString() ?? '') ?? 1;
        final pageSize = rawPageSize is int
            ? rawPageSize
            : int.tryParse(rawPageSize?.toString() ?? '') ?? 20;
        final profileType = options.queryParameters['profileType'] as int?;
        final profileId = options.queryParameters['profileId'] as String?;
        final data = await MockApi.documents(
          page: page,
          pageSize: pageSize,
          profileType: profileType,
          profileId: profileId,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Documents: detail route (must be before delete/post routes)
      if (method == 'GET' && _matches(path, r'^/documents/[^/]+$')) {
        final documentId = path.split('/').last;
        final data = await MockApi.documentDetail(documentId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Documents: upload
      if (method == 'POST' && _matches(path, r'^/documents/upload$')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.uploadDocument(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // Documents: extract text (OCR)
      if (method == 'POST' &&
          _matches(path, r'^/documents/.+?/extract-text$')) {
        final documentId = path.split('/')[2];
        final data = await MockApi.extractTextFromDocument(documentId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Documents: verify
      if (method == 'PUT' && _matches(path, r'^/documents/.+?/verify$')) {
        final documentId = path.split('/')[2];
        await MockApi.verifyDocument(documentId);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // Documents: delete
      if (method == 'DELETE' && _matches(path, r'^/documents/[^/]+$')) {
        final documentId = path.split('/').last;
        await MockApi.deleteDocument(documentId);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // If no mock matched, continue to real network (or fail if baseUrl is empty)
      return handler.next(options);
    } catch (e, st) {
      handler.reject(
        DioException(requestOptions: options, error: e, stackTrace: st),
      );
    }
  }

  bool _matches(String path, String pattern) => RegExp(pattern).hasMatch(path);
}
