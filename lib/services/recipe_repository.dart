import 'dart:math';

import '../data/mock_recipes.dart';
import '../models/recipe.dart';
import 'local_storage_service.dart';

class RecipeRepository {
  final LocalStorageService storage;
  List<Recipe> _recipes = [];

  RecipeRepository(this.storage);

  Future<List<Recipe>> loadRecipes() async {
    // Offline-first: always load from the local bundle; no network required.
    await Future.delayed(const Duration(milliseconds: 250));
    _recipes = List<Recipe>.from(mockRecipes);
    return _recipes;
  }

  List<Recipe> getRecipes() {
    return List<Recipe>.from(_recipes);
  }

  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) {
      return getRecipes();
    }

    final lowerQuery = query.toLowerCase();
    return _recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
          recipe.category.toLowerCase().contains(lowerQuery) ||
          recipe.area.toLowerCase().contains(lowerQuery) ||
          recipe.instructions.toLowerCase().contains(lowerQuery) ||
          recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Recipe> getRecommendedRecipes() {
    if (_recipes.isEmpty) {
      return [];
    }
    final top = min(3, _recipes.length);
    return _recipes.take(top).toList();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastViewedRecipe(String id) async {
    await storage.saveLastViewedRecipeId(id);
  }
}
