# Responsive Sliding Drawer Flutter Widget

A responsive sliding drawer for Flutter inspired by the official ChatGPT Android app. It adjust its behaviour based on screen width but also the platform it detects which leads to an overall responsive and smooth experience. On mobile it fully mimics the sliding drawer behaviour and design from the ChatGPT Android app. 

> Small Reminder: It took me over 100 hours (yes I'm not even joking, it could be even more) to create this package with all the fine details and adjustments to mimic the ChatGPT app etc. So please don't forget to give this package star on github if it's useful to you. Thanks

![](https://raw.githubusercontent.com/hruzgar/flutter_responsive_sliding_drawer/refs/heads/main/example.gif)


## Features & Behaviour

- **Responsive Layout:** The drawer adjusts its behavior depending on screen size and platform. On mobile, you can swipe anywhere on the screen to open or close it. On desktop, it behaves more like a traditional side panel with a draggable area and a resizable width.
- **Smart Gesture Handling:** Gestures feel intuitive across platforms. On Android and iOS, horizontal swipes control the drawer. On desktop platforms, gestures are limited to a small drag zone near the drawer for a more controlled experience (or fully disabled if window width is small).
- **Resizable on Desktop:** On wider screens (like tablets or desktops), the drawer can be resized by dragging the divider. You can set minimum and maximum widths, and the resizing even handles edge cases like overdrag smoothly.
- **Smooth Animations:** Opening and closing the drawer is animated with clean transitions. You can tweak the speed, how fast a swipe needs to be, and how far it should go to trigger the drawer.
- **Custom Callbacks:** Easily hook into the drawer’s lifecycle. Run custom logic when it starts or finishes opening or closing, or when the animation completes.
- **Scrim Overlay (Mobile):** When the drawer is open on mobile, a dimmed background appears behind it, complete with a subtle gradient on the edge. Tapping or swiping this area also closes the drawer.
- **Built-in Controller:** Control the drawer programmatically using the included `ResponsiveSlidingDrawerController`. You can open, close, or toggle it from anywhere in your app.


## Getting Started

### Prerequisites

- Flutter 2.0 or higher

### Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  responsive_sliding_drawer: ^1.5.1
```
> (Replace `^1.5.1` with the latest version or the version you need.)

Then run:

```bash
flutter pub get
```



## Usage

To use the `ResponsiveSlidingDrawer` widget in your Flutter project, simply wrap your main content and drawer content shown in the example below (for a more comprehensive example as in the example gif above, you can run the example project included in the repository and get inspiration from there):

```dart
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
    return ResponsiveSlidingDrawer(
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
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
```


### Customization Options

When creating a `ResponsiveSlidingDrawer`, you can customize its behavior and appearance using the following parameters:

- **`animationDuration`**: The duration of the open/close animation.
- **`openRatio`**: The fraction of the screen width that the drawer covers when fully open on mobile.
- **`desktopOpenRatio`**: The fraction of the screen width for the open drawer on desktop devices.
- **`desktopMinDrawerWidth`** & **`desktopMaxDrawerWidth`**: The minimum and maximum widths allowed for the drawer on desktop devices.
- **`swipeVelocityThreshold`**: The minimum swipe velocity required to trigger the open/close action.
- **`dragPercentageThreshold`**: The drag percentage needed to complete an open/close action if the swipe velocity is low.
- **`onAnimationComplete`**: A callback function that is called once the drawer has finished animating.
Here are the missing descriptions for the remaining parameters:
- **`onFinishedOpening`**: A callback function that is triggered once the drawer has fully opened.
- **`onFinishedClosing`**: A callback function that is triggered once the drawer has fully closed.
- **`onStartedOpening`**: A callback function that is called when the drawer starts to open.
- **`onStartedClosing`**: A callback function that is called when the drawer starts to close.
- **`dividerWidth`**: The width of the draggable divider between the drawer and the body on desktop devices.
- **`centerDivider`**: A boolean that determines whether the divider is centered along the edge of the open drawer.
- **`controller`**: An optional `ResponsiveSlidingDrawerController` that allows you to programmatically open, close, or toggle the drawer.
- **`desktopDragAreaWidth`**: The width of the draggable area on desktop devices, allowing you to customize the zone from which you can swipe to open the drawer.

There is also multiple `scrim` related parameters which I don't recommend to change as it needs fine adjustment but you can find their explanations in the package itself or if you hover over the parameters (this works for all the other parameters as well).


## Additional Information

- **Issues:** If you encounter any problems or have suggestions, please open an issue on the [issue tracker](https://github.com/hruzgar/flutter_responsive_sliding_drawer/issues).
- **License:** This project is licensed under the terms of the GNU Lesser General Public License v3.0.
See the `LICENSE` file for details.

Feel free to open a pull request if you’d like to add more features or improve the widget. Happy coding!
