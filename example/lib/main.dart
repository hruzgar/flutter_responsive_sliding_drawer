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
      theme: ThemeData(useMaterial3: true),
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
  bool _isLightTheme = false;

  @override
  Widget build(BuildContext context) {
    return SlidingDrawer(
      controller: _drawerController,
      onStartedOpening: () {
        setState(() => _showMainMenuButton = false);
      },
      onFinishedOpening: () {},
      onStartedClosing: () {},
      onFinishedClosing: () {
        setState(() => _showMainMenuButton = true);
      },
      drawer: DrawerContent(
        controller: _drawerController,
        isLightTheme: _isLightTheme,
        toggleTheme: () => setState(() => _isLightTheme = !_isLightTheme),
      ),
      body: MainContent(
        controller: _drawerController,
        showMenuButton: _showMainMenuButton,
        isLightTheme: _isLightTheme,
      ),
      scrimColor: _isLightTheme ? Colors.black : Colors.white,
      scrimColorOpacity: 0.3,
      scrimGradientStartOpacity: 0.2,
      scrimGradientWidth: 4,
    );
  }
}

class DrawerContent extends StatelessWidget {
  final SlidingDrawerController controller;
  final bool isLightTheme;
  final VoidCallback toggleTheme;

  const DrawerContent({
    Key? key,
    required this.controller,
    required this.isLightTheme,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isLightTheme ? Colors.white : Colors.grey[900];
    final textColor = isLightTheme ? Colors.black : Colors.white;

    return Material(
      color: backgroundColor,
      child: Theme(
        data: ThemeData(
          brightness: isLightTheme ? Brightness.light : Brightness.dark,
          primaryColor: backgroundColor,
        ),
        child: Column(
          children: [
            SafeArea(
              child: AppBar(
                backgroundColor: backgroundColor,
                automaticallyImplyLeading: false,
                title: Text(
                  'Drawer Header',
                  style: TextStyle(color: textColor),
                ),
                leading: IconButton(
                  icon: Icon(Icons.menu, color: textColor),
                  onPressed: () => controller.close(),
                ),
              ),
            ),
            SwitchListTile(
              title: Text('Light Theme', style: TextStyle(color: textColor)),
              value: isLightTheme,
              onChanged: (_) => toggleTheme(),
              secondary: Icon(Icons.light_mode, color: textColor),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: textColor),
                    title: Text('Home', style: TextStyle(color: textColor)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: textColor),
                    title: Text('Settings', style: TextStyle(color: textColor)),
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
  final bool isLightTheme;

  const MainContent({
    Key? key,
    required this.controller,
    required this.showMenuButton,
    required this.isLightTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isLightTheme
            ? const Color.fromARGB(255, 245, 245, 245)
            : const Color.fromARGB(255, 47, 47, 47);
    final textColor =
        isLightTheme
            ? const Color.fromARGB(255, 33, 33, 33)
            : const Color.fromARGB(255, 202, 202, 202);
    final iconColor = isLightTheme ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          // 'Sliding Drawer Example',
          'Windows (desktop platforms)',
          style: TextStyle(color: textColor),
        ),
        automaticallyImplyLeading: false,
        leading:
            showMenuButton
                ? IconButton(
                  icon: Icon(Icons.menu, color: iconColor),
                  onPressed: () => controller.open(),
                )
                : null,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Swiping right does not work here. On desktop platforms you have use the controller (with a button for example) to open/close the drawer.',
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
