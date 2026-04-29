import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';
import '../services/location_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/search_bar.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  String? _currentArea;
  String? _suggestedCategory;

  @override
  void initState() {
    super.initState();
    _initializeSuggestions();
  }

  Future<void> _initializeSuggestions() async {
    await _getLocationAndSuggest();
    _suggestBasedOnTime();
  }

  Future<void> _getLocationAndSuggest() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final country = await _locationService.getCountryFromPosition(position);
        if (country != null) {
          setState(() {
            _currentArea = _mapCountryToArea(country);
          });
        }
      }
    }
  }

  String _mapCountryToArea(String country) {
    // Simple mapping - in real app, use a more comprehensive mapping
    final countryToArea = {
      'United States': 'American',
      'United Kingdom': 'British',
      'Italy': 'Italian',
      'Mexico': 'Mexican',
      'India': 'Indian',
      'China': 'Chinese',
      'Japan': 'Japanese',
      'France': 'French',
      'Germany': 'German',
      'Spain': 'Spanish',
      // Add more mappings as needed
    };
    return countryToArea[country] ?? 'American';
  }

  void _suggestBasedOnTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 12) {
      _suggestedCategory = 'Breakfast';
    } else if (hour >= 12 && hour < 17) {
      _suggestedCategory = 'Lunch';
    } else {
      _suggestedCategory = 'Dinner';
    }

    // Load suggested recipes
    context.read<RecipeBloc>().add(LoadRecipes(category: _suggestedCategory));
  }

  void _onSearch(String query) {
    context.read<RecipeBloc>().add(LoadRecipes(searchQuery: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              context.read<RecipeBloc>().add(LoadFavorites());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(onSearch: _onSearch),
                const SizedBox(height: 16),
                if (_suggestedCategory != null)
                  Text(
                    'Suggested for ${_suggestedCategory!.toLowerCase()}:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                if (_currentArea != null)
                  Text(
                    'Popular in $_currentArea cuisine',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state is RecipeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RecipeLoaded) {
                  return ListView.builder(
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is RecipeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<RecipeBloc>().add(LoadCachedRecipes());
                          },
                          child: const Text('Load Cached Recipes'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Welcome to Recipe Discovery!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}