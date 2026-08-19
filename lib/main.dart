import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'repositories/content_repository.dart';
import 'services/storage_service.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const StetApp());
}

class StetApp extends StatelessWidget {
  const StetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bihar STET 2026 - Computer Science',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppLoader(),
    );
  }
}

/// Loads all bundled JSON study content once, then routes to either the
/// one-time local profile setup screen or straight to the Home dashboard.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await ContentRepository.instance.load();
      final name = await StorageService.instance.getProfileName();
      final hasSetProfile = name.isNotEmpty;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              hasSetProfile ? const HomeScreen() : const ProfileSetupScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_outlined, color: Colors.white, size: 56),
              const SizedBox(height: 16),
              const Text(
                'BIHAR STET 2026',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              const Text(
                'PAPER 2 • COMPUTER SCIENCE',
                style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2),
              ),
              const SizedBox(height: 32),
              if (_error) ...[
                const Icon(Icons.error_outline, color: AppColors.accent, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Could not load study content.\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = false);
                    _bootstrap();
                  },
                  child: const Text('Retry'),
                ),
              ] else
                const CircularProgressIndicator(color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
