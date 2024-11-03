library duration_picker;

import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);

const double _kDurationPickerWidthPortrait = 328.0;
const double _kDurationPickerWidthLandscape = 512.0;

const double _kDurationPickerHeightPortrait = 380.0;
const double _kDurationPickerHeightLandscape = 304.0;

const double _kTwoPi = 2 * math.pi;
const double _kPiByTwo = math.pi / 2;

const double _kCircleTop = _kPiByTwo;
const double _radPerMinute = _kTwoPi / 60;

/// Use [DialPainter] to style the durationPicker to your style.
class DialPainter extends CustomPainter {
  const DialPainter(
      {required this.context,
      required this.labels,
      required this.backgroundColor,
      required this.accentColor,
      required this.theta,
      required this.textDirection,
      required this.selectedValue,
      required this.pct,
      required this.baseUnitMultiplier,
      required this.baseUnitHand,
      required this.baseUnit,
      this.ringWidth});

  final List<TextPainter> labels;
  final Color? backgroundColor;
  final Color accentColor;
  final double theta;
  final ui.TextDirection textDirection;
  final int? selectedValue;
  final BuildContext context;
  final double? ringWidth;

  final double pct;
  final int baseUnitMultiplier;
  final int baseUnitHand;
  final BaseUnit baseUnit;

  @override
  void paint(Canvas canvas, Size size) {
    const epsilon = .001;
    const sweep = _kTwoPi - epsilon;
    const startAngle = -math.pi / 2.0;

    final radius = size.shortestSide * 0.75;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    var pctTheta = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;
    var shadowOffSet = Offset((size.width / 2.0), (size.height / 2.0));

    var outerCircleInnerShadow = radius + 5;
    // if (ringWidth != null) {
    //   outerCircleInnerShadow = radius - (ringWidth! * 2);
    // }
    var outerCircleInnerShadowOffSet =
        Offset((size.width / 2.0), (size.height / 2.0));
    var gradiee = ui.Gradient.radial(center, radius / .8,
        [Colors.white, Color.fromRGBO(10, 10, 10, 1)], [0.775, 0.999]);
    var shadedPaint = Paint()
      ..color = Color.fromRGBO(10, 0, 0, 0.9)
      ..shader = gradiee;
    canvas.drawCircle(
        outerCircleInnerShadowOffSet, outerCircleInnerShadow, shadedPaint);

    // // Draw the background outer ring
    // canvas.drawCircle(centerPoint, radius, Paint()..color = Colors.white70);

    // Draw a translucent circle for every secondary unit
    for (var i = 0; i < baseUnitMultiplier; i = i + 1) {
      canvas.drawCircle(
        centerPoint,
        radius,
        Paint()..color = accentColor.withOpacity((i == 0) ? 0.3 : 0.1),
      );
    }

    print('Outer is ' + radius.toString());

    //Inner circle shadow
    var innerCircleRadius = radius * 0.88;
    if (ringWidth != null) {
      innerCircleRadius = radius - (ringWidth! * 2);
    }
    shadowOffSet = Offset((size.width / 2.0) + 4, (size.height / 2.0) + 4);
    canvas.drawCircle(
        shadowOffSet, innerCircleRadius, Paint()..color = Colors.black38);

    // Draw the inner background circle
    canvas.drawCircle(centerPoint, innerCircleRadius,
        Paint()..color = Color.fromRGBO(240, 240, 240, 1));

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double radius) {
      return center +
          Offset(radius * math.cos(theta), -radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    // final handlePaint = Paint()..color = Colors.purple;
    final handlePaint = Paint()..color = Color.fromRGBO(4, 42, 43, 1);
    final handlePoint = getOffsetForTheta(theta, radius - 23.0);
    canvas.drawCircle(handlePoint, 25.0, handlePaint);

    // Get the appropriate base unit string
    String getBaseUnitString() {
      switch (baseUnit) {
        case BaseUnit.millisecond:
          return 'ms.';
        case BaseUnit.second:
          return 'sec.';
        case BaseUnit.minute:
          return 'minaa.';
        case BaseUnit.hour:
          return 'hr.';
      }
    }

    // Get the appropriate secondary unit string
    String getSecondaryUnitString() {
      switch (baseUnit) {
        case BaseUnit.millisecond:
          return 's ';
        case BaseUnit.second:
          return 'm ';
        case BaseUnit.minute:
          return 'huii ';
        case BaseUnit.hour:
          return 'd ';
      }
    }

    // Draw the Text in the center of the circle which displays the duration string
    // final secondaryUnits = (baseUnitMultiplier == 0)
    //     ? ''
    //     : '$baseUnitMultiplier${getSecondaryUnitString()} ';
    // final baseUnits = '$baseUnitHand';

    // final textDurationValuePainter = TextPainter(
    //   textAlign: TextAlign.center,
    //   text: TextSpan(
    //     text: '$secondaryUnits$baseUnits',
    //     style: Theme.of(context)
    //         .textTheme
    //         .headline2!
    //         .copyWith(fontSize: size.shortestSide * 0.15),
    //   ),
    //   textDirection: TextDirection.ltr,
    // )..layout();
    // final middleForValueText = Offset(
    //   centerPoint.dx - (textDurationValuePainter.width / 2),
    //   centerPoint.dy - textDurationValuePainter.height / 2,
    // );
    // textDurationValuePainter.paint(canvas, middleForValueText);

    // final textMinPainter = TextPainter(
    //   textAlign: TextAlign.center,
    //   text: TextSpan(
    //     text: getBaseUnitString(), //th: ${theta}',
    //     style: Theme.of(context).textTheme.bodyText2,
    //   ),
    //   textDirection: TextDirection.ltr,
    // )..layout();
    // textMinPainter.paint(
    //   canvas,
    //   Offset(
    //     centerPoint.dx - (textMinPainter.width / 2),
    //     centerPoint.dy +
    //         (textDurationValuePainter.height / 2) -
    //         textMinPainter.height / 2,
    //   ),
    // );

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    final elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.3)
      ..isAntiAlias = true
      ..strokeWidth = radius * 0.12;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius - radius * 0.12 / 2,
      ),
      startAngle,
      sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = _kPiByTwo;

