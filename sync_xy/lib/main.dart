import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/screens/tasks_screen.dart';
import 'package:sync_xy/screens/stats_screen.dart';
import 'package:sync_xy/screens/plan_screen.dart';
import 'package:sync_xy/screens/shop_screen.dart';
import 'package:sync_xy/screens/settings_screen.dart';
import 'package:sync_xy/providers/app_state_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Productivity To-Do App',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.deepPurple),
              bodyMedium: TextStyle(color: Colors.deepPurple),
              bodySmall: TextStyle(color: Colors.deepPurple),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple, // Set the solid color for the AppBar
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Set the text color to white
            ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: appState.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'Tasks',
    'Stats',
    'Plan',
    'Shop',
    'Settings',
  ];

  static const List<Widget> _widgetOptions = <Widget>[
    TasksScreen(),
    StatsScreen(),
    PlanScreen(),
    ShopScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_titles[_selectedIndex]),
            if (_selectedIndex == 3) // Only show coins on Shop screen
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 5),
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return Text('${appState.coins}');
                    },
                  ),
                ],
              ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
