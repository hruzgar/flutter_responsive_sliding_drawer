import 'package:flutter/material.dart';
import 'package:responsive_sliding_drawer/responsive_sliding_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ResponsiveSlidingDrawerController _drawerController =
      ResponsiveSlidingDrawerController();
  bool _showMainMenuButton = true;
  bool _isLightTheme = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _isLightTheme ? Colors.white : const Color(0xFF212121);
    final textColor = _isLightTheme ? Colors.black : Colors.white;

    return ResponsiveSlidingDrawer(
      controller: _drawerController,
      isDarkMode: !_isLightTheme,
      onStartedOpening: () {
        setState(() => _showMainMenuButton = false);
      },
      onFinishedClosing: () {
        setState(() => _showMainMenuButton = true);
      },
      drawer: DrawerContent(
        controller: _drawerController,
        isLightTheme: _isLightTheme,
        toggleTheme: () => setState(() => _isLightTheme = !_isLightTheme),
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      body: MainContent(
        controller: _drawerController,
        showMenuButton: _showMainMenuButton,
        isLightTheme: _isLightTheme,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );
  }
}

class DrawerContent extends StatelessWidget {
  final ResponsiveSlidingDrawerController controller;
  final bool isLightTheme;
  final VoidCallback toggleTheme;
  final Color backgroundColor;
  final Color textColor;

  const DrawerContent({
    super.key,
    required this.controller,
    required this.isLightTheme,
    required this.toggleTheme,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Theme(
        data: ThemeData(
          brightness: isLightTheme ? Brightness.light : Brightness.dark,
          primaryColor: backgroundColor,
          applyElevationOverlayColor: false,
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
  final ResponsiveSlidingDrawerController controller;
  final bool showMenuButton;
  final bool isLightTheme;
  final Color backgroundColor;
  final Color textColor;

  const MainContent({
    super.key,
    required this.controller,
    required this.showMenuButton,
    required this.isLightTheme,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Windows (desktop platforms)',
          style: TextStyle(color: textColor),
        ),
        automaticallyImplyLeading: false,
        leading:
            showMenuButton
                ? IconButton(
                  icon: Icon(Icons.menu, color: textColor),
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
