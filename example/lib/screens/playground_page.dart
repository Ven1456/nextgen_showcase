import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage(
      {super.key, required this.data, required this.onChanged});

  final NextgenShowcaseThemeData data;
  final void Function(NextgenShowcaseThemeData) onChanged;

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final GlobalKey _targetKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();
  CardTransition _transition = CardTransition.zoom;
  Color _backdropColor = const Color.fromARGB(170, 0, 0, 0);
  double _glassBlur = 16;

  @override
  void initState() {
    super.initState();
    _updateShowcase();
  }

  void _applyTheme() {
    widget.onChanged(
      widget.data.copyWith(
        backdropColor: _backdropColor,
        glassBlurSigma: _glassBlur,
      ),
    );
  }

  void _updateShowcase() {
    _controller.setConfig(ShowcaseConfig(
      cardTransition: _transition,
      cardTransitionDurationMs: 400,
    ));
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _targetKey,
        title: 'Configurable Target',
        description:
            'This is a playground for testing different shapes, transitions, and effects. Adjust the settings below to see changes in real-time.',
        actions: <ShowcaseAction>[
          ShowcaseAction(
            label: 'Learn More',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is a custom action!')),
              );
            },
          ),
        ],
      ),
    ]);
  }

  void _startDemo() {
    ShowcaseManager().dismissActive();
    _updateShowcase();
    _controller.startManaged(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: _startDemo,
                child: const Text('Start Demo'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => ShowcaseManager().dismissActive(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              DropdownButton<CardTransition>(
                value: _transition,
                onChanged: (CardTransition? v) {
                  setState(() => _transition = v ?? _transition);
                  _updateShowcase();
                  if (ShowcaseManager().hasActiveShowcase) _startDemo();
                },
                items: const <DropdownMenuItem<CardTransition>>[
                  DropdownMenuItem(
                      value: CardTransition.fade, child: Text('Fade')),
                  DropdownMenuItem(
                      value: CardTransition.zoom, child: Text('Zoom')),
                  DropdownMenuItem(
                      value: CardTransition.slideUp, child: Text('Slide Up')),
                  DropdownMenuItem(
                      value: CardTransition.elasticIn,
                      child: Text('Elastic In')),
                  DropdownMenuItem(
                      value: CardTransition.slideFromRight,
                      child: Text('Slide From Right')),
                  DropdownMenuItem(
                      value: CardTransition.bounceIn, child: Text('Bounce In')),
                ],
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Backdrop color'),
                    DropdownButton<Color>(
                      value: _backdropColor,
                      onChanged: (Color? c) {
                        if (c == null) return;
                        setState(() => _backdropColor = c);
                        _applyTheme();
                      },
                      items: const <DropdownMenuItem<Color>>[
                        DropdownMenuItem(
                            value: Color.fromARGB(170, 0, 0, 0),
                            child: Text('Black (semi)')),
                        DropdownMenuItem(
                            value: Color.fromARGB(170, 0, 0, 255),
                            child: Text('Blue (semi)')),
                        DropdownMenuItem(
                            value: Color.fromARGB(170, 0, 255, 0),
                            child: Text('Green (semi)')),
                        DropdownMenuItem(
                            value: Color.fromARGB(170, 255, 0, 0),
                            child: Text('Red (semi)')),
                        DropdownMenuItem(
                            value: Color.fromARGB(170, 255, 255, 255),
                            child: Text('White (semi)')),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Glass blur sigma'),
                    Slider(
                      value: _glassBlur,
                      min: 0,
                      max: 48,
                      divisions: 48,
                      label: _glassBlur.toStringAsFixed(0),
                      onChanged: (double v) {
                        setState(() => _glassBlur = v);
                        _applyTheme();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              key: _targetKey,
              onPressed: () {},
              child: const Text('Target widget'),
            ),
          ),
        ],
      ),
    );
  }
}
