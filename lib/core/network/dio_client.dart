import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'mock_api.dart';
import 'token_service.dart';

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
    if (AppConfig.useMockData) {
      // Mock interceptor routes HTTP calls to in-app MockApi so the app
      // can use a realistic network surface while remaining offline.
      dio.interceptors.add(_MockInterceptor());
    } else {
      if (client == null) {
        dio.options.baseUrl = AppConfig.realApiBaseUrl;
        dio.options.headers['x-client-key'] = AppConfig.clientKey;
      }
      final tokenService = GetIt.instance.isRegistered<TokenService>()
          ? GetIt.instance<TokenService>()
          : TokenService();
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.realApiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'x-client-key': AppConfig.clientKey,
          },
        ),
      );
      dio.interceptors.add(
        AuthInterceptor(tokenService, refreshDio),
      );
    }

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
    baseUrl: AppConfig.useMockData
        ? AppConfig.apiBaseUrl
        : AppConfig.realApiBaseUrl,
    connectTimeout: const Duration(seconds: 50),
    receiveTimeout: const Duration(seconds: 50),
    headers: {
      'Content-Type': 'application/json',
      if (!AppConfig.useMockData) 'x-client-key': AppConfig.clientKey,
    },
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
      if (path.startsWith('/servicelisting')) {
        path = '/listings${path.substring('/servicelisting'.length)}';
      }
      if (path.startsWith('/freelance/')) {
        path = path.substring('/freelance'.length);
      }
      final method = options.method.toUpperCase();
      // debug aid for flaky matching in tests
      // ignore: avoid_print
      print('MockInterceptor: normalized $method $path');

      // Mobile Bootstrap Configuration
      if (method == 'GET' && (path == '/config/mobile' || path == '/api/config/mobile')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'activeModules': {
                'wallet': true,
                'documents': true,
                'marketplace': true,
                'procedures': false,
                'chat': true,
                'community': false,
                'committee': false,
                'freelance': false,
                'services': true,
                'settings': true,
                'profile': true,
              },
              'parcelTransportCategoryId': '019248a0-6b3a-7182-9a84-7c6d9e0f1234',
              'defaultLocale': 'fr',
              'supportedLocales': ['fr', 'en', 'ru'],
              'minAppVersion': '1.0.0',
            },
          ),
        );
      }

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
      if (method == 'GET' && _matches(path, r'^/wallet/profile/[^/]+$')) {
        final profileId = path.split('/').last;
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'id': 'wallet_mock_1',
              'externalProfileId': profileId,
              'balance': 150000.0,
              'currency': 'XOF',
              'isActive': true,
            },
            statusCode: 200,
          ),
        );
      }

      if (method == 'GET' && _matches(path, r'^/wallet/balance')) {
        final userId =
            options.queryParameters['userId'] as String? ?? 'unknown';
        final data = await MockApi.walletBalance(userId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'GET' &&
          _matches(path, r'^/wallet/transactions/profile/[^/]+$')) {
        final profileId = path.split('/').last;
        final items = await MockApi.walletTransactions(
          profileId,
          page: options.queryParameters['pageNumber'] as int? ?? 1,
        );
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'items': items,
              'totalCount': items.length,
              'pageNumber': options.queryParameters['pageNumber'] as int? ?? 1,
              'pageSize': options.queryParameters['pageSize'] as int? ?? 20,
            },
            statusCode: 200,
          ),
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

      if (method == 'POST' &&
          (_matches(path, r'^/wallet/transfer') ||
              _matches(path, r'^/wallet/transactions/transfer'))) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.walletTransfer(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'POST' &&
          (_matches(path, r'^/wallet/withdraw') ||
              _matches(path, r'^/wallet/profile/[^/]+/withdraw'))) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'transactionId': 'tx_withdraw_mock', 'status': 'Completed'},
            statusCode: 200,
          ),
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

      // ==================== MARKETPLACE ROUTES ====================
      // NOTE: literal-suffix routes (e.g. /listings/my, /listings/pending,
      // /listings/stats/my) MUST be matched before the generic
      // /listings/:id detail route below, otherwise the generic pattern
      // ('^/listings/[^/]+$') swallows them first (a previous version of
      // this file had the routes in the wrong order, and triplicated by
      // an accidental paste — this block replaces all of that).

      // GET /listings/categories or /category — must come before the generic
      // /listings/:id detail route below (same lesson as /listings/my and
      // /listings/pending: literal-suffix routes go first).
      if (method == 'GET' &&
          (_matches(path, r'^/listings/categories(?:/)?$') ||
           _matches(path, r'^/category(?:/)?$'))) {
        final data = await MockApi.getMarketplaceCategories();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /listings/my (provider's own listings)
      if (method == 'GET' && _matches(path, r'^/listings/my(?:/)?$')) {
        final data = await MockApi.getMyListings(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
          status: options.queryParameters['status'] as int?,
          isStandardService: options.queryParameters['isStandardService'] == 'true',
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /listings/pending (moderation queue)
      if (method == 'GET' && _matches(path, r'^/listings/pending(?:/)?$')) {
        final data = await MockApi.getPendingListings(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /listings/stats/my (provider dashboard)
      if (method == 'GET' && _matches(path, r'^/listings/stats/my(?:/)?$')) {
        final data = await MockApi.getMyProviderStats();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /listings/:id/approve
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/approve')) {
        final id = path.split('/')[2];
        await MockApi.approveListing(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /listings/:id/reject
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/reject')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.rejectListing(id, body['reason'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /listings/:id/suspend
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/suspend')) {
        final id = path.split('/')[2];
        await MockApi.suspendListing(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /listings/:id/images
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/images')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.addListingImage(id, body['imagePath'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // DELETE /listings/:id/images
      if (method == 'DELETE' && _matches(path, r'^/listings/[^/]+/images')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.removeListingImage(id, body['imagePath'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // PUT /listings/:id/availability
      if (method == 'PUT' && _matches(path, r'^/listings/[^/]+/availability')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        final rawSlots = body['slots'] as List<dynamic>? ?? [];
        await MockApi.setAvailability(
          id,
          rawSlots.map((e) => e as Map<String, dynamic>).toList(),
        );
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // GET /listings/:id/reviews
      if (method == 'GET' && _matches(path, r'^/listings/[^/]+/reviews(?:/)?$')) {
        final id = path.split('/')[2];
        final data = await MockApi.getListingReviews(
          listingId: id,
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /listings/:id/reviews
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/reviews(?:/)?$')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createReview(id, body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // PUT /listings/:listingId/reviews/:reviewId
      if (method == 'PUT' && _matches(path, r'^/listings/[^/]+/reviews/[^/]+$')) {
        final listingId = path.split('/')[2];
        final reviewId = path.split('/')[4];
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.updateReview(listingId, reviewId, body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // DELETE /listings/:listingId/reviews/:reviewId
      if (method == 'DELETE' && _matches(path, r'^/listings/[^/]+/reviews/[^/]+$')) {
        final reviewId = path.split('/')[4];
        await MockApi.deleteReview(path.split('/')[2], reviewId);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /listings/:listingId/reviews/:reviewId/reply
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/reviews/[^/]+/reply')) {
        final listingId = path.split('/')[2];
        final reviewId = path.split('/')[4];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.replyToReview(
          listingId,
          reviewId,
          body['replyText'] as String? ?? '',
        );
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /listings/:id/favorite
      if (method == 'POST' && _matches(path, r'^/listings/[^/]+/favorite')) {
        final id = path.split('/')[2];
        await MockApi.addFavorite(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // DELETE /listings/:id/favorite
      if (method == 'DELETE' && _matches(path, r'^/listings/[^/]+/favorite')) {
        final id = path.split('/')[2];
        await MockApi.removeFavorite(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // GET /listings/:id (detail) — must come after every literal-suffix
      // route above (my, pending, stats/my, approve, reject, suspend,
      // images, availability, reviews, favorite), since this generic
      // pattern otherwise matches all of them too.
      if (method == 'GET' && _matches(path, r'^/listings/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.getListing(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /listings (search with filters) — exact/collection match
      if (method == 'GET' && _matches(path, r'^/listings(?:/)?$')) {
        final data = await MockApi.searchListings(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
          categoryId: options.queryParameters['categoryId'] as String?,
          search: options.queryParameters['search'] as String?,
          paymentMode: options.queryParameters['paymentMode'] as int?,
          minPrice: options.queryParameters['minPrice'] as double?,
          maxPrice: options.queryParameters['maxPrice'] as double?,
          city: options.queryParameters['city'] as String?,
          country: options.queryParameters['country'] as String?,
          sortBy: options.queryParameters['sortBy'] as int?,
          userLat: options.queryParameters['userLatitude'] as double?,
          userLng: options.queryParameters['userLongitude'] as double?,
          maxDistanceKm: options.queryParameters['maxDistanceKm'] as double?,
          availableNow: options.queryParameters['availableNow'] == 'true',
          isStandardService: options.queryParameters['isStandardService'] == 'true',
          serviceCategory: options.queryParameters['serviceCategory'] as String?,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /listings (create)
      if (method == 'POST' && _matches(path, r'^/listings(?:/)?$')) {
        final data = await MockApi.createListing(
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // PUT /listings/:id (update)
      if (method == 'PUT' && _matches(path, r'^/listings/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.updateListing(
          id,
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // DELETE /listings/:id
      if (method == 'DELETE' && _matches(path, r'^/listings/[^/]+$')) {
        final id = path.split('/').last;
        await MockApi.deleteListing(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // GET /favorites/my
      if (method == 'GET' && _matches(path, r'^/favorites/my(?:/)?$')) {
        final data = await MockApi.getMyFavorites(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /service-requests/my or /service-requests/sent — must come before /service-requests/:id
      if (method == 'GET' &&
          _matches(path, r'^/service-requests/(?:my|sent)(?:/)?$')) {
        final data = await MockApi.getMySentRequests(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /service-requests/received — must come before /:id
      if (method == 'GET' && _matches(path, r'^/service-requests/received(?:/)?$')) {
        final data = await MockApi.getMyReceivedRequests(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /service-requests/:id/accept
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/accept')) {
        final id = path.split('/')[2];
        await MockApi.acceptServiceRequest(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /service-requests/:id/decline
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/decline')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.declineServiceRequest(id, body['reason'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /service-requests/:id/complete
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/complete')) {
        final id = path.split('/')[2];
        await MockApi.completeServiceRequest(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /service-requests/:id/cancel
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/cancel')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.cancelServiceRequest(id, body['reason'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /service-requests/:id/pay
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/pay')) {
        final id = path.split('/')[2];
        await MockApi.payServiceRequest(id);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 202),
        );
      }

      // POST /service-requests/:id/confirm-handover
      if (method == 'POST' &&
          _matches(path, r'^/service-requests/[^/]+/confirm-handover')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'message': 'Handover confirmed'},
            statusCode: 200,
          ),
        );
      }

      // POST /service-requests/:id/mark-in-transit
      if (method == 'POST' &&
          _matches(path, r'^/service-requests/[^/]+/mark-in-transit')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'message': 'In transit'},
            statusCode: 200,
          ),
        );
      }

      // POST /service-requests/:id/mark-arrived
      if (method == 'POST' &&
          _matches(path, r'^/service-requests/[^/]+/mark-arrived')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'message': 'Arrived at destination'},
            statusCode: 200,
          ),
        );
      }

      // POST /service-requests/:id/confirm-delivery
      if (method == 'POST' &&
          _matches(path, r'^/service-requests/[^/]+/confirm-delivery')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {'message': 'Delivery confirmed'},
            statusCode: 200,
          ),
        );
      }

      // POST /service-requests/:id/chat-thread
      if (method == 'POST' && _matches(path, r'^/service-requests/[^/]+/chat-thread')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.linkChatThread(id, body['chatThreadId'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // GET /service-requests/:id (detail) — must come after /my, /received
      if (method == 'GET' && _matches(path, r'^/service-requests/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.getServiceRequest(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /service-requests (create)
      if (method == 'POST' && _matches(path, r'^/service-requests(?:/)?$')) {
        final data = await MockApi.createServiceRequest(
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // POST /disputes
      if (method == 'POST' && _matches(path, r'^/disputes(?:/)?$')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'id': 'disp_${DateTime.now().millisecondsSinceEpoch}',
              'status': 'Open',
            },
            statusCode: 201,
          ),
        );
      }

      // POST /reports
      if (method == 'POST' && _matches(path, r'^/reports(?:/)?$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.createReport(
          targetType: body['targetType'] as int? ?? 0,
          targetId: body['targetId'] as String? ?? '',
          reason: body['reason'] as String? ?? '',
        );
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 201),
        );
      }

      // GET /reports/pending — must come before nothing else conflicts here
      if (method == 'GET' && _matches(path, r'^/reports/pending(?:/)?$')) {
        final data = await MockApi.getPendingReports(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /reports/:id/resolve
      if (method == 'POST' && _matches(path, r'^/reports/[^/]+/resolve')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.resolveReport(
          id,
          body['status'] as int? ?? 0,
          body['notes'] as String?,
        );
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // ==================== CHAT PROFILE RESOLUTION ====================
      if (method == 'GET' && _matches(path, r'^/chat/profiles/by-external/[^/]+$')) {
        final externalId = path.split('/').last;
        final data = await MockApi.chatProfileByExternal(externalId);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // ==================== KYC VERIFICATION ====================
      if (method == 'GET' && _matches(path, r'^/kyc/my-verification')) {
        final data = await MockApi.getMyKycVerification();
        return handler.resolve(
          Response(requestOptions: options, data: {'data': data}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/kyc$')) {
        final payload = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.createKycVerification(payload);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'POST' && _matches(path, r'^/kyc/[^/]+/documents')) {
        final id = path.split('/')[2];
        final docType = options.queryParameters['documentType'] ?? 'IdentityDocument';
        final data = await MockApi.uploadKycDocument(id, docType.toString());
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/kyc/[^/]+/submit')) {
        final id = path.split('/')[2];
        await MockApi.submitKycVerification(id);
        return handler.resolve(
          Response(requestOptions: options, data: {'message': 'KYC submitted'}, statusCode: 200),
        );
      }

      // ==================== WALLET FREELANCE ESCROW ====================
      if (method == 'POST' && _matches(path, r'^/transactions/freelance/hold$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.freelanceHold(body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/transactions/freelance/release$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.freelanceRelease(body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/transactions/freelance/refund$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.freelanceRefund(body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/transactions/freelance/pay$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final data = await MockApi.freelancePay(body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // ==================== FREELANCE ROUTES ====================
      // NOTE: literal-suffix routes (my, publish, close-registration, start,
      // complete, cancel, applications, check-ins, reviews) MUST be matched
      // before the generic /:id detail routes.

      // GET /job-categories
      if (method == 'GET' && _matches(path, r'^/job-categories(?:/)?$')) {
        final data = await MockApi.jobCategories();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Templates
      if (method == 'POST' && _matches(path, r'^/job-templates(?:/)?$')) {
        final data = await MockApi.createJobTemplate(
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'GET' &&
          (_matches(path, r'^/job-templates/my(?:/)?$') ||
              _matches(path, r'^/job-templates(?:/)?$'))) {
        final data = await MockApi.myJobTemplates();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'PUT' && _matches(path, r'^/job-templates/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.updateJobTemplate(
          id,
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'DELETE' && _matches(path, r'^/job-templates/[^/]+$')) {
        await MockApi.deleteJobTemplate(path.split('/').last);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // Job postings — lifecycle sub-routes BEFORE generic /:id
      if (method == 'GET' && _matches(path, r'^/job-postings/my(?:/)?$')) {
        final data = await MockApi.myJobPostings(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/publish')) {
        await MockApi.publishJobPosting(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/close-registration')) {
        await MockApi.closeJobRegistration(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/start')) {
        await MockApi.startJobPosting(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/complete')) {
        await MockApi.completeJobPosting(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/cancel')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.cancelJobPosting(id, body['reason'] as String?);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /job-postings/:jobPostingId/applications
      if (method == 'POST' && _matches(path, r'^/job-postings/[^/]+/applications$')) {
        final id = path.split('/')[2];
        final data = await MockApi.applyToJob(
          id,
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // GET /job-postings/:jobPostingId/applications
      if (method == 'GET' && _matches(path, r'^/job-postings/[^/]+/applications$')) {
        final id = path.split('/')[2];
        final data = await MockApi.jobPostingApplications(
          id,
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /job-postings/:id (detail)
      if (method == 'GET' && _matches(path, r'^/job-postings/[^/]+$')) {
        final data = await MockApi.getJobPosting(path.split('/').last);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // GET /job-postings (search)
      if (method == 'GET' && _matches(path, r'^/job-postings(?:/)?$')) {
        final data = await MockApi.searchJobPostings(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
          categoryId: options.queryParameters['categoryId'] as String?,
          search: options.queryParameters['search'] as String?,
          paymentType: options.queryParameters['paymentType'] as int?,
          minAmount: options.queryParameters['minAmount'] as double?,
          maxAmount: options.queryParameters['maxAmount'] as double?,
          city: options.queryParameters['city'] as String?,
          country: options.queryParameters['country'] as String?,
          isRemote: options.queryParameters['isRemote'] == 'true',
          userLat: options.queryParameters['userLatitude'] as double?,
          userLng: options.queryParameters['userLongitude'] as double?,
          maxDistanceKm: options.queryParameters['maxDistanceKm'] as double?,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /job-postings (create)
      if (method == 'POST' && _matches(path, r'^/job-postings(?:/)?$')) {
        final data = await MockApi.createJobPosting(
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // PUT /job-postings/:id
      if (method == 'PUT' && _matches(path, r'^/job-postings/[^/]+$')) {
        final id = path.split('/').last;
        final data = await MockApi.updateJobPosting(
          id,
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // DELETE /job-postings/:id
      if (method == 'DELETE' && _matches(path, r'^/job-postings/[^/]+$')) {
        await MockApi.deleteJobPosting(path.split('/').last);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      // Applications — literal action routes BEFORE generic /:id
      // Also support /job-applications/... prefix
      if (path.startsWith('/job-applications')) {
        path = '/applications${path.substring('/job-applications'.length)}';
      }

      if (method == 'POST' && _matches(path, r'^/applications(?:/)?$')) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final jobPostingId =
            (body['jobPostingId'] ?? body['JobPostingId'] ?? '').toString();
        final data = await MockApi.applyToJob(jobPostingId, body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'GET' &&
          _matches(path, r'^/applications/(?:my|sent|received)(?:/)?$')) {
        final data = await MockApi.myApplications(
          page: options.queryParameters['page'] as int? ?? 1,
          pageSize: options.queryParameters['pageSize'] as int? ?? 20,
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/withdraw')) {
        await MockApi.withdrawApplication(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/accept')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.acceptApplication(id, body['escrowTransactionId'] as String?);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/reject')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.rejectApplication(id, body['reason'] as String?);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/no-show')) {
        await MockApi.noShowApplication(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/complete')) {
        await MockApi.completeApplication(path.split('/')[2]);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      if (method == 'POST' && _matches(path, r'^/applications/[^/]+/chat-thread')) {
        final id = path.split('/')[2];
        final body = options.data as Map<String, dynamic>? ?? {};
        await MockApi.linkApplicationChatThread(id, body['chatThreadId'] as String? ?? '');
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // POST /applications/:id/check-ins or POST /job-check-ins/check-in
      if (method == 'POST' &&
          (_matches(path, r'^/applications/[^/]+/check-ins$') ||
              _matches(path, r'^/job-check-ins/check-in$'))) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final id = _matches(path, r'^/applications/[^/]+/check-ins$')
            ? path.split('/')[2]
            : (body['jobApplicationId'] ?? body['JobApplicationId'] ?? '')
                .toString();
        final data = await MockApi.createJobCheckIn(id, body);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      // GET /applications/:id/check-ins or GET /job-check-ins
      if (method == 'GET' &&
          (_matches(path, r'^/applications/[^/]+/check-ins$') ||
              _matches(path, r'^/job-check-ins(?:/)?$'))) {
        final id = _matches(path, r'^/applications/[^/]+/check-ins$')
            ? path.split('/')[2]
            : (options.queryParameters['applicationId'] ?? '').toString();
        final data = await MockApi.applicationCheckIns(id);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /applications/:id/reviews or POST /job-reviews
      if (method == 'POST' &&
          (_matches(path, r'^/applications/[^/]+/reviews$') ||
              _matches(path, r'^/job-reviews(?:/)?$'))) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final id = _matches(path, r'^/applications/[^/]+/reviews$')
            ? path.split('/')[2]
            : (body['jobApplicationId'] ?? body['JobApplicationId'] ?? '')
                .toString();
        await MockApi.createJobReview(id, body);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 201),
        );
      }

      // GET /applications/:id (detail)
      if (method == 'GET' && _matches(path, r'^/applications/[^/]+$')) {
        final data = await MockApi.getApplication(path.split('/').last);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // POST /check-ins/:checkInId/check-out or POST /job-check-ins/check-out
      if (method == 'POST' &&
          (_matches(path, r'^/check-ins/[^/]+/check-out') ||
              _matches(path, r'^/job-check-ins/check-out'))) {
        final body = options.data as Map<String, dynamic>? ?? {};
        final checkInId = _matches(path, r'^/check-ins/[^/]+/check-out')
            ? path.split('/')[2]
            : (body['checkInId'] ?? body['jobApplicationId'] ?? '').toString();
        await MockApi.jobCheckOut(checkInId);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 200),
        );
      }

      // GET /reputation/:subjectId
      if (method == 'GET' && _matches(path, r'^/reputation/[^/]+$')) {
        final subjectId = path.split('/').last;
        final role = int.tryParse(
              options.queryParameters['role']?.toString() ?? '',
            ) ??
            0;
        final data = await MockApi.getReputation(subjectId, role);
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
        );
      }

      // Job preferences (/job-preferences or /worker-preferences)
      if ((method == 'POST' || method == 'PUT') &&
          _matches(path, r'^/(?:job-preferences|worker-preferences)(?:/)?$')) {
        final data = await MockApi.createJobPreference(
          options.data as Map<String, dynamic>? ?? {},
        );
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 201),
        );
      }

      if (method == 'DELETE' &&
          _matches(path, r'^/(?:job-preferences|worker-preferences)(?:/[^/]+)?$')) {
        await MockApi.deleteJobPreference(path.split('/').last);
        return handler.resolve(
          Response(requestOptions: options, data: {}, statusCode: 204),
        );
      }

      if (method == 'GET' &&
          (_matches(path, r'^/job-preferences/my(?:/)?$') ||
              _matches(path, r'^/worker-preferences(?:/my)?(?:/)?$'))) {
        final data = await MockApi.myJobPreferences();
        return handler.resolve(
          Response(requestOptions: options, data: data, statusCode: 200),
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

  bool _matches(String path, String pattern) {
    // Strip query parameters before matching
    final pathWithoutQuery = path.split('?').first;
    return RegExp(pattern).hasMatch(pathWithoutQuery);
  }
}
