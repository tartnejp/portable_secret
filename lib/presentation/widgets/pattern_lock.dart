import 'package:flutter/material.dart';

class PatternLock extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onComplete;
  final ValueChanged<String>? onError; // Callback for errors
  final int dimension;
  final double relativePadding;
  final double pointRadius;
  final bool showInput;
  final String value;

  const PatternLock({
    super.key,
    required this.onChanged,
    this.onComplete,
    this.onError,
    this.dimension = 3,
    this.relativePadding = 0.7,
    this.pointRadius = 10.0,
    this.showInput = true,
    this.value = "",
  });

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  final List<int> _selectedPoints = [];
  Offset? _currentDragPos;

  @override
  void didUpdateWidget(covariant PatternLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.isEmpty && _selectedPoints.isNotEmpty) {
      _selectedPoints.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _PatternPainter(
          selectedPoints: _selectedPoints,
          currentDragPos: _currentDragPos,
          dimension: widget.dimension,
          pointRadius: widget.pointRadius,
          showInput: widget.showInput,
        ),
        size: const Size(300, 300),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _selectedPoints.clear();
    _handleTouch(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _handleTouch(details.localPosition);
    setState(() {
      _currentDragPos = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _currentDragPos = null;
    });
    if (_selectedPoints.length > 1) {
      widget.onComplete?.call(_selectedPoints.join());
    } else if (_selectedPoints.isNotEmpty) {
      // 1 point case
      _selectedPoints.clear();
      setState(() {});
      if (widget.onError != null) {
        widget.onError!("2点以上を接続してください");
      }
    }
  }

  void _handleTouch(Offset localPosition) {
    final size = const Size(300, 300);
    // Fixed size for now, should be layout builder
    // Actually, CustomPainter size fits parent. But GestureDetector need size.
    // Let's assume size is available via LayoutBuilder or fixed.
    // For simplicity, passing fixed size 300x300 in build.

    final cellWidth = 300 / widget.dimension;
    final cellHeight = 300 / widget.dimension;

    int col = (localPosition.dx ~/ cellWidth);
    int row = (localPosition.dy ~/ cellHeight);

    if (col < 0 ||
        col >= widget.dimension ||
        row < 0 ||
        row >= widget.dimension) {
      return;
    }

    int index = row * widget.dimension + col;

    // Check if point is close to center of cell (optional, but better UX)
    // For now, if within cell, accept it.

    if (!_selectedPoints.contains(index)) {
      setState(() {
        _selectedPoints.add(index);
      });
      widget.onChanged(_selectedPoints.join());
    }
  }
}

class _PatternPainter extends CustomPainter {
  final List<int> selectedPoints;
  final Offset? currentDragPos;
  final int dimension;
  final double pointRadius;
  final bool showInput;

  _PatternPainter({
    required this.selectedPoints,
    this.currentDragPos,
    required this.dimension,
    required this.pointRadius,
    required this.showInput,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / dimension;
    final cellHeight = size.height / dimension;

    final paintNormal = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final paintSelected = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final centers = <int, Offset>{};

    // Draw Points
    for (int i = 0; i < dimension * dimension; i++) {
      int row = i ~/ dimension;
      int col = i % dimension;
      final center = Offset(
        col * cellWidth + cellWidth / 2,
        row * cellHeight + cellHeight / 2,
      );
      centers[i] = center;

      canvas.drawCircle(
        center,
        pointRadius,
        selectedPoints.contains(i) && showInput ? paintSelected : paintNormal,
      );
    }

    if (!showInput) return;

    // Draw Lines
    for (int i = 0; i < selectedPoints.length - 1; i++) {
      canvas.drawLine(
        centers[selectedPoints[i]]!,
        centers[selectedPoints[i + 1]]!,
        paintLine,
      );
    }

    if (selectedPoints.isNotEmpty && currentDragPos != null) {
      canvas.drawLine(
        centers[selectedPoints.last]!,
        currentDragPos!,
        paintLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
