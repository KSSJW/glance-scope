import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:glance_scope/component/gauge.dart';
import 'package:http/http.dart' as http;
import 'package:glance_scope/component/all_chart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.baseUrl,
  });

  final String baseUrl;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? cpu;
  Map<String, dynamic>? ram;
  List<dynamic>? rawGpu;
  double? gpu;

  String? error;
  bool loading = true;
  DateTime? lastUpdated;

  Timer? timer;

  final List<FlSpot> cpuHistory = [];
  final List<FlSpot> ramHistory = [];
  final List<FlSpot> gpuHistory = [];

  double sampleIndex = 0;

  static const int maxHistoryPoints = 60;

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
    refresh();
    timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => refresh(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    WakelockPlus.disable();

    super.dispose();
  }

  Future<dynamic> fetchJson(
    String endpoint,
  ) async {
    final response = await http
        .get(Uri.parse('${widget.baseUrl}/api/4/$endpoint'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
        '$endpoint: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    return decoded;
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        fetchJson('quicklook'),
        fetchJson('mem'),
        fetchJson('gpu'),
      ]);

      if (results[0] is! Map<String, dynamic> ||
          results[1] is! Map<String, dynamic> ||
          results[2] is! List) {
        throw const FormatException('Unexpected API response');
      }

      if (!mounted) return;

      setState(() {
        cpu = results[0];
        ram = results[1];
        final gpuList = results[2] as List<dynamic>;
        rawGpu = gpuList;

        final gpuUsage = gpuList.isNotEmpty
          ? (gpuList.first['proc'] as num?)?.toDouble()
          : null;
        gpu = gpuUsage;

        final cpuValue = results[0]['cpu'];
        final ramValue = results[1]['percent'];

        if (cpuValue is num) {
          cpuHistory.add(
            FlSpot(sampleIndex, cpuValue.toDouble()),
          );

          if (cpuHistory.length > maxHistoryPoints) {
            cpuHistory.removeAt(0);
          }
        }

        if (ramValue is num) {
          ramHistory.add(
            FlSpot(sampleIndex, ramValue.toDouble()),
          );

          if (ramHistory.length > maxHistoryPoints) {
            ramHistory.removeAt(0);
          }
        }

        if (gpuUsage != null) {
          gpuHistory.add(
            FlSpot(sampleIndex, gpuUsage),
          );

          if (gpuHistory.length > maxHistoryPoints) {
            gpuHistory.removeAt(0);
          }
        }

        sampleIndex++;

        error = null;
        loading = false;
        lastUpdated = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Icon(
                  error == null
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: error == null
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error == null
                        ? 'Connected to ${widget.baseUrl}'
                        : 'Connection failed',
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Updated at ${lastUpdated!.toLocal()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 3 : 1;

                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisExtent: 240,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    Gauge(
                      title: 'CPU Usage',
                      usage: ((cpu?['cpu'] as num?)?.toDouble() ?? 0).clamp(0.0, 100.0),
                    ),
                    Gauge(
                      title: 'GPU Usage',
                      usage: ((gpu as num?)?.toDouble() ?? 0).clamp(0.0, 100.0),
                    ),
                    AllChart(
                      cpu: cpuHistory,
                      ram: ramHistory,
                      gpu: gpuHistory
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
