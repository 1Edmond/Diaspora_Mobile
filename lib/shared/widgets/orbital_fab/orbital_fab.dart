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
  final ScrollController _itemsScrollController = ScrollController();

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
    _itemsScrollController.dispose();
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
    _scrollToSelected();
  }

  void _scrollToSelected() {
    if (!_itemsScrollController.hasClients) return;
    final target = _selectedIndex * _itemBlockHeight;
    final viewport = _itemsScrollController.position.viewportDimension;
    final maxScroll = _itemsScrollController.position.maxScrollExtent;
    final offset = (target - viewport / 2 + _itemBlockHeight / 2)
        .clamp(0.0, maxScroll)
        .toDouble();
    _itemsScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
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

  static const double _itemBlockHeight = 100.0;
  static const double _arcLeftAnchor = 40.0;
  static const double _arcHorizontalRadius = 55.0;

  double _arcXOffset(int index, int itemCount) {
    final t = itemCount <= 1 ? 0.5 : index / (itemCount - 1);
    return math.sin(t * math.pi) * _arcHorizontalRadius;
  }

  Widget _buildOrbitalArc() {
    final itemCount = widget.items.length;
    final totalHeight = itemCount * _itemBlockHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SingleChildScrollView(
          controller: _itemsScrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: math.max(totalHeight, constraints.maxHeight),
            width: width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ScrollableArcPainter(
                        itemCount: itemCount,
                        selectedIndex: _selectedIndex,
                        centerX: _arcLeftAnchor,
                        itemBlockHeight: _itemBlockHeight,
                        horizontalRadius: _arcHorizontalRadius,
                        animation: _anim.value,
                      ),
                    ),
                  ),
                ),
                ..._buildArcItems(width),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildArcItems(double width) {
    final itemCount = widget.items.length;

    return List.generate(itemCount, (index) {
      final isSelected = index == _selectedIndex;
      final item = widget.items[index];

      // Stagger animation
      double itemOpacity;
      double slideOffset;
      final delay = itemCount <= 1 ? 0.0 : index / itemCount;

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

      final centerX = _arcLeftAnchor + _arcXOffset(index, itemCount);
      final left = (centerX - 26).clamp(0.0, width - 52);
      final top = index * _itemBlockHeight + 24 + slideOffset;

      return Positioned(
        left: left,
        top: top,
        child: Opacity(
          opacity: itemOpacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
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
