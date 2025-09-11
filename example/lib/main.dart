import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

void main() {
  runApp(const ShowcaseExampleApp());
}

class ShowcaseExampleApp extends StatelessWidget {
  const ShowcaseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ShowcaseDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShowcaseDemoPage extends StatefulWidget {
  const ShowcaseDemoPage({super.key});

  @override
  State<ShowcaseDemoPage> createState() => _ShowcaseDemoPageState();
}

class _ShowcaseDemoPageState extends State<ShowcaseDemoPage> {
  final GlobalKey _buttonKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('nextgen_showcase example')),
      body: Center(
        child: ElevatedButton(
          key: _buttonKey,
          onPressed: () {
            _controller.show(
              context: context,
              targetKey: _buttonKey,
              title: 'Primary action',
              description: 'This button triggers the main action in this screen.',
            );
          },
          child: const Text('Highlight me'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.hide,
        child: const Icon(Icons.close),
      ),
    );
  }
}


