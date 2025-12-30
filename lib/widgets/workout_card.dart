import 'package:flutter/material.dart';

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
