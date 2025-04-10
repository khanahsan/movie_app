import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_app/views/screens/popular_movies_screen.dart';
import 'package:movie_app/views/screens/search_movies_screen.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/providers/theme_provider.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'favorite_movies_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = [
    PopularMoviesScreen(),
    SearchMoviesScreen(),
    FavoriteMoviesScreen(),
  ];

  final List<String> _screenTitles = [
    'Popular Movies',
    'Search',
    'Favorites',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearching = false;
      _searchController.clear();
      if (_selectedIndex == 1) {
        (_screens[1] as SearchMoviesScreen).resetSearch();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        (_screens[1] as SearchMoviesScreen).resetSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching && _selectedIndex == 1
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            final content = _screens[1] as SearchMoviesScreen;
            content.updateSearchQuery(query);
          },
        )
            : Text(_screenTitles[_selectedIndex],style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),

          // Add the animated toggle button for theme switching
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child:
                AnimatedToggleSwitch<bool>.dual(
                  current: themeProvider.themeMode == ThemeMode.dark,
                  first: false, // Light mode
                  second: true, // Dark mode
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                    return Future.value(true);
                  },
                  spacing: 8.0,
                  style: ToggleStyle(
                    //borderColor: Colors.transparent,
                    borderColor: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.transparent // Deep Navy for dark mode
                        : const Color(0xFFD4AF37),
                    backgroundColor: const Color(0xFFF5E0B7), // Light Gold to match AppBar
                    indicatorColor: themeProvider.themeMode == ThemeMode.dark
                        ? const Color(0xFF0A1D37) // Deep Navy for dark mode
                        : const Color(0xFFD4AF37), // Gold for light mode
                  ),
                  iconBuilder: (value) => value
                      ? const Icon(
                    Icons.dark_mode,
                    color: Colors.white,
                    size: 20,
                  )
                      : const Icon(
                    Icons.light_mode,
                    color: Colors.white, // Gold to match light theme
                    size: 20,
                  ),
                  textBuilder: (value) => value
                      ? const Text(
                    'Dark',
                    style: TextStyle(
                      color: Color(0xFFFFF8E1), // Soft Cream for dark mode
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : const Text(
                    'Light',
                    style: TextStyle(
                      color: Color(0xFF1C2526), // Deep Charcoal for light mode
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  animationDuration: const Duration(milliseconds: 500),
                  height: 36.0,
                  borderWidth: 2.0,
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


