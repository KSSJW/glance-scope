import 'package:flutter/material.dart';
import 'package:glance_scope/component/gauge/gauge.dart' as gauge;

class CPUGauge extends StatelessWidget {
  const CPUGauge({
    super.key,
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    return gauge.build('CPU Usage', value.clamp(0.0, 100.0), context);
  }
}
