import 'package:flutter/material.dart';
import 'package:english_education/screens/name_input_screen.dart';
import 'package:english_education/screens/select_grade_screen.dart';
import 'package:english_education/screens/splash_screen.dart';
import 'package:english_education/screens/welcome_screen.dart';
import 'package:english_education/screens/main_menu_screen.dart';
import 'package:english_education/screens/game/learning_screen.dart';
import 'package:english_education/screens/game/playing_screen.dart';
import 'package:english_education/screens/game/exercise_screen.dart';
import 'package:english_education/screens/report_screen.dart';
import 'package:english_education/shared/game_grade.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------- Helpers ----------
GameGrade? _parseGrade(dynamic raw) {
  if (raw is GameGrade) return raw;

  if (raw is int && raw >= 1 && raw <= GameGrade.values.length) {
    // menerima 1..3 → enum
    return GameGrade.values[raw - 1];
  }

  if (raw is String) {
    // menerima “1”, “grade1”, “Grade 2”, dll
    final n = int.tryParse(raw.replaceAll(RegExp(r'\D'), ''));
    if (n != null && n >= 1 && n <= GameGrade.values.length) {
      return GameGrade.values[n - 1];
    }
  }

  return null;
}

/// Resolusi nama:
/// - jika argumen valid dan bukan "unknown" → pakai
/// - else → ambil dari SharedPreferences
/// - jika tetap kosong → "Player"
Future<String> _resolveName(dynamic raw) async {
  final fromArg = (raw is String ? raw : '').trim();
  if (fromArg.isNotEmpty && fromArg.toLowerCase() != 'unknown') {
    return fromArg;
  }
  final prefs = await SharedPreferences.getInstance();
  final fromPrefs = (prefs.getString('playerName') ?? '').trim();
  return fromPrefs.isEmpty ? 'Player' : fromPrefs;
}

/// ---------- Router ----------
Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case '/welcome':
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());

    case '/input-name':
      return MaterialPageRoute(builder: (_) => const InputNameScreen());

    case '/select-grade':
      return MaterialPageRoute(builder: (_) => const SelectGradeScreen());

    case '/main-menu':
      {
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('grade') ||
            !args.containsKey('playerName')) {
          return _errorRoute("Missing arguments for MainMenu");
        }
        return MaterialPageRoute(
          builder: (_) => MainMenuScreen(
            grade: args['grade'],
            playerName: args['playerName'],
          ),
        );
      }

    case '/learning':
      {
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('grade')) {
          return _errorRoute("Missing arguments for LearningScreen");
        }
        // LearningScreen kamu masih menerima int → teruskan apa adanya.
        return MaterialPageRoute(
          builder: (_) => LearningScreen(grade: args['grade']),
        );
      }

    case '/playing':
      {
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('grade')) {
          return _errorRoute("Missing arguments for PlayingScreen");
        }
        final grade = _parseGrade(args['grade']);
        if (grade == null) {
          return _errorRoute("Invalid grade: ${args['grade']}");
        }
        return MaterialPageRoute(builder: (_) => PlayingScreen(grade: grade));
      }

    case '/exercise':
      {
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('grade')) {
          // playerName tidak wajib di args karena ada fallback
          return _errorRoute("Missing arguments for ExerciseScreen");
        }
        final grade = _parseGrade(args['grade']);
        if (grade == null) {
          return _errorRoute("Invalid grade: ${args['grade']}");
        }

        // 🚀 Pastikan nama valid (fallback ke SharedPreferences bila perlu)
        final rawName = args['playerName']; // boleh null/unknown
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<String>(
            future: _resolveName(rawName),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final userName = snap.data!;
              return ExerciseScreen(grade: grade, userName: userName);
            },
          ),
        );
      }

    // routes.dart (di switch)
    case '/report':
      {
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('grade') ||
            !args.containsKey('playerName')) {
          return _errorRoute("Missing arguments for ReportScreen");
        }
        final grade = _parseGrade(args['grade']);
        if (grade == null)
          return _errorRoute("Invalid grade: ${args['grade']}");
        final userName = (args['playerName'] as String?) ?? 'Player';
        return MaterialPageRoute(
          builder: (_) => ReportScreen(playerName: userName, grade: grade),
        );
      }

    default:
      return _errorRoute("Route not found: ${settings.name}");
  }
}

Route<dynamic> _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(message)),
    ),
  );
}
