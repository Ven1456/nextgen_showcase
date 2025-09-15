import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.isDark, required this.onToggleDark, required this.stunEnabled, required this.onToggleStun});

  final bool isDark;
  final void Function(bool) onToggleDark;
  final bool stunEnabled;
  final void Function(bool) onToggleStun;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: const Text('Dark mode'),
          value: isDark,
          onChanged: onToggleDark,
        ),
        SwitchListTile(
          title: const Text('Stun Mode (animated gradient + glass)'),
          value: stunEnabled,
          onChanged: onToggleStun,
        ),
        const ListTile(
          title: Text('About'),
          subtitle: Text('This example showcases multiple use cases and a live playground.'),
        ),
      ],
    );
  }
}


