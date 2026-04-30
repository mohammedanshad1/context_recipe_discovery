import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'bloc/recipe_bloc.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize local storage
  final localStorage = LocalStorageService();
  await localStorage.init();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(MyApp(localStorage: localStorage));
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorage;

  const MyApp({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Expose LocalStorageService so FavoritesScreen can read it directly
        RepositoryProvider<LocalStorageService>(
          create: (_) => localStorage,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RecipeBloc(
              ApiService(),
              localStorage,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Recipe Discovery',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}