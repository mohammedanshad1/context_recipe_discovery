import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/recipe.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with shimmer loading
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: widget.recipe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: IconButton(
                              icon: Icon(
                                widget.recipe.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: widget.recipe.isFavorite ? Colors.red : null,
                              ),
                              onPressed: () {
                                if (!widget.recipe.isFavorite) {
                                  _animationController.forward().then((_) {
                                    _animationController.reverse();
                                  });
                                }
                                // Handle favorite toggle in parent
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.recipe.category} • ${widget.recipe.area}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.instructions.length > 100
                        ? '${widget.recipe.instructions.substring(0, 100)}...'
                        : widget.recipe.instructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}