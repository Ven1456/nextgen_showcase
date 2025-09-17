import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

class EdgeCasesPage extends StatefulWidget {
  const EdgeCasesPage({super.key});

  @override
  State<EdgeCasesPage> createState() => _EdgeCasesPageState();
}

class _EdgeCasesPageState extends State<EdgeCasesPage> {
  final NextgenShowcaseController _controller = NextgenShowcaseController();
  final GlobalKey _unmountedKey = GlobalKey();
  final GlobalKey _farKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  Future<void> _demoMissingKey(BuildContext context) async {
    ShowcaseManager().dismissActive();
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _unmountedKey,
        title: 'Missing/moved target',
        description:
            'The controller safely does nothing if the key is not found.',
      ),
    ]);
    _controller.startManaged(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No crash: missing key handled gracefully')),
      );
    }
  }

  Future<void> _demoOffscreen(BuildContext context) async {
    ShowcaseManager().dismissActive();
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _farKey,
        title: 'Offscreen target',
        description:
            'This button was scrolled into view before starting the tour.',
      ),
    ]);
    _controller.startManaged(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () => _demoMissingKey(context),
                child: const Text('Missing key'),
              ),
              FilledButton.tonal(
                onPressed: () => _demoOffscreen(context),
                child: const Text('Offscreen target'),
              ),
              TextButton(
                onPressed: () => ShowcaseManager().dismissActive(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text('Scroll down to find the target…'),
              const SizedBox(height: 1200),
              Center(
                child: ElevatedButton(
                  key: _farKey,
                  onPressed: () {},
                  child: const Text('Far away target'),
                ),
              ),
              const SizedBox(height: 600),
            ],
          ),
        ),
      ],
    );
  }
}
