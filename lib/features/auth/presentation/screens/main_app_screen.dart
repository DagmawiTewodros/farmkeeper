import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import 'home_screen.dart';
import 'statstics_dashboard_screen.dart';
import 'tasks_screen.dart';
import 'weather_screen.dart';
import 'profile_screen.dart';

import 'harvest_page.dart';
import 'watering_page.dart';
import 'calendar_screen.dart';

class MainAppScreen extends StatefulWidget {
  final int initialIndex;

  const MainAppScreen({super.key, this.initialIndex = 0});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  bool _isCropsModule = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<NavItem> _mainNavItems = const [
    NavItem(icon: Icons.home_filled, label: 'HOME'),
    NavItem(icon: Icons.energy_savings_leaf_outlined, label: 'CROPS'),
    NavItem(icon: Icons.assignment_outlined, label: 'TASKS'),
    NavItem(icon: Icons.wb_sunny_outlined, label: 'WEATHER'),
    NavItem(icon: Icons.person_outline, label: 'PROFILE'),
  ];

  final List<NavItem> _cropsNavItems = const [
    NavItem(icon: Icons.grass, label: 'CROPS'),
    NavItem(icon: Icons.water_drop_outlined, label: 'WATERING'),
    NavItem(icon: Icons.agriculture_outlined, label: 'HARVESTS'),
    NavItem(icon: Icons.analytics_outlined, label: 'ANALYTICS'),
    NavItem(icon: Icons.grid_view_rounded, label: 'MAIN'),
  ];

  late List<Widget> _mainScreens;
  late List<Widget> _cropsScreens;

  List<Widget> get _currentScreens =>
      _isCropsModule ? _cropsScreens : _mainScreens;
  List<NavItem> get _currentNavItems =>
      _isCropsModule ? _cropsNavItems : _mainNavItems;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _mainScreens = [
      const HomeScreen(),
      const Center(child: Text("Module Entry")),
      const DailyTasksPage(),
      const WeatherScreen(),
      const ProfilePage(),
    ];

    _cropsScreens = [
      const FarmKeeperPage(),
      const WateringPage(),
      const HarvestPage(),
      const DashboardPage(),
      const Center(child: Text("Returning...")),
    ];

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!_isCropsModule && index == 1) {
      setState(() {
        _isCropsModule = true;
        _selectedIndex = 0;
      });
    } else if (_isCropsModule && index == 4) {
      setState(() {
        _isCropsModule = false;
        _selectedIndex = 1;
      });
    } else if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      return;
    }

    _triggerAnimation();
  }

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavbar(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: _selectedIndex, children: _currentScreens),
      ),
      items: _currentNavItems,
      floatingActionButton: (!_isCropsModule && _selectedIndex == 2)
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2E7D32),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Use Add Task to create a local task.'),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      appBar: (!_isCropsModule && _selectedIndex == 4)
          ? AppBar(
              backgroundColor: const Color(0xFFF4F7F1),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    context.push('/settings_screen');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    context.push('/notifications_screen');
                  },
                ),
              ],
            )
          : null,
      onNavItemTapped: _onItemTapped,
      currentIndex: _selectedIndex,
    );
  }
}
