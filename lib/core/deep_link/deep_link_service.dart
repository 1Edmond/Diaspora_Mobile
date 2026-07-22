import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  Uri? initialUri;
  Stream<Uri> get uriStream => _controller.stream;

  Future<void> initialize() async {
    initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _controller.add(initialUri!);
    }
    _appLinks.uriLinkStream.listen(_controller.add);
  }

  void dispose() => _controller.close();
}
