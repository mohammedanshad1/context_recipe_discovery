// lib/screens/recipe_detail_screen.dart
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
  bool _isLoading = false;

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
    final isAdding = !_currentRecipe.isFavorite;
    
    // Update favorite in bloc
    context.read<RecipeBloc>().add(ToggleFavorite(_currentRecipe));
    
    // Update local state immediately for instant UI feedback
    setState(() {
      _currentRecipe = _currentRecipe.copyWith(isFavorite: isAdding);
    });
    
    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdding 
            ? '${_currentRecipe.name} added to favorites ✨'
            : '${_currentRecipe.name} removed from favorites',
          style: const TextStyle(fontSize: 14),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isAdding ? Colors.green[700] : Colors.grey[800],
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Undo favorite action
            final undoAdding = !isAdding;
            context.read<RecipeBloc>().add(ToggleFavorite(_currentRecipe));
            setState(() {
              _currentRecipe = _currentRecipe.copyWith(isFavorite: undoAdding);
            });
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Refresh home screen data when going back
        if (mounted) {
          // Reload recipes to update favorite status in home screen
          context.read<RecipeBloc>().add(LoadRecipes());
        }
        return true;
      },
      child: BlocListener<RecipeBloc, RecipeState>(
        listener: (context, state) {
          if (state is RecipeDetailsLoaded) {
            setState(() {
              _currentRecipe = state.recipe;
              _isLoading = false;
            });
          } else if (state is RecipeLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is RecipeError) {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _currentRecipe.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            elevation: 0,
            centerTitle: false,
            actions: [
              // Favorite button in app bar
              IconButton(
                icon: Icon(
                  _currentRecipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _currentRecipe.isFavorite ? Colors.red : null,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share recipe functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image with gradient overlay
                      Stack(
                        children: [
                          Hero(
                            tag: 'recipe-image-${_currentRecipe.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl: _currentRecipe.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      color: Colors.white,
                                     // borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 100),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Gradient overlay for better text visibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Recipe name and metadata
                      Text(
                        _currentRecipe.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category and area chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            icon: Icons.category,
                            label: _currentRecipe.category,
                            color: Colors.deepPurple,
                          ),
                          _buildInfoChip(
                            icon: Icons.public,
                            label: _currentRecipe.area,
                            color: Colors.teal,
                          ),
                          _buildInfoChip(
                            icon: Icons.kitchen,
                            label: '${_currentRecipe.ingredients.length} ingredients',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Ingredients section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shopping_basket, color: Colors.deepPurple[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _currentRecipe.ingredients.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final ingredient = _currentRecipe.ingredients[index];
                                final measure = _currentRecipe.measures[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[300],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '$measure $ingredient'.trim(),
                                        style: const TextStyle(fontSize: 16, height: 1.4),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Instructions section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.article, color: Colors.deepPurple[700]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Instructions',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentRecipe.instructions,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // External links section
                      if (_currentRecipe.youtubeUrl != null || _currentRecipe.sourceUrl != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Additional Resources',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_currentRecipe.youtubeUrl != null)
                                _buildExternalLinkButton(
                                  icon: Icons.play_circle_filled,
                                  label: 'Watch on YouTube',
                                  color: Colors.red,
                                  onPressed: () => _launchUrl(_currentRecipe.youtubeUrl!),
                                ),
                              if (_currentRecipe.sourceUrl != null)
                                const SizedBox(height: 8),
                              if (_currentRecipe.sourceUrl != null)
                                _buildExternalLinkButton(
                                  icon: Icons.link,
                                  label: 'View Original Source',
                                  color: Colors.blue,
                                  onPressed: () => _launchUrl(_currentRecipe.sourceUrl!),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalLinkButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }
}