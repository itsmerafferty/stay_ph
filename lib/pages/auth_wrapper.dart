import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import 'login_page.dart';
import 'tenant/tenant_dashboard.dart';
import 'landlord/landlord_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Handle connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if there was an error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Check if user is logged in
        final session = snapshot.data?.session;
        if (session == null) {
          return const LoginPage();
        }

        // User is logged in - fetch profile to determine role
        return FutureBuilder<UserProfile?>(
          future: authService.getCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            // Loading profile
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Error loading profile
            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading profile: ${profileSnapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await authService.signOut();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = profileSnapshot.data;

            // No profile found (shouldn't happen but handle gracefully)
            if (profile == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 60, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text('Profile not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await authService.signOut();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Route based on role
            switch (profile.role) {
              case UserRole.tenant:
                return TenantDashboard(profile: profile);
              case UserRole.landlord:
                return LandlordDashboard(profile: profile);
            }
          },
        );
      },
    );
  }
}
