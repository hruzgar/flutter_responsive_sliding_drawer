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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
    
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
    
class _HomeScreenState extends State<HomeScreen> {
  final SlidingDrawerController _drawerController = SlidingDrawerController();
  bool _showMainMenuButton = true;
    
  @override
  Widget build(BuildContext context) {
    return SlidingDrawer(
      controller: _drawerController,
      onStartedOpening: () {
        print("Opening started!");
        setState(() {
          _showMainMenuButton = false;
        });
      },
      onFinishedOpening: () => print("Opening finished!"),
      onStartedClosing: () => print("Closing started!"),
      onFinishedClosing: () {
        print("Closing finished!");
        setState(() {
          _showMainMenuButton = true;
        });
      },
      drawer: DrawerContent(controller: _drawerController),
      body: MainContent(
        controller: _drawerController,
        showMenuButton: _showMainMenuButton,
      ),
    );
  }
}

class DrawerContent extends StatelessWidget {
  final SlidingDrawerController controller;
  const DrawerContent({Key? key, required this.controller}) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[850],
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.grey[900],
        ),
        child: Column(
          children: [
            SafeArea(
              child: AppBar(
                backgroundColor: Colors.grey[900],
                automaticallyImplyLeading: false,
                title: const Text('Drawer Header'),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => controller.close(),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.white),
                    title: const Text('Home', style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Settings', style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  final SlidingDrawerController controller;
  final bool showMenuButton;
  const MainContent({
    Key? key,
    required this.controller,
    required this.showMenuButton,
  }) : super(key: key);
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliding Drawer Example'),
        automaticallyImplyLeading: false,
        leading: showMenuButton
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => controller.open(),
              )
            : null,
      ),
      body: const Center(
        child: Text('Swipe right from the left edge to open the drawer'),
      ),
    );
  }
}
