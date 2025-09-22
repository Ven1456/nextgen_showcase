import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

/// Comprehensive example demonstrating all advanced showcase features.
class AdvancedShowcaseExample extends StatefulWidget {
  const AdvancedShowcaseExample({super.key});

  @override
  State<AdvancedShowcaseExample> createState() => _AdvancedShowcaseExampleState();
}

class _AdvancedShowcaseExampleState extends State<AdvancedShowcaseExample>
    with TickerProviderStateMixin {
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();
  final GlobalKey _button3Key = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();

  late AdvancedShowcaseController _controller;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AdvancedShowcaseController();
    _controller.initializeAnimations(this);
    _setupShowcaseSteps();
  }

  @override
  void dispose() {
    _controller.disposeAnimations();
    _controller.dispose();
    super.dispose();
  }

  void _setupShowcaseSteps() {
    final List<ShowcaseStep> steps = [
      // Step 1: Basic button with scale animation
      ShowcaseStep(
        key: _button1Key,
        title: 'Welcome to Advanced Showcase!',
        description: 'This is a basic button with scale animation. Tap to continue.',
        shape: ShowcaseShape.roundedRectangle,
        highlightAnimation: HighlightAnimation.scale,
        animationDuration: const Duration(milliseconds: 500),
        tooltipPlacement: TooltipPlacement.auto,
        tooltipShape: TooltipShape.bubble,
        tooltipArrow: true,
        allowTapHighlight: true,
        gestureSupport: true,
        onStart: () => print('Step 1 started'),
        onNext: () => print('Step 1 next'),
      ),

      // Step 2: Star-shaped highlight with pulse animation
      ShowcaseStep(
        key: _button2Key,
        title: 'Star Shape Highlight',
        description: 'This button uses a star-shaped highlight with pulsing animation.',
        shape: ShowcaseShape.star,
        starPoints: 6,
        starInnerRadius: 0.3,
        highlightAnimation: HighlightAnimation.pulse,
        animationDuration: const Duration(milliseconds: 800),
        tooltipPlacement: TooltipPlacement.bottom,
        tooltipShape: TooltipShape.roundedRectangle,
        richContent: 'This is **rich content** with *formatting* support!',
        icon: Icons.star,
        progressIndicator: true,
        autoAdvance: true,
        autoAdvanceDelay: const Duration(seconds: 4),
        onStart: () => print('Step 2 started'),
      ),

      // Step 3: Polygon shape with glow effect
      ShowcaseStep(
        key: _button3Key,
        title: 'Polygon Shape',
        description: 'This uses a polygon shape with glowing animation effect.',
        shape: ShowcaseShape.polygon,
        polygonSides: 8,
        highlightAnimation: HighlightAnimation.glow,
        animationDuration: const Duration(milliseconds: 1000),
        tooltipPlacement: TooltipPlacement.left,
        tooltipShape: TooltipShape.bubble,
        image: 'assets/example_image.png',
        persistent: true,
        onStart: () => print('Step 3 started'),
      ),

      // Step 4: Custom shape with bounce animation
      ShowcaseStep(
        key: _cardKey,
        title: 'Custom Shape',
        description: 'This card uses a custom diamond shape with bounce animation.',
        shape: ShowcaseShape.diamond,
        highlightAnimation: HighlightAnimation.bounce,
        animationDuration: const Duration(milliseconds: 600),
        tooltipPlacement: TooltipPlacement.top,
        tooltipShape: TooltipShape.roundedRectangle,
        heroAnimation: true,
        onStart: () => print('Step 4 started'),
      ),

      // Step 5: Multi-widget highlighting
      ShowcaseStep(
        key: _fabKey,
        title: 'Multi-Widget Highlight',
        description: 'This step highlights multiple widgets simultaneously.',
        shape: ShowcaseShape.circle,
        highlightAnimation: HighlightAnimation.elastic,
        animationDuration: const Duration(milliseconds: 700),
        tooltipPlacement: TooltipPlacement.auto,
        tooltipShape: TooltipShape.bubble,
        onStart: () {
          print('Step 5 started - highlighting multiple widgets');
          _controller.highlightMultiple(context, [_fabKey, _menuKey]);
        },
      ),
    ];

    _controller.setSteps(steps);
  }

  void _startShowcase() {
    _controller.startAdvanced(context);
  }

  void _startQuickTour() {
    EasyShowcase.showSimple(
      context,
      [
        _button1Key,
        _button2Key,
        _button3Key,
        _cardKey,
        _fabKey,
      ],
    );
  }

  void _startMultiHighlight() {
    _controller.highlightMultiple(context, [_button1Key, _button2Key, _button3Key]);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Showcase Example',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Showcase Features'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        body: NextgenShowcaseTheme(
          data: NextgenShowcaseThemeData(
            // Advanced theme configuration
            backgroundType: BackgroundType.glass,
            backdropColor: Colors.black.withAlpha(70),
            backdropBlurSigma: 10.0,
            gradientColors: const [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
            gradientAnimationMs: 3000,
            glassBlurSigma: 15.0,
            cardOpacity: 0.9,
            glowPulseDelta: 15.0,
            animationCurve: Curves.elasticOut,
            animationDuration: const Duration(milliseconds: 500),
            tooltipBackgroundColor: Colors.white,
            tooltipBorderColor: Colors.blue,
            tooltipBorderWidth: 2.0,
            tooltipBorderRadius: const BorderRadius.all(Radius.circular(12)),
            tooltipShadowColor: Colors.black.withAlpha(30),
            tooltipShadowBlur: 12.0,
            tooltipShadowOffset: const Offset(0, 4),
            tooltipPadding: const EdgeInsets.all(20),
            tooltipMargin: const EdgeInsets.all(16),
            arrowSize: 12.0,
            arrowColor: Colors.blue,
            progressIndicatorColor: Colors.blue,
            progressIndicatorBackgroundColor: Colors.grey.withAlpha(30),
            progressIndicatorHeight: 6.0,
            rtlSupport: false,
            accessibilityAnnouncements: true,
            keyboardNavigation: true,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Control buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Showcase Controls',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                             ElevatedButton.icon(
                               onPressed: _startQuickTour,
                               icon: const Icon(Icons.flash_on),
                               label: const Text('Quick Tour (1-liner)'),
                             ),
                            ElevatedButton.icon(
                              onPressed: _startShowcase,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Showcase'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _startMultiHighlight,
                              icon: const Icon(Icons.select_all),
                              label: const Text('Multi-Highlight'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _controller.dismiss(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _controller.setAccessibilityEnabled(
                                !_controller.accessibilityEnabled,
                              ),
                              icon: Icon(_controller.accessibilityEnabled 
                                ? Icons.accessibility 
                                : Icons.accessibility_new),
                              label: Text(_controller.accessibilityEnabled 
                                ? 'Disable A11y' 
                                : 'Enable A11y'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Demo buttons with different shapes
                Text(
                  'Demo Buttons',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: _button1Key,
                        onPressed: () => print('Button 1 pressed'),
                        child: const Text('Scale Animation'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: _button2Key,
                        onPressed: () => print('Button 2 pressed'),
                        child: const Text('Star Shape'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: _button3Key,
                        onPressed: () => print('Button 3 pressed'),
                        child: const Text('Polygon'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Demo card
                Card(
                  key: _cardKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Card',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a demo card that can be highlighted with custom shapes and animations.',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text('Custom diamond shape with bounce animation'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Feature showcase
                Text(
                  'Advanced Features',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _buildFeatureCard(
                      'Shapes',
                      'Rectangle, Circle, Polygon, Star, Custom',
                      Icons.shape_line,
                    ),
                    _buildFeatureCard(
                      'Animations',
                      'Scale, Pulse, Glow, Bounce, Elastic',
                      Icons.animation,
                    ),
                    _buildFeatureCard(
                      'Backgrounds',
                      'Solid, Gradient, Blur, Glass, Custom',
                      Icons.photo_camera_back,
                    ),
                    _buildFeatureCard(
                      'Tooltips',
                      'Adaptive positioning, Rich content, Arrows',
                      Icons.power_input,
                    ),
                    _buildFeatureCard(
                      'Multi-Widget',
                      'Highlight multiple widgets simultaneously',
                      Icons.select_all,
                    ),
                    _buildFeatureCard(
                      'Accessibility',
                      'Screen reader support, Keyboard navigation',
                      Icons.accessibility,
                    ),
                  ],
                ),
                
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              key: _fabKey,
              onPressed: () => print('FAB pressed'),
              heroTag: 'fab1',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              key: _menuKey,
              onPressed: () => print('Menu pressed'),
              heroTag: 'fab2',
              child: const Icon(Icons.menu),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
