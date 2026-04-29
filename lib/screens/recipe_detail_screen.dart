import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/recipe_bloc.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _currentRecipe;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    // Load full details if not already loaded
    if (_currentRecipe.instructions.isEmpty) {
      context.read<RecipeBloc>().add(LoadRecipeDetails(_currentRecipe.id));
    }
  }

  void _toggleFavorite() {
    context.read<RecipeBloc>().add(ToggleFavorite(_currentRecipe));
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeDetailsLoaded) {
          setState(() {
            _currentRecipe = state.recipe;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentRecipe.name),
          actions: [
            IconButton(
              icon: Icon(
                _currentRecipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _currentRecipe.isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with shimmer
              Hero(
                tag: 'recipe-image-${_currentRecipe.id}',
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: _currentRecipe.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _currentRecipe.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentRecipe.category} • ${_currentRecipe.area}',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._currentRecipe.ingredients.asMap().entries.map((entry) {
                int index = entry.key;
                String ingredient = entry.value;
                String measure = _currentRecipe.measures[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $measure $ingredient'),
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_currentRecipe.instructions),
              const SizedBox(height: 16),
              if (_currentRecipe.youtubeUrl != null)
                ElevatedButton.icon(
                  onPressed: () => _launchUrl(_currentRecipe.youtubeUrl!),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Watch on YouTube'),
                ),
              if (_currentRecipe.sourceUrl != null) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _launchUrl(_currentRecipe.sourceUrl!),
                  icon: const Icon(Icons.link),
                  label: const Text('View Source'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}