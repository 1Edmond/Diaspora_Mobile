import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';

class StoryViewerScreen extends StatefulWidget {
  final String storyName;
  const StoryViewerScreen({super.key, required this.storyName});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentIndex = 0;
  Timer? _autoTimer;

  static const _storyDuration = Duration(seconds: 5);
  static const _totalStories = 5;

  static const _storyContents = [
    'Photo de vacances aux Caraïbes ☀️',
    'Nouveau restaurant à Lomé 🍽️',
    'Soirée avec les amis 🎉',
    'Coucher de soleil magnifique 🌅',
    'Mon nouveau look ✨',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _startStory() {
    _progressController.forward(from: 0);
  }

  void _nextStory() {
    if (_currentIndex < _totalStories - 1) {
      setState(() => _currentIndex++);
      _progressController.forward(from: 0);
    } else {
      context.pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.forward(from: 0);
    }
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;
    if (tapX < screenWidth / 3) {
      _prevStory();
    } else if (tapX > screenWidth * 2 / 3) {
      _nextStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.storyName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    const color = AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.3),
                      const Color(0xFF1A1A2E),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _storyContents[_currentIndex],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(_totalStories, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildProgressBar(i),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentIndex + 1}/$_totalStories',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        double progress;
        if (index < _currentIndex) {
          progress = 1.0;
        } else if (index == _currentIndex) {
          progress = _progressController.value;
        } else {
          progress = 0.0;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );
  }
}
