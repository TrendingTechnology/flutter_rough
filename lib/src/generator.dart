import 'config.dart';
import 'core.dart';
import 'entities.dart';
import 'filler.dart';
import 'geometry.dart';
import 'renderer.dart';

class Generator {
  final DrawConfig config;
  final Filler filler;

  Generator(this.config, this.filler);

  Drawable _buildDrawable(OpSet drawSets, [List<PointD> fillPoints]) {
    final List<OpSet> sets = [];
    if (fillPoints != null) {
      sets.add(filler.fill(fillPoints));
    }
    sets.add(drawSets);
    return Drawable(sets: sets, options: config);
  }

  Drawable line(double x1, double y1, double x2, double y2) {
    return _buildDrawable(OpSetBuilder.buildLine(x1, y1, x2, y2, config));
  }

  Drawable rectangle(double x, double y, double width, double height) {
    List<PointD> points = [PointD(x, y), PointD(x + width, y), PointD(x + width, y + height), PointD(x, y + height)];
    OpSet outline = OpSetBuilder.buildPolygon(points, config);
    return _buildDrawable(outline, points);
  }

  Drawable ellipse(double x, double y, double width, double height) {
    EllipseParams ellipseParams = generateEllipseParams(width, height, config);
    EllipseResult ellipseResponse = ellipseWithParams(x, y, config, ellipseParams);
    return _buildDrawable(ellipseResponse.opset, ellipseResponse.estimatedPoints);
  }

  Drawable circle(double x, double y, double diameter) {
    Drawable ret = ellipse(x, y, diameter, diameter);
    return ret;
  }

  Drawable linearPath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.linearPath(points, true, config));
  }

  Drawable arc(double x, double y, double width, double height, double start, double stop, [bool closed = false]) {
    OpSet outline = OpSetBuilder.arc(PointD(x, y), width, height, start, stop, closed, true, config);
    List<PointD> fillPoints = OpSetBuilder.arcPolygon(PointD(x, y), width, height, start, stop, config);
    return _buildDrawable(outline, fillPoints);
  }

  Drawable curvePath(List<PointD> points) {
    return _buildDrawable(OpSetBuilder.curve(points, config));
  }

  Drawable polygon(List<PointD> points) {
    var path = OpSetBuilder.linearPath(points, true, config);
    return _buildDrawable(path, points);
  }
}
