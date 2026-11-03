import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Grid yang menyamakan tinggi SEMUA sel (satu tinggi per kelompok): tinggi = sel tertinggi pada lebar kolom itu
/// (teks membungkus, tidak dipotong), atau [minHeight] bila lebih besar. Jumlah kolom tetap.
class EqualHeightGrid extends MultiChildRenderObjectWidget {
  const EqualHeightGrid({super.key, required this.columns, required super.children, this.spacing = 12, this.minHeight = 0});
  final int columns;
  final double spacing;
  final double minHeight;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderEqualHeightGrid(columns, spacing, minHeight);

  @override
  void updateRenderObject(BuildContext context, covariant RenderEqualHeightGrid renderObject) {
    renderObject
      ..columns = columns
      ..spacing = spacing
      ..minHeight = minHeight;
  }
}

class EqualGridParentData extends ContainerBoxParentData<RenderBox> {}

class RenderEqualHeightGrid extends RenderBox with ContainerRenderObjectMixin<RenderBox, EqualGridParentData>, RenderBoxContainerDefaultsMixin<RenderBox, EqualGridParentData> {
  RenderEqualHeightGrid(this._columns, this._spacing, this._minHeight);
  int _columns;
  double _spacing;
  double _minHeight;

  set columns(int v) {
    if (v != _columns) {
      _columns = v;
      markNeedsLayout();
    }
  }

  set spacing(double v) {
    if (v != _spacing) {
      _spacing = v;
      markNeedsLayout();
    }
  }

  set minHeight(double v) {
    if (v != _minHeight) {
      _minHeight = v;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! EqualGridParentData) child.parentData = EqualGridParentData();
  }

  double _cellWidth(double w) => (w - _spacing * (_columns - 1)) / _columns;

  int get _count {
    var n = 0;
    for (var c = firstChild; c != null; c = childAfter(c)) {
      n++;
    }
    return n;
  }

  double _cellHeight(double width) {
    var h = _minHeight;
    final cw = _cellWidth(width);
    for (var c = firstChild; c != null; c = childAfter(c)) {
      h = math.max(h, c.getMaxIntrinsicHeight(cw));
    }
    return h;
  }

  double _totalHeight(double width) {
    final rows = (_count / _columns).ceil();
    return rows == 0 ? 0 : rows * _cellHeight(width) + (rows - 1) * _spacing;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _totalHeight(width);
  @override
  double computeMaxIntrinsicHeight(double width) => _totalHeight(width);
  @override
  double computeMinIntrinsicWidth(double height) => 0;
  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(Size(constraints.maxWidth, _totalHeight(constraints.maxWidth)));

  @override
  void performLayout() {
    final w = constraints.maxWidth;
    final cw = _cellWidth(w);
    final ch = _cellHeight(w);
    var i = 0;
    for (var c = firstChild; c != null; c = childAfter(c), i++) {
      c.layout(BoxConstraints.tightFor(width: cw, height: ch), parentUsesSize: false);
      (c.parentData! as EqualGridParentData).offset = Offset((i % _columns) * (cw + _spacing), (i ~/ _columns) * (ch + _spacing));
    }
    size = constraints.constrain(Size(w, _totalHeight(w)));
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => defaultHitTestChildren(result, position: position);
}
