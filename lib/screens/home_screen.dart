import 'package:flutter/material.dart';
import 'package:super_awesome_workout_timer/screens/amrap_screen.dart';
import 'package:super_awesome_workout_timer/screens/emom_screen.dart';
import 'package:super_awesome_workout_timer/screens/fortime_screen.dart';
import 'package:super_awesome_workout_timer/screens/pyramid_screen.dart';
import 'package:super_awesome_workout_timer/screens/tabata_screen.dart';
import 'package:super_awesome_workout_timer/widgets/workout_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
