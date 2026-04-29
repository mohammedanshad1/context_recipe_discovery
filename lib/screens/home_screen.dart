import 'package:context_recipe_discovery/widgets/skelton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';
import '../services/location_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/search_bar.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialArea;
  final String? suggestedCategory;

  const HomeScreen({
    super.key,
    this.initialArea,
    this.suggestedCategory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  String? _currentArea;
  String? _suggestedCategory;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Use data from splash screen if available
    if (widget.initialArea != null) {
      _currentArea = widget.initialArea;
    } else {
      await _getLocationAndSuggest();
    }
    
    if (widget.suggestedCategory != null) {
      _suggestedCategory = widget.suggestedCategory;
    } else {
      _suggestBasedOnTime();
    }
    
    // Load initial recipes
    _loadRecipes();
    
    setState(() {
      _isDataLoaded = true;
    });
  }

  Future<void> _getLocationAndSuggest() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission && mounted) {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        final country = await _locationService.getCountryFromPosition(position);
        if (country != null && mounted) {
          setState(() {
            _currentArea = _mapCountryToArea(country);
          });
        }
      }
    }
  }

  String _mapCountryToArea(String country) {
    final countryToArea = {
      'United States': 'American',
      'United Kingdom': 'British',
      'Canada': 'Canadian',
      'Italy': 'Italian',
      'Mexico': 'Mexican',
      'India': 'Indian',
      'China': 'Chinese',
      'Japan': 'Japanese',
      'France': 'French',
      'Germany': 'German',
      'Spain': 'Spanish',
      'Thailand': 'Thai',
    };
    return countryToArea[country] ?? 'International';
  }

  void _suggestBasedOnTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _suggestedCategory = 'Breakfast';
    } else if (hour >= 12 && hour < 17) {
      _suggestedCategory = 'Lunch';
    } else {
      _suggestedCategory = 'Dinner';
    }
  }

  void _loadRecipes() {
    final bloc = context.read<RecipeBloc>();
    
    if (_suggestedCategory != null && _currentArea != null) {
      bloc.add(LoadRecipes(
        category: _suggestedCategory,
        area: _currentArea,
      ));
    } else if (_suggestedCategory != null) {
      bloc.add(LoadRecipes(category: _suggestedCategory));
    } else if (_currentArea != null) {
      bloc.add(LoadRecipes(area: _currentArea));
    } else {
      bloc.add( LoadRecipes());
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<RecipeBloc>().add(LoadRecipes(searchQuery: query));
    } else {
      _loadRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Discovery'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              context.read<RecipeBloc>().add( LoadFavorites());
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
                const SizedBox(height: 12),
                if (_suggestedCategory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.deepPurple.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Suggested for $_suggestedCategory',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_currentArea != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Popular in $_currentArea cuisine',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                // Show skeleton loader while loading
                if (state is RecipeLoading) {
                  return const SkeletonLoader();
                }
                
                // Show loaded recipes
                if (state is RecipeLoaded) {
                  if (state.recipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No recipes found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadRecipes,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(
                        recipe: state.recipes[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: state.recipes[index]),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                
                // Show error state
                if (state is RecipeError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<RecipeBloc>().add( LoadCachedRecipes());
                            },
                            icon: const Icon(Icons.folder),
                            label: const Text('Load Saved Recipes'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadRecipes,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Default - show skeleton
                return const SkeletonLoader();
              },
            ),
          ),
        ],
      ),
    );
  }
}