import '../models/recipe.dart';

List<Recipe> mockRecipes = [
  Recipe(
    id: '1',
    name: 'Spaghetti Carbonara',
    category: 'Pasta',
    area: 'Italian',
    ingredients: [
      '200g spaghetti',
      '100g pancetta',
      '2 large eggs',
      '50g grated Parmesan cheese',
      'Black pepper',
      'Salt'
    ],
    measures: [
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    instructions: 'Cook spaghetti in salted boiling water until al dente. Fry pancetta until crispy. Whisk eggs with cheese and pepper. Drain pasta, mix with pancetta, then add egg mixture off heat. Serve immediately.',
    imageUrl: 'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
    youtubeUrl: 'https://www.youtube.com/watch?v=8o9C_AF4rKQ',
    sourceUrl: 'https://www.bbcgoodfood.com/recipes/ultimate-spaghetti-carbonara-recipe',
  ),
  Recipe(
    id: '2',
    name: 'Chicken Stir Fry',
    category: 'Chicken',
    area: 'Chinese',
    ingredients: [
      '300g chicken breast',
      '2 bell peppers',
      '1 broccoli head',
      '2 tbsp soy sauce',
      '1 tbsp oil',
      'Garlic',
      'Ginger'
    ],
    measures: [
      '',
      '',
      '',
      '',
      '',
      '2 cloves',
      '1 inch'
    ],
    instructions: 'Cut chicken and vegetables. Heat oil, cook chicken until done. Add vegetables, stir fry. Add soy sauce, serve with rice.',
    imageUrl: 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
    youtubeUrl: null,
    sourceUrl: null,
  ),
  Recipe(
    id: '3',
    name: 'Chocolate Chip Cookies',
    category: 'Dessert',
    area: 'American',
    ingredients: [
      '1 cup butter',
      '1 cup sugar',
      '1 cup brown sugar',
      '2 eggs',
      '2 cups flour',
      '1 tsp vanilla',
      '2 cups chocolate chips'
    ],
    measures: [
      'softened',
      '',
      '',
      '',
      '',
      '',
      ''
    ],
    instructions: 'Cream butter and sugars. Add eggs and vanilla. Mix in flour, then chocolate chips. Bake at 350°F for 10-12 minutes.',
    imageUrl: 'https://www.themealdb.com/images/media/meals/1548771604304.jpg',
    youtubeUrl: null,
    sourceUrl: null,
  ),
];