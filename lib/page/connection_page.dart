import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home_page.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  bool connecting = false;
  String? connectionError;

  final addressController = TextEditingController(
    text: '127.0.0.1',
  );
  final portController = TextEditingController(
    text: '61208',
  );

  @override
  void dispose() {
    addressController.dispose();
    portController.dispose();
    super.dispose();
  }
  
  Future<void> connect() async {
    if (connecting) return;

    final address = addressController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (address.isEmpty ||
        port == null ||
        port < 1 ||
        port > 65535) {
      setState(() {
        connectionError = 'Address error.';
      });
      return;
    }

    final baseUrl = 'http://$address:$port';

    setState(() {
      connecting = true;
      connectionError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/4/quicklook'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Server return HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          !decoded.containsKey('cpu')) {
        throw const FormatException(
          'Glances quicklook error.',
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => HomePage(baseUrl: baseUrl),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        connectionError = switch (e) {
          FormatException() => e.message,
          _ => 'Error: ${e is Exception ? e.toString().replaceFirst('Exception: ', '') : e}',
        };
      });
    } finally {
      if (mounted) {
        setState(() {
          connecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Glances'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.monitor_heart_outlined,
                  size: 56,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'IP address / Hostname',
                    hintText: '127.0.0.1',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: '61208',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.settings_ethernet),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: connecting ? null : connect,
                  icon: connecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.link),
                  label: Text(connecting ? 'Connecting...' : 'Connect'),
                ),
                if (connectionError != null) ...[
                  Text(
                    connectionError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
