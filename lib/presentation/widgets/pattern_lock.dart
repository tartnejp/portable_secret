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
    final cellWidth = size.width / widget.dimension;
    final cellHeight = size.height / widget.dimension;

    // Calculate all point centers
    final centers = <int, Offset>{};
    for (int i = 0; i < widget.dimension * widget.dimension; i++) {
      int row = i ~/ widget.dimension;
      int col = i % widget.dimension;
      centers[i] = Offset(col * cellWidth + cellWidth / 2, row * cellHeight + cellHeight / 2);
    }

    // Use 2x pointRadius as the touch threshold - only select if touch is within the extended circle
    final touchThreshold = widget.pointRadius * 2;

    // Find the closest point that the touch position has actually passed through
    int? closestIndex;
    double closestDistance = double.infinity;

    for (int i = 0; i < widget.dimension * widget.dimension; i++) {
      if (_selectedPoints.contains(i)) continue;
      final center = centers[i]!;
      final distance = (localPosition - center).distance;
      // Only consider points where touch is within the circle (pointRadius)
      if (distance <= touchThreshold && distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != null) {
      _selectPoint(closestIndex, centers);
    }
  }

  void _selectPoint(int index, Map<int, Offset> centers) {
    if (_selectedPoints.contains(index)) return;

    setState(() {
      // Add intermediate points between last selected point and new point
      if (_selectedPoints.isNotEmpty) {
        int lastPoint = _selectedPoints.last;
        List<int> intermediate = _getIntermediatePoints(lastPoint, index);
        for (int point in intermediate) {
          if (!_selectedPoints.contains(point)) {
            _selectedPoints.add(point);
          }
        }
      }
      _selectedPoints.add(index);
    });
    widget.onChanged(_selectedPoints.join());
  }

  /// Get intermediate points between two points on a straight line
  /// (horizontal, vertical, or diagonal)
  List<int> _getIntermediatePoints(int from, int to) {
    if (from == to) return [];

    int fromRow = from ~/ widget.dimension;
    int fromCol = from % widget.dimension;
    int toRow = to ~/ widget.dimension;
    int toCol = to % widget.dimension;

    int rowDiff = toRow - fromRow;
    int colDiff = toCol - fromCol;

    if (rowDiff == 0 && colDiff == 0) return [];

    // Check if points are on a valid line:
    // - Horizontal: rowDiff == 0
    // - Vertical: colDiff == 0
    // - Diagonal: abs(rowDiff) == abs(colDiff)
    bool isHorizontal = rowDiff == 0;
    bool isVertical = colDiff == 0;
    bool isDiagonal = rowDiff.abs() == colDiff.abs();

    if (!isHorizontal && !isVertical && !isDiagonal) {
      return []; // Not on a straight line
    }

    List<int> intermediate = [];

    int rowStep = rowDiff == 0 ? 0 : (rowDiff > 0 ? 1 : -1);
    int colStep = colDiff == 0 ? 0 : (colDiff > 0 ? 1 : -1);

    int currentRow = fromRow + rowStep;
    int currentCol = fromCol + colStep;

    while (currentRow != toRow || currentCol != toCol) {
      int pointIndex = currentRow * widget.dimension + currentCol;
      intermediate.add(pointIndex);
      currentRow += rowStep;
      currentCol += colStep;
    }

    return intermediate;
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
      // ignore: deprecated_member_use
      ..color = Colors.blue.withAlpha((255 * 0.5).round())
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final centers = <int, Offset>{};

    // Draw Points
    for (int i = 0; i < dimension * dimension; i++) {
      int row = i ~/ dimension;
      int col = i % dimension;
      final center = Offset(col * cellWidth + cellWidth / 2, row * cellHeight + cellHeight / 2);
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
      canvas.drawLine(centers[selectedPoints[i]]!, centers[selectedPoints[i + 1]]!, paintLine);
    }

    if (selectedPoints.isNotEmpty && currentDragPos != null) {
      canvas.drawLine(centers[selectedPoints.last]!, currentDragPos!, paintLine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
