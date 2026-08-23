import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'orbital_data.dart';
import 'orbital_arc_painter.dart';
import 'orbital_description_panel.dart';

class OrbitalFab extends StatefulWidget {
  final List<OrbitalItem> items;
  final Color fabColor;
  final IconData fabIcon;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final VoidCallback? onLogout;

  const OrbitalFab({
    super.key,
    required this.items,
    this.fabColor = const Color(0xFF0033A0),
    this.fabIcon = Icons.dashboard_outlined,
    this.onOpen,
    this.onClose,
    this.onLogout,
  });

  @override
  State<OrbitalFab> createState() => _OrbitalFabState();
}

class _OrbitalFabState extends State<OrbitalFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _anim;

  bool _isOpen = false;
  bool _isClosing = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _open() {
    if (_isOpen) return;
    setState(() {
      _isOpen = true;
      _isClosing = false;
      _selectedIndex = 0;
    });
    _animController.forward(from: 0).then((_) {
      if (mounted) setState(() {});
    });
    widget.onOpen?.call();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isClosing = true);
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isOpen = false;
          _isClosing = false;
        });
      }
    });
    widget.onClose?.call();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _onItemSelected(int index) {
    if (index == _selectedIndex || _isClosing) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildFabButton(),
        if (_isOpen) _buildOverlay(),
      ],
    );
  }

  Widget _buildFabButton() {
    return Positioned(
      right: 20,
      bottom: 90,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.fabColor,
                widget.fabColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.fabColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isOpen ? Icons.close : widget.fabIcon,
              key: ValueKey(_isOpen),
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final opacity = _isClosing ? _anim.value : _anim.value;
          return Opacity(
            opacity: opacity,
            child: _buildFullScreenContent(),
          );
        },
      ),
    );
  }

  Widget _buildFullScreenContent() {
    final selectedItem = widget.items[_selectedIndex];

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _isClosing
                          ? OrbitalDescriptionPanel(
                              item: selectedItem,
                              animation: const AlwaysStoppedAnimation(1.0),
                              onLogout: widget.onLogout,
                            )
                          : OrbitalDescriptionPanel(
                              item: selectedItem,
                              animation: _anim,
                              onDiscover: () {
                                selectedItem.onTap?.call();
                                _close();
                              },
                              onLogout: widget.onLogout,
                            ),
                    ),
                    Expanded(
                      flex: 5,
                      child: _buildOrbitalArc(),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrbitalArc() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const topMargin = 40.0;
        const bottomMargin = 20.0;
        final usableHeight = constraints.maxHeight - topMargin - bottomMargin;

        final centerX = constraints.maxWidth * 0.12;
        final centerY = topMargin + usableHeight * 0.5;
        final radius = usableHeight * 0.44;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: OrbitalArcPainter(
                items: widget.items,
                selectedIndex: _selectedIndex,
                centerX: centerX,
                centerY: centerY,
                radius: radius,
                animation: _anim.value,
              ),
            ),
            ..._buildArcItems(centerX, centerY, radius, constraints),
          ],
        );
      },
    );
  }

  List<Widget> _buildArcItems(
    double centerX,
    double centerY,
    double radius,
    BoxConstraints constraints,
  ) {
    final itemCount = widget.items.length;

    // Use linear vertical spacing for uniform visual distribution
    const topMargin = 50.0;
    const bottomMargin = 50.0;
    final usableHeight = constraints.maxHeight - topMargin - bottomMargin;

    return List.generate(itemCount, (index) {
      final t = itemCount <= 1 ? 0.5 : index / (itemCount - 1);

      // Uniform vertical position
      final y = topMargin + usableHeight * t;

      // X follows the arc curve: items curve inward toward the center
      final arcOffset = math.sin(t * math.pi) * radius * 0.3;
      final x = centerX + arcOffset;

      final clampedX = x.clamp(0.0, constraints.maxWidth - 52);
      final clampedY = y.clamp(0.0, constraints.maxHeight - 70);

      final isSelected = index == _selectedIndex;
      final item = widget.items[index];

      // Stagger animation
      double itemOpacity;
      double slideOffset;
      final delay = index / itemCount;

      if (_isClosing) {
        final closeProgress = math.max(
          0.0,
          math.min(1.0, (1.0 - _anim.value - delay * 0.5) / 0.5),
        );
        itemOpacity = 1.0 - closeProgress;
        slideOffset = 30 * closeProgress;
      } else {
        final openProgress = math.max(
          0.0,
          math.min(1.0, (_anim.value - delay * 0.5) / 0.5),
        );
        itemOpacity = openProgress;
        slideOffset = 30 * (1 - openProgress);
      }

      return Positioned(
        left: clampedX - 26,
        top: clampedY - 26 - (isSelected ? 10 : 0) + slideOffset,
        child: Opacity(
          opacity: itemOpacity,
          child: GestureDetector(
            onTap: () => _onItemSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 56 : 52,
                  height: isSelected ? 56 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isSelected
                        ? Border.all(color: item.color, width: 2.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(
                          alpha: isSelected ? 0.35 : 0.12,
                        ),
                        blurRadius: isSelected ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: isSelected ? 26 : 24,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? item.color : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fermer',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 18, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
