import '../models/recipe.dart';

List<Recipe> mockRecipes = [
  Recipe(
    id: '1',
    name: 'Spaghetti Carbonara',
    description: 'A classic Italian pasta dish with eggs, cheese, and pancetta.',
    ingredients: [
      '200g spaghetti',
      '100g pancetta',
      '2 large eggs',
      '50g grated Parmesan cheese',
      'Black pepper',
      'Salt'
    ],
    instructions: [
      'Cook spaghetti in salted boiling water until al dente.',
      'Fry pancetta until crispy.',
      'Whisk eggs with cheese and pepper.',
      'Drain pasta, mix with pancetta, then add egg mixture off heat.',
      'Serve immediately.'
    ],
    imageUrl: 'https://example.com/spaghetti.jpg',
    tags: ['Italian', 'Pasta', 'Quick'],
    prepTime: 10,
    cookTime: 15,
    servings: 2,
  ),
  Recipe(
    id: '2',
    name: 'Chicken Stir Fry',
    description: 'Quick and healthy stir-fried chicken with vegetables.',
    ingredients: [
      '300g chicken breast',
      '2 bell peppers',
      '1 broccoli head',
      '2 tbsp soy sauce',
      '1 tbsp oil',
      'Garlic and ginger'
    ],
    instructions: [
      'Cut chicken and vegetables.',
      'Heat oil, cook chicken until done.',
      'Add vegetables, stir fry.',
      'Add soy sauce, serve with rice.'
    ],
    imageUrl: 'https://example.com/stirfry.jpg',
    tags: ['Healthy', 'Asian', 'Quick'],
    prepTime: 15,
    cookTime: 10,
    servings: 2,
  ),
  Recipe(
    id: '3',
    name: 'Chocolate Chip Cookies',
    description: 'Classic homemade cookies that are soft and chewy.',
    ingredients: [
      '1 cup butter',
      '1 cup sugar',
      '1 cup brown sugar',
      '2 eggs',
      '2 cups flour',
      '1 tsp vanilla',
      '2 cups chocolate chips'
    ],
    instructions: [
      'Cream butter and sugars.',
      'Add eggs and vanilla.',
      'Mix in flour, then chocolate chips.',
      'Bake at 350°F for 10-12 minutes.'
    ],
    imageUrl: 'https://example.com/cookies.jpg',
    tags: ['Dessert', 'Baking', 'Comfort'],
    prepTime: 20,
    cookTime: 12,
    servings: 24,
  ),
];