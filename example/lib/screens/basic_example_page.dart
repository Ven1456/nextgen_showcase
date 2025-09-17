import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

class BasicExamplePage extends StatefulWidget {
  const BasicExamplePage({super.key});

  @override
  State<BasicExamplePage> createState() => _BasicExamplePageState();
}

class _BasicExamplePageState extends State<BasicExamplePage> {
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Showcase Demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ShowcaseManager().dismissActive();
              ShowcaseFlowBuilder.create()
                  .addStep(
                    key: _buttonKey,
                    title: 'Welcome!',
                    description:
                        'This is a simple showcase demo. Tap the button below to see more features.',
                  )
                  .addCircularStep(
                    key: _fabKey,
                    title: 'Floating Action Button',
                    description:
                        'This FAB demonstrates circular spotlight shapes.',
                  )
                  .addRectangularStep(
                    key: _cardKey,
                    title: 'Info Card',
                    description:
                        'This card shows how rectangular spotlights work with custom content.',
                    contentBuilder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Custom Content',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'You can create custom content for showcase cards!'),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            FilledButton.tonal(
                              onPressed: () {},
                              child: const Text('Learn More'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Get Started'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .withConfig(ShowcasePresets.modern())
                  .start(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Showcase Features',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              key: _cardKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Enhanced Animations',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Smooth transitions with improved timing and curves.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    key: _buttonKey,
                    onPressed: () {},
                    child: const Text('Try Feature'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ShowcaseManager().dismissActive();
                      ShowcaseFlowBuilder.create()
                          .addStep(
                            key: _buttonKey,
                            title: 'Preset Demo',
                            description:
                                'This uses the playful preset configuration.',
                          )
                          .withConfig(ShowcasePresets.playful())
                          .start(context);
                    },
                    child: const Text('Playful Mode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'New Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Improved background colors and gradients'),
            const Text('• Enhanced animations with better timing'),
            const Text('• Simplified API with ShowcaseBuilder'),
            const Text('• Fixed shape rendering and alignment'),
            const Text('• New transition types (slideFromRight, bounceIn)'),
            const Text('• Preset configurations for common use cases'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          ShowcaseManager().dismissActive();
          final controller = NextgenShowcaseController();
          controller.setSteps([
            _fabKey.toCircularShowcaseStep(
              title: 'Quick Action',
              description:
                  'This demonstrates the extension method for creating showcase steps.',
            ),
          ]);
          controller.startManaged(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
