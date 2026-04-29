import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
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
}
