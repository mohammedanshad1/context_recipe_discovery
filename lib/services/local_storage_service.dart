import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorites';
  static const String _cachedRecipesKey = 'cached_recipes';
  static const _lastSearchKey = 'last_search_query';
  static const _lastViewedRecipeKey = 'last_viewed_recipe_id';

  late SharedPreferences _prefs;
  String? lastSearchQuery;
  String? lastViewedRecipeId;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    lastSearchQuery = _prefs.getString(_lastSearchKey);
    lastViewedRecipeId = _prefs.getString(_lastViewedRecipeKey);
  }

  Future<void> saveLastSearchQuery(String query) async {
    lastSearchQuery = query;
    await _prefs.setString(_lastSearchKey, query);
  }

  Future<void> saveLastViewedRecipeId(String recipeId) async {
    lastViewedRecipeId = recipeId;
    await _prefs.setString(_lastViewedRecipeKey, recipeId);
  }

  Future<void> saveFavorite(Recipe recipe) async {
    final favorites = await getFavorites();
    favorites[recipe.id] = recipe.copyWith(isFavorite: true);
    final jsonList = favorites.values.map((r) => json.encode(r.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  Future<void> removeFavorite(String recipeId) async {
    final favorites = await getFavorites();
    favorites.remove(recipeId);
    final jsonList = favorites.values.map((r) => json.encode(r.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  Future<Map<String, Recipe>> getFavorites() async {
    final jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    final favorites = <String, Recipe>{};
    for (final jsonStr in jsonList) {
      final recipe = Recipe.fromJson(json.decode(jsonStr));
      favorites[recipe.id] = recipe.copyWith(isFavorite: true);
    }
    return favorites;
  }

  Future<void> cacheRecipe(Recipe recipe) async {
    final cached = await getCachedRecipes();
    cached[recipe.id] = recipe;
    final jsonList = cached.values.map((r) => json.encode(r.toJson())).toList();
    await _prefs.setStringList(_cachedRecipesKey, jsonList);
  }

  Future<Map<String, Recipe>> getCachedRecipes() async {
    final jsonList = _prefs.getStringList(_cachedRecipesKey) ?? [];
    final cached = <String, Recipe>{};
    for (final jsonStr in jsonList) {
      final recipe = Recipe.fromJson(json.decode(jsonStr));
      cached[recipe.id] = recipe;
    }
    return cached;
  }

  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavorites();
    return favorites.containsKey(recipeId);
  }
}
