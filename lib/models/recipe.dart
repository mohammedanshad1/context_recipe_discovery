class Recipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final List<String> ingredients;
  final List<String> measures;
  final String instructions;
  final String imageUrl;
  final String? youtubeUrl;
  final String? sourceUrl;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.ingredients,
    required this.measures,
    required this.instructions,
    required this.imageUrl,
    this.youtubeUrl,
    this.sourceUrl,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure ?? '');
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      ingredients: ingredients,
      measures: measures,
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      sourceUrl: json['strSource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': imageUrl,
      'strYoutube': youtubeUrl,
      'strSource': sourceUrl,
      'isFavorite': isFavorite,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    List<String>? ingredients,
    List<String>? measures,
    String? instructions,
    String? imageUrl,
    String? youtubeUrl,
    String? sourceUrl,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      ingredients: ingredients ?? this.ingredients,
      measures: measures ?? this.measures,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}