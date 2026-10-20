import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

Card build(String title, double usage, BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 240,
            height: 160,
            child: AnimatedRadialGauge(
              duration: const Duration(milliseconds: 250),
              value: usage,
              axis: GaugeAxis(
                min: 0.0,
                max: 100.0,
                progressBar: GaugeProgressBar.rounded(
                  color: usage < 50.0 ? Colors.green : (usage < 75.0 ? Colors.orange : Colors.red),
                ),
                style: GaugeAxisStyle(
                  background: Colors.white.withAlpha(128),
                ),
              ),
              child: Center(
                child: Text(
                  '${usage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
