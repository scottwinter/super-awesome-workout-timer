import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_awesome_workout_timer/screens/amrap_screen.dart';
import 'package:super_awesome_workout_timer/screens/emom_screen.dart';
import 'package:super_awesome_workout_timer/screens/fortime_screen.dart';
import 'package:super_awesome_workout_timer/screens/pyramid_screen.dart';
import 'package:super_awesome_workout_timer/screens/tabata_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const WorkoutTimerApp());
}

class WorkoutTimerApp extends StatelessWidget {
  const WorkoutTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Awesome Workout Timer'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
        children: const [
          WorkoutCard(
              title: 'AMRAP',
              icon: Icons.repeat,
              destination: AmrapScreen(),
            ),
            WorkoutCard(
              title: 'Pyramid',
              icon: Icons.stacked_line_chart,
              destination: PyramidScreen(),
            ),
            WorkoutCard(
              title: 'EMOM',
              icon: Icons.timer,
              destination: EmomScreen(),
            ),
            WorkoutCard(
              title: 'For Time',
              icon: Icons.speed,
              destination: ForTimeScreen(),
            ),
            WorkoutCard(
              title: 'Tabata',
              icon: Icons.whatshot,
              destination: TabataScreen(),
            ),
        ],
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget destination;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.icon,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 8.0,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50.0,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}