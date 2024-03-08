import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Port Scanner',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PortScannerPage(),
    );
  }
}

class PortScannerPage extends StatefulWidget {
  @override
  _PortScannerPageState createState() => _PortScannerPageState();
}

class _PortScannerPageState extends State<PortScannerPage> {
  TextEditingController ipController = TextEditingController();
  TextEditingController startPortController = TextEditingController();
  TextEditingController endPortController = TextEditingController();

  List<int> openPorts = [];
  bool scanning = false;

  // Debugging flags
  bool showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Port Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Enter IP Address'),
            ),
            TextField(
              controller: startPortController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Start Port'),
            ),
            TextField(
              controller: endPortController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter End Port'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await scanPorts();
              },
              child: Text('Scan Ports'),
            ),
            SizedBox(height: 20),
            scanning
                ? LinearProgressIndicator()
                : Container(), // Show progress indicator while scanning
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showDebugInfo =
                      !showDebugInfo; // Toggle debug info visibility
                });
              },
              child:
                  Text(showDebugInfo ? 'Hide Debug Info' : 'Show Debug Info'),
            ),
            if (showDebugInfo)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text('Debug Information:'),
                  Text('IP Address: ${ipController.text}'),
                  Text('Start Port: ${startPortController.text}'),
                  Text('End Port: ${endPortController.text}'),
                  Text('Scanning: $scanning'),
                  Text('Open Ports: $openPorts'),
                ],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: openPorts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Open Port: ${openPorts[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> scanPorts() async {
    setState(() {
      openPorts.clear(); // Clear previous results
      scanning = true; // Set scanning to true
    });

    String ipAddress = ipController.text.trim();
    int startPort = int.tryParse(startPortController.text.trim()) ?? 0;
    int endPort = int.tryParse(endPortController.text.trim()) ?? 0;

    for (int port = startPort; port <= endPort; port++) {
      try {
        await Socket.connect(ipAddress, port, timeout: Duration(seconds: 1));
        setState(() {
          openPorts.add(port);
        });
      } catch (e) {
        // Port is closed
      }
    }

    setState(() {
      scanning = false; // Set scanning to false when done
    });
  }
}
