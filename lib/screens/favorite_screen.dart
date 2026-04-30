// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';
import '../services/local_storage_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final localStorage = context.read<LocalStorageService>();
      final favMap = await localStorage.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favMap.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load favorites';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Recipe recipe) async {
    try {
      final localStorage = context.read<LocalStorageService>();
      await localStorage.removeFavorite(recipe.id);

      // Instantly remove from local list
      setState(() {
        _favorites.removeWhere((r) => r.id == recipe.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove favorite')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener watches for ToggleFavorite changes fired by RecipeCard's heart button
    return BlocListener<RecipeBloc, RecipeState>(
      listenWhen: (previous, current) =>
          current is RecipeLoaded || current is RecipeDetailsLoaded,
      listener: (context, state) {
        // Re-sync local list whenever bloc state changes (e.g. heart tapped in card)
        _loadFavorites();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites'),
          elevation: 0,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any recipe to add it here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final recipe = _favorites[index];
          return Dismissible(
            key: Key(recipe.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await _removeFavorite(recipe);
              return false; // we handle removal manually via setState
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.white, size: 28),
            ),
            child: RecipeCard(
              recipe: recipe.copyWith(isFavorite: true),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
                if (mounted) _loadFavorites();
              },
            ),
          );
        },
      ),
    );
  }
}