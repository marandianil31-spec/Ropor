import 'package:flutter/material.dart';

class WarningCard extends StatelessWidget {
  const WarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Text("Community Guidelines"),
        subtitle: Text(
          "Be respectful. Don't share personal information with strangers.",
        ),
      ),
    );
  }
}
