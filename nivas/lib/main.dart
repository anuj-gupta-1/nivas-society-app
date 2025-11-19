import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivas/services/hive_service.dart';
import 'package:nivas/providers/auth_provider.dart';
import 'package:nivas/screens/auth/phone_entry_screen.dart';
import 'package:nivas/screens/home/home_screen.dart';
import 'package:nivas/screens/auth/verification_pending_screen.dart';
import 'package:nivas/screens/project/project_selection_screen.dart';
import 'package:nivas/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive (local storage)
  await HiveService.init();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Nivas - Society Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // Not logged in - show phone entry
          return const PhoneEntryScreen();
        }
        
        // User is logged in - check verification status
        final userDataAsync = ref.watch(currentUserProvider);
        
        return userDataAsync.when(
          data: (userData) {
            if (userData == null) {
              return const PhoneEntryScreen();
            }
            
            // Check if user has any project memberships
            final membershipsAsync = ref.watch(userMembershipsProvider);
            
            return membershipsAsync.when(
              data: (memberships) {
                if (memberships.isEmpty) {
                  // No memberships yet - still in registration
                  return const VerificationPendingScreen();
                }
                
                // Check if any membership is approved
                final approvedMemberships = memberships
                    .where((m) => m.verificationStatus == 'approved')
                    .toList();
                
                if (approvedMemberships.isEmpty) {
                  // All memberships pending - show pending screen
                  return const VerificationPendingScreen();
                }
                
                // User has approved memberships
                // Check if current project is set
                final currentProjectId = ref.watch(currentProjectIdProvider);
                
                if (currentProjectId == null) {
                  // No project selected - show project selection
                  return const ProjectSelectionScreen();
                }
                
                // All good - show home screen
                return const HomeScreen();
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Scaffold(
                body: Center(
                  child: Text('Error loading memberships: $error'),
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Text('Error loading user data: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Authentication error: $error'),
        ),
      ),
    );
  }
}

