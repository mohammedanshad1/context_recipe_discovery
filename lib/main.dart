import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'bloc/recipe_bloc.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize services
  final localStorage = LocalStorageService();
  await localStorage.init();

  // Initialize notifications
  await NotificationService.initialize();
  await NotificationService.scheduleMealNotifications();

  runApp(MyApp(localStorage: localStorage));
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorage;

  const MyApp({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
