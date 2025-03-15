import 'package:flutter/material.dart';
import 'package:responsive_sliding_drawer/responsive_sliding_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Drawer Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidingDrawer(
      drawer: const DrawerContent(),
      body: const MainContent(),
    );
  }
}

class DrawerContent extends StatelessWidget {
  const DrawerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the entire drawer content in a Material widget.
    return Material(
      child: Container(
        color: Colors.blueGrey[100],
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Handle navigation if needed.
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle navigation if needed.
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Drawer Example')),
      body: const Center(
        child: Text('Swipe right from the left edge to open the drawer'),
      ),
    );
  }
}
