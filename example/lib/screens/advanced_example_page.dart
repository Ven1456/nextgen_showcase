import 'package:flutter/material.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

class AdvancedExamplePage extends StatefulWidget {
  const AdvancedExamplePage({super.key});

  @override
  State<AdvancedExamplePage> createState() => _AdvancedExamplePageState();
}

class _AdvancedExamplePageState extends State<AdvancedExamplePage> {
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _firstProductKey = GlobalKey();
  final NextgenShowcaseController _controller = NextgenShowcaseController();

  @override
  void dispose() {
    // Ensure the tour is closed if the screen disposes
    ShowcaseManager().dismissActive();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupShowcase();
  }

  void _setupShowcase() {
    _controller.setSteps(<ShowcaseStep>[
      ShowcaseStep(
        key: _searchKey,
        title: 'Search Products',
        description:
            'Use the search icon to find any product in our store. You can search by name, category, or brand.',
        shape: ShowcaseShape.circle,
        actions: <ShowcaseAction>[
          ShowcaseAction(label: 'Try Search', onPressed: () {}),
        ],
      ),
      ShowcaseStep(
        key: _profileKey,
        title: 'Your Profile',
        description:
            'View and edit your profile information, manage your account settings, and track your orders.',
        contentBuilder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: const <Widget>[
                  CircleAvatar(radius: 20, backgroundColor: Colors.blue),
                  SizedBox(width: 12),
                  Text('Profile Management',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                  'Manage your personal information, shipping addresses, and payment methods.'),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  FilledButton.tonal(
                      onPressed: () => ShowcaseManager().dismissActive(),
                      child: const Text('Edit Profile')),
                  const SizedBox(width: 8),
                  FilledButton(
                      onPressed: () => ShowcaseManager().dismissActive(),
                      child: const Text('View Orders')),
                ],
              )
            ],
          );
        },
      ),
      ShowcaseStep(
        key: _categoriesKey,
        title: 'Browse Categories',
        description:
            'Swipe through popular categories to quickly find what you need.',
      ),
      ShowcaseStep(
        key: _notificationsKey,
        title: 'Notifications',
        description:
            'Stay updated with order status, promotions, and important updates.',
        shape: ShowcaseShape.circle,
      ),
      ShowcaseStep(
        key: _settingsKey,
        title: 'App Settings',
        description:
            'Customize your app experience, manage privacy settings, and configure preferences.',
        shape: ShowcaseShape.circle,
      ),
      ShowcaseStep(
        key: _firstProductKey,
        title: 'Featured Product',
        description: 'Tap to view details, compare, and add to your cart.',
      ),
      ShowcaseStep(
        key: _fabKey,
        title: 'Tips & Tricks',
        description:
            'Use Quick Actions for common tasks like adding to cart or starting a search.',
        shape: ShowcaseShape.circle,
      ),
      ShowcaseStep(
        key: _fabKey,
        title: 'Quick Actions',
        description:
            'Access quick actions like adding items to cart or starting a new search.',
        shape: ShowcaseShape.circle,
      ),
    ]);
  }

  void _startShowcase() {
    ShowcaseManager().dismissActive();
    _controller.startManaged(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Dismiss Tour',
            onPressed: () => ShowcaseManager().dismissActive(),
          ),
          IconButton(
            key: _searchKey,
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            key: _notificationsKey,
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            key: _settingsKey,
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _startShowcase,
            tooltip: 'Start Tour',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              key: _profileKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/60x60/667eea/ffffff?text=U'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text('Welcome back!',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('John Doe',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Premium Member',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blue)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  final List<String> categories = <String>[
                    'Electronics',
                    'Fashion',
                    'Home',
                    'Sports',
                    'Books'
                  ];
                  final List<IconData> icons = <IconData>[
                    Icons.phone_android,
                    Icons.shopping_bag,
                    Icons.home,
                    Icons.sports,
                    Icons.book
                  ];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          key: index == 0 ? _categoriesKey : null,
                          child:
                              Icon(icons[index], color: Colors.blue, size: 30),
                        ),
                        const SizedBox(height: 8),
                        Text(categories[index],
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Featured Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                final List<String> products = <String>[
                  'iPhone 15',
                  'MacBook Pro',
                  'AirPods',
                  'iPad Air'
                ];
                final List<String> prices = <String>[
                  '\$999',
                  '\$1999',
                  '\$199',
                  '\$599'
                ];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                          child: Center(
                            key: index == 0 ? _firstProductKey : null,
                            child: const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(products[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(prices[index],
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick action triggered!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
