class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;
  final List<String> tags;
  final int prepTime;
  final int cookTime;
  final int servings;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.tags,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      servings: json['servings'],
    );
  }
}