      for (final label in labels) {
        final labelOffset = Offset(-label.width / 2.0, -label.height / 2.0);

        label.paint(
            canvas, getOffsetForTheta(labelTheta, radius - 25.0) + labelOffset);

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  _Dial(
      {required this.duration,
      required this.onChanged,
      this.backgroundColor,
      this.baseUnit = BaseUnit.minute,
      this.snapToMins = 1.0,
      this.ringWidth = 25.0,
      this.duratationTextStyle,
      Key? key})
      : super(key: key);

  NumberFormat formatter = new NumberFormat("00");
  Duration duration;
  final ValueChanged<Duration> onChanged;
  final BaseUnit baseUnit;
  final Color? backgroundColor;
  final double? ringWidth;
  final TextStyle? duratationTextStyle;

  /// The resolution of mins of the dial, i.e. if snapToMins = 5.0, only durations of 5min intervals will be selectable.
  final double? snapToMins;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  late TextEditingController _hourInputController;
  late TextEditingController _minuteInputController;
  @override
  void initState() {
    super.initState();
    initializeHourAndMinuteControllers(widget.duration, isFirstRun: true);

    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(
      begin: _getThetaForDuration(widget.duration, widget.baseUnit),
    );
    _theta = _thetaTween.animate(
      CurvedAnimation(parent: _thetaController, curve: Curves.fastOutSlowIn),
    )..addListener(() => setState(() {}));
    _thetaController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _secondaryUnitValue = _secondaryUnitHand();
        _baseUnitValue = _baseUnitHand();
        setState(() {});
      }
    });

    _turningAngle = _kPiByTwo - _turningAngleFactor() * _kTwoPi;
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
  }

  late ThemeData themeData;
  MaterialLocalizations? localizations;
  MediaQueryData? media;

  void initializeHourAndMinuteControllers(
    Duration duration, {
    bool isFirstRun = false,
  }) {
    if (!isFirstRun) {
      _hourInputController.dispose();
      _minuteInputController.dispose();
    }
    _hourInputController = TextEditingController(
      text: duration.inHours.toString(),
    );
    _hourInputController.addListener(() {
      int textBoxHourValue =
          int.tryParse(_hourInputController.value.text) ?? duration.inHours;
      if (_hourInputController.value.text.isEmpty) {
        textBoxHourValue = 0;
      }
      int textBoxMinuteValue =
          int.tryParse(_minuteInputController.value.text) ??
              duration.inMinutes % 60;
      if (_minuteInputController.value.text.isEmpty) {
        textBoxMinuteValue = 0;
      }

      final int dialHourValue = _secondaryUnitHand();
      final int dialMinValue = _baseUnitHand();
      if (textBoxHourValue != dialHourValue ||
          textBoxMinuteValue != dialMinValue) {
        final updatedDuration =
            Duration(hours: textBoxHourValue, minutes: dialMinValue);
        final thetaVal = _getThetaForDuration(updatedDuration, widget.baseUnit);

        widget.onChanged(updatedDuration);
        setState(() {
          widget.duration = updatedDuration;
          _baseUnitValue = textBoxMinuteValue;
          _secondaryUnitValue = dialHourValue;
          final box = context.findRenderObject() as RenderBox?;
          _center = box?.size.center(Offset.zero);
          _thetaTween
            ..begin = thetaVal
            ..end = thetaVal;
          _turningAngle =
              _kPiByTwo - (updatedDuration.inMinutes * _radPerMinute);
        });
      }
    });
    _minuteInputController = TextEditingController(
      text: widget.formatter.format(duration.inMinutes % 60),
    );

    _minuteInputController.addListener(() {
      int textBoxHourValue =
          int.tryParse(_hourInputController.value.text) ?? duration.inHours;
      if (_hourInputController.value.text.isEmpty) {
        textBoxHourValue = 0;
      }
      int textBoxMinuteValue =
          int.tryParse(_minuteInputController.value.text) ??
              duration.inMinutes % 60;
      if (_minuteInputController.value.text.isEmpty) {
        textBoxMinuteValue = 0;
      }
      int dialHourValue = _secondaryUnitHand();
      final int dialMinValue = _baseUnitHand();
      if (textBoxHourValue != dialHourValue ||
          textBoxMinuteValue != dialMinValue) {
        if (textBoxMinuteValue >= Duration.minutesPerHour) {
          dialHourValue = 0;
        }

        final updatedDuration =
            Duration(hours: dialHourValue, minutes: textBoxMinuteValue);
        _hourInputController.text =
            widget.formatter.format(updatedDuration.inHours);
        _minuteInputController.text = widget.formatter
            .format(updatedDuration.inMinutes % Duration.minutesPerHour);

        double thetaVal =
            _getThetaForDuration(updatedDuration, widget.baseUnit);
        thetaVal = (updatedDuration.inHours * _kTwoPi) + thetaVal;
        widget.onChanged(updatedDuration);
        setState(() {
          widget.duration = updatedDuration;
          _baseUnitValue = textBoxMinuteValue;
          _secondaryUnitValue = dialHourValue;
          final box = context.findRenderObject() as RenderBox?;
          _center = box?.size.center(Offset.zero);
          _thetaTween
            ..begin = thetaVal
            ..end = thetaVal;

          _turningAngle =
              _kPiByTwo - (updatedDuration.inMinutes * _radPerMinute);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void dispose() {
    _thetaController.dispose();
    _hourInputController.dispose();
    _minuteInputController.dispose();
    super.dispose();
  }

  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late AnimationController _thetaController;

  final double _pct = 0.0;
  int _secondaryUnitValue = 0;
  bool _dragging = false;
  int _baseUnitValue = 0;
  double _turningAngle = 0.0;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta =
        _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController
      ..value = 0.0
      ..forward();
  }

  // Converts the duration to the chosen base unit. For example, for base unit minutes, this gets the number of minutes
  // in the duration
  int _getDurationInBaseUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds;
      case BaseUnit.second:
        return duration.inSeconds;
      case BaseUnit.minute:
        return duration.inMinutes;
      case BaseUnit.hour:
        return duration.inHours;
    }
  }

  // Converts the duration to the chosen secondary unit. For example, for base unit minutes, this gets the number
  // of hours in the duration
  int _getDurationInSecondaryUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inSeconds;
      case BaseUnit.second:
        return duration.inMinutes;
      case BaseUnit.minute:
        return duration.inHours;
      case BaseUnit.hour:
        return duration.inDays;
    }
  }

  // Gets the relation between the base unit and the secondary unit, which is the unit just greater than the base unit.
  // For example if the base unit is second, it will get the number of seconds in a minute
  int _getBaseUnitToSecondaryUnitFactor(BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return Duration.millisecondsPerSecond;
      case BaseUnit.second:
        return Duration.secondsPerMinute;
      case BaseUnit.minute:
        return Duration.minutesPerHour;
      case BaseUnit.hour:
        return Duration.hoursPerDay;
    }
  }

  double _getThetaForDuration(Duration duration, BaseUnit baseUnit) {
    final int baseUnits = _getDurationInBaseUnits(duration, baseUnit);
    final int baseToSecondaryFactor =
        _getBaseUnitToSecondaryUnitFactor(baseUnit);

    return (_kPiByTwo -
            (baseUnits % baseToSecondaryFactor) /
                baseToSecondaryFactor.toDouble() *
                _kTwoPi) %
        _kTwoPi;
  }

  double _turningAngleFactor() {
    return _getDurationInBaseUnits(widget.duration, widget.baseUnit) /
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  // TODO: Fix snap to mins
  Duration _getTimeForTheta(double theta) {
    return _angleToDuration(_turningAngle);
    // var fractionalRotation = (0.25 - (theta / _kTwoPi));
    // fractionalRotation = fractionalRotation < 0
    //    ? 1 - fractionalRotation.abs()
    //    : fractionalRotation;
    // var mins = (fractionalRotation * 60).round();
    // debugPrint('Mins0: ${widget.snapToMins }');
    // if (widget.snapToMins != null) {
    //   debugPrint('Mins1: $mins');
    //  mins = ((mins / widget.snapToMins!).round() * widget.snapToMins!).round();
    //   debugPrint('Mins2: $mins');
    // }
    // if (mins == 60) {
    //  // _snappedHours = _hours + 1;
    //  // mins = 0;
    //  return new Duration(hours: 1, minutes: mins);
    // } else {
    //  // _snappedHours = _hours;
    //  return new Duration(hours: _hours, minutes: mins);
    // }
  }

  Duration _notifyOnChangedIfNeeded() {
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
    final d = _angleToDuration(_turningAngle);
    widget.onChanged(d);
    setState(() {
      initializeHourAndMinuteControllers(d);
    });

    return d;
  }

  void _updateThetaForPan() {
    setState(() {
      final offset = _position! - _center!;
      final angle = (math.atan2(offset.dx, offset.dy) - _kPiByTwo) % _kTwoPi;

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      if (angle >= _kCircleTop &&
          _theta.value <= _kCircleTop &&
          _theta.value >= 0.1 && // to allow the radians sign change at 15mins.
          _secondaryUnitValue == 0) return;

      _thetaTween
        ..begin = angle
        ..end = angle;
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final oldTheta = _theta.value;

    _position = _position! + details.delta;
    // _position! += details.delta;
    _updateThetaForPan();
    final newTheta = _theta.value;

    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _secondaryUnitHand() {
    return _getDurationInSecondaryUnits(widget.duration, widget.baseUnit);
  }

  int _baseUnitHand() {
    // Result is in [0; num base units in secondary unit - 1], even if overall time is >= 1 secondary unit
    return _getDurationInBaseUnits(widget.duration, widget.baseUnit) %
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  Duration _angleToDuration(double angle) {
    return _baseUnitToDuration(_angleToBaseUnit(angle));
  }

  Duration _baseUnitToDuration(double baseUnitValue) {
    final int unitFactor = _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return Duration(
          seconds: baseUnitValue ~/ unitFactor,
          milliseconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.second:
        return Duration(
          minutes: baseUnitValue ~/ unitFactor,
          seconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.minute:
        return Duration(
          hours: baseUnitValue ~/ unitFactor,
          minutes: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.hour:
        return Duration(
          days: baseUnitValue ~/ unitFactor,
          hours: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
    }
  }

  String _durationToBaseUnitString(Duration duration) {
    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds.toString();
      case BaseUnit.second:
        return duration.inSeconds.toString();
      case BaseUnit.minute:
        return duration.inMinutes.toString();
      case BaseUnit.hour:
        return duration.inHours.toString();
    }
  }

  double _angleToBaseUnit(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    final dialAngle = _kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle /
        _kTwoPi *
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  void _updateTurningAngle(double oldTheta, double newTheta) {
    // Register any angle by which the user has turned the dial.
    //
    // The resulting turning angle fully captures the state of the dial,
    // including multiple turns (= full hours). The [_turningAngle] is in
    // mathematical coordinate system, i.e. 3-o-clock position being zero, and
    // increasing counter clock wise.

    // From positive to negative (in mathematical COS)
    if (newTheta > 1.5 * math.pi && oldTheta < 0.5 * math.pi) {
      _turningAngle = _turningAngle - ((_kTwoPi - newTheta) + oldTheta);
    }
    // From negative to positive (in mathematical COS)
    else if (newTheta < 0.5 * math.pi && oldTheta > 1.5 * math.pi) {
      _turningAngle = _turningAngle + ((_kTwoPi - oldTheta) + newTheta);
    } else {
      _turningAngle = _turningAngle + (newTheta - oldTheta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _animateTo(_getThetaForDuration(widget.duration, widget.baseUnit));
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();

    _animateTo(
      _getThetaForDuration(_getTimeForTheta(_theta.value), widget.baseUnit),
    );
    _dragging = false;
    _position = null;
    _center = null;
  }

  List<TextPainter> _buildBaseUnitLabels(TextTheme textTheme) {
    // final style = textTheme.subtitle1;

    var baseUnitMarkerValues = <Duration>[];

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        const int interval = 100;
        const int factor = Duration.millisecondsPerSecond;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(milliseconds: index * interval),
        );
        break;
      case BaseUnit.second:
        const int interval = 5;
        const int factor = Duration.secondsPerMinute;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(seconds: index * interval),
        );
        break;
      case BaseUnit.minute:
        const int interval = 5;
        const int factor = Duration.minutesPerHour;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(minutes: index * interval),
        );
        break;
      case BaseUnit.hour:
        const int interval = 3;
        const int factor = Duration.hoursPerDay;
        const int length = factor ~/ interval;
        baseUnitMarkerValues =
            List.generate(length, (index) => Duration(hours: index * interval));
        break;
    }

    final labels = <TextPainter>[];
    for (var duration in baseUnitMarkerValues) {
      var painter = TextPainter(
        text: TextSpan(
          style: TextStyle(
              fontSize: 15,
              // fontFamily: 'Rubik',
              fontWeight: FontWeight.w300,
              color: Color.fromRGBO(15, 15, 15, 0.2)),
          text: '⚫',
          // text: _durationToBaseUnitString(duration)
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor = this.widget.backgroundColor;
    if (backgroundColor == null) {
      switch (themeData.brightness) {
        case Brightness.light:
          backgroundColor = Colors.grey[200];
          break;
        case Brightness.dark:
          backgroundColor = themeData.scaffoldBackgroundColor;
          break;
      }
    }

    final theme = Theme.of(context);

    int? selectedDialValue;
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();

    return Stack(
      children: [
        Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: GestureDetector(
                excludeFromSemantics: true,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                onTapUp: _handleTapUp,
                child: CustomPaint(
                  painter: DialPainter(
                      pct: _pct,
                      baseUnitMultiplier: _secondaryUnitValue,
                      baseUnitHand: _baseUnitValue,
                      baseUnit: widget.baseUnit,
                      context: context,
                      selectedValue: selectedDialValue,
                      labels: _buildBaseUnitLabels(theme.textTheme),
                      backgroundColor: backgroundColor,
                      accentColor: themeData.colorScheme.secondary,
                      theta: _theta.value,
                      textDirection: Directionality.of(context),
                      ringWidth: this.widget.ringWidth),
                )),
          ),
        ),
        Center(
          child: SizedBox(
            height: 85,
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 50,
                  child: Column(
                    children: [
                      TextField(
                        style: widget.duratationTextStyle,
                        textAlign: ui.TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: _hourInputController,
                      ),
                      const Text("Hour"),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Text(
                    ":",
                    style: widget.duratationTextStyle,
                  ),
                ),
                SizedBox(
                  height: 120,
                  width: 50,
                  child: Column(
                    children: [
                      TextField(
                        style: widget.duratationTextStyle,
                        textAlign: ui.TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onTapOutside: (PointerDownEvent event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: _minuteInputController,
                      ),
                      const Text("Min"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class DurationPickerDialog extends StatefulWidget {
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const DurationPickerDialog({
    Key? key,
    required this.initialTime,
    this.baseUnit = BaseUnit.minute,
    this.snapToMins = 1.0,
    this.decoration,
  }) : super(key: key);

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final BaseUnit baseUnit;
  final double snapToMins;
  final BoxDecoration? decoration;

  @override
  DurationPickerDialogState createState() => DurationPickerDialogState();
}

class DurationPickerDialogState extends State<DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  Duration? get selectedDuration => _selectedDuration;
  Duration? _selectedDuration;

  late MaterialLocalizations localizations;

  void _handleTimeChanged(Duration value) {
    setState(() {
      _selectedDuration = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDuration);
  }

  int get Hours {
    return _selectedDuration?.inHours ?? 0;
  }

  int get Minutes {
    return (_selectedDuration?.inMinutes ?? 0) % 60;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);
    final boxDecoration =
        widget.decoration ?? BoxDecoration(color: theme.dialogBackgroundColor);
    final Widget picker = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: _Dial(
          duration: _selectedDuration!,
          onChanged: _handleTimeChanged,
          baseUnit: widget.baseUnit,
          snapToMins: widget.snapToMins,
        ),
      ),
    );

    final Widget actions = ButtonBarTheme(
      data: ButtonBarTheme.of(context),
      child: ButtonBar(
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );

    final dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final Widget pickerAndActions = DecoratedBox(
            decoration: boxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: picker,
                ), // picker grows and shrinks with the available space
                actions,
              ],
            ),
          );

          switch (orientation) {
            case Orientation.portrait:
              return SizedBox(
                width: _kDurationPickerWidthPortrait,
                height: _kDurationPickerHeightPortrait,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              return SizedBox(
                width: _kDurationPickerWidthLandscape,
                height: _kDurationPickerHeightLandscape,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Shows a dialog containing the duration picker.
///
/// The returned Future resolves to the duration selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
///
/// ```dart
/// showDurationPicker(
///   initialTime: new Duration.now(),
///   context: context,
/// );
/// ```
Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialTime,
  BaseUnit baseUnit = BaseUnit.minute,
  double snapToMins = 1.0,
  BoxDecoration? decoration,
}) async {
  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) => DurationPickerDialog(
      initialTime: initialTime,
      baseUnit: baseUnit,
      snapToMins: snapToMins,
      decoration: decoration,
    ),
  );
}

/// The [DurationPicker] widget.
class DurationPicker extends StatefulWidget {
  final Duration duration;
  final ValueChanged<Duration> onChange;
  final BaseUnit baseUnit;
  final double? snapToMins;
  final TextStyle? fontStyle;
  final double? width;
  final double? height;

  const DurationPicker(
      {Key? key,
      this.duration = Duration.zero,
      required this.onChange,
      this.baseUnit = BaseUnit.minute,
      this.snapToMins,
      this.width,
      this.height,
      this.fontStyle})
      : super(key: key);

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  @override
  Widget build(BuildContext context) {
    //https://www.youtube.com/watch?v=iiL065berk8 for sample implementation

    return SizedBox(
      width: widget.width ?? _kDurationPickerWidthPortrait / 1.5,
      height: widget.height ?? _kDurationPickerHeightPortrait / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _Dial(
              duration: widget.duration,
              onChanged: widget.onChange,
              baseUnit: widget.baseUnit,
              snapToMins: widget.snapToMins,
              duratationTextStyle: widget.fontStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// This enum contains the possible units for the [DurationPicker]
enum BaseUnit {
  millisecond,
  second,
  minute,
  hour,
}
