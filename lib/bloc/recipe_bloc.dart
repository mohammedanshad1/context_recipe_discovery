// lib/bloc/recipe_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

abstract class RecipeEvent {}

class LoadRecipes extends RecipeEvent {
  final String? category;
  final String? area;
  final String? searchQuery;

  LoadRecipes({this.category, this.area, this.searchQuery});
}

class LoadRecipeDetails extends RecipeEvent {
  final String recipeId;

  LoadRecipeDetails(this.recipeId);
}

class ToggleFavorite extends RecipeEvent {
  final Recipe recipe;

  ToggleFavorite(this.recipe);
}

class LoadFavorites extends RecipeEvent {}

class LoadCachedRecipes extends RecipeEvent {}

abstract class RecipeState {}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;

  RecipeLoaded(this.recipes);
}

class RecipeDetailsLoaded extends RecipeState {
  final Recipe recipe;

  RecipeDetailsLoaded(this.recipe);
}

class RecipeError extends RecipeState {
  final String message;

  RecipeError(this.message);
}

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  RecipeBloc(this._apiService, this._localStorage) : super(RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<LoadCachedRecipes>(_onLoadCachedRecipes);
  }

  Future<void> _onLoadRecipes(LoadRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      List<Recipe> recipes = [];

      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        recipes = await _apiService.searchRecipes(event.searchQuery!);
      } else if (event.category != null) {
        recipes = await _apiService.fetchRecipesByCategory(event.category!);
      } else if (event.area != null) {
        recipes = await _apiService.fetchRecipesByArea(event.area!);
      } else {
        recipes = await _apiService.searchRecipes('chicken');
      }

      final favorites = await _localStorage.getFavorites();
      recipes = recipes.map((recipe) {
        return recipe.copyWith(isFavorite: favorites.containsKey(recipe.id));
      }).toList();

      emit(RecipeLoaded(recipes));
    } catch (e) {
      final cached = await _localStorage.getCachedRecipes();
      if (cached.isNotEmpty) {
        emit(RecipeLoaded(cached.values.toList()));
      } else {
        emit(RecipeError('Failed to load recipes. Please check your internet connection.'));
      }
    }
  }

  Future<void> _onLoadRecipeDetails(LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      Recipe? recipe = await _apiService.fetchRecipeDetails(event.recipeId);
      if (recipe != null) {
        final isFavorite = await _localStorage.isFavorite(recipe.id);
        recipe = recipe.copyWith(isFavorite: isFavorite);
        await _localStorage.cacheRecipe(recipe);
        emit(RecipeDetailsLoaded(recipe));
      } else {
        emit(RecipeError('Recipe not found'));
      }
    } catch (e) {
      final cached = await _localStorage.getCachedRecipes();
      final recipe = cached[event.recipeId];
      if (recipe != null) {
        emit(RecipeDetailsLoaded(recipe));
      } else {
        emit(RecipeError('Failed to load recipe details'));
      }
    }
  }

 // lib/bloc/recipe_bloc.dart (Update the _onToggleFavorite method)
Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<RecipeState> emit) async {
  final newFavoriteStatus = !event.recipe.isFavorite;
  
  if (newFavoriteStatus) {
    await _localStorage.saveFavorite(event.recipe);
  } else {
    await _localStorage.removeFavorite(event.recipe.id);
  }
  
  final updatedRecipe = event.recipe.copyWith(isFavorite: newFavoriteStatus);
  
  // Update RecipeDetailsLoaded state if it exists
  if (state is RecipeDetailsLoaded) {
    emit(RecipeDetailsLoaded(updatedRecipe));
  }
  
  // Update RecipeLoaded state if it exists
  if (state is RecipeLoaded) {
    final currentState = state as RecipeLoaded;
    final updatedRecipes = currentState.recipes.map((recipe) {
      if (recipe.id == updatedRecipe.id) {
        return updatedRecipe;
      }
      return recipe;
    }).toList();
    emit(RecipeLoaded(updatedRecipes));
  }
}
  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      final favorites = await _localStorage.getFavorites();
      emit(RecipeLoaded(favorites.values.toList()));
    } catch (e) {
      emit(RecipeError('Failed to load favorites'));
    }
  }

  Future<void> _onLoadCachedRecipes(LoadCachedRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      final cached = await _localStorage.getCachedRecipes();
      emit(RecipeLoaded(cached.values.toList()));
    } catch (e) {
      emit(RecipeError('Failed to load cached recipes'));
    }
  }
}