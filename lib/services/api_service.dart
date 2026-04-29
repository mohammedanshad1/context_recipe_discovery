import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> fetchRecipesByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null) {
        return meals.map((meal) => Recipe.fromJson(meal)).toList();
      }
    }
    return [];
  }

  Future<List<Recipe>> fetchRecipesByArea(String area) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=$area'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null) {
        return meals.map((meal) => Recipe.fromJson(meal)).toList();
      }
    }
    return [];
  }

  Future<Recipe?> fetchRecipeDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        return Recipe.fromJson(meals[0]);
      }
    }
    return null;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null) {
        return meals.map((meal) => Recipe.fromJson(meal)).toList();
      }
    }
    return [];
  }

  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = data['categories'] as List?;
      if (categories != null) {
        return categories.map((cat) => cat['strCategory'] as String).toList();
      }
    }
    return [];
  }

  Future<List<String>> fetchAreas() async {
    final response = await http.get(Uri.parse('$baseUrl/list.php?a=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final areas = data['meals'] as List?;
      if (areas != null) {
        return areas.map((area) => area['strArea'] as String).toList();
      }
    }
    return [];
  }
}