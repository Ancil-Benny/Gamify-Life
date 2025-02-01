import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('Theme'),
          subtitle: Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Text(
                appState.themeMode == ThemeMode.light
                    ? 'Light Mode'
                    : appState.themeMode == ThemeMode.dark
                        ? 'Dark Mode'
                        : 'System Default',
              );
            },
          ),
          onTap: () => _showThemeDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Reset'),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const ResetDialog(),
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Mode'),
                    value: ThemeMode.light,
                    groupValue: appState.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setThemeMode(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Mode'),
                    value: ThemeMode.dark,
                    groupValue: appState.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setThemeMode(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: appState.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        appState.setThemeMode(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ResetDialog extends StatefulWidget {
  const ResetDialog({super.key});

  @override
  State<ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<ResetDialog> {
  final List<bool> resetOptions = List<bool>.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Reset History Log'),
              value: resetOptions[0],
              onChanged: (bool? value) {
                setState(() {
                  resetOptions[0] = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Delete All Tasks'),
              value: resetOptions[1],
              onChanged: (bool? value) {
                setState(() {
                  resetOptions[1] = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Delete Rewards'),
              value: resetOptions[2],
              onChanged: (bool? value) {
                setState(() {
                  resetOptions[2] = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Reset Coins'),
              value: resetOptions[3],
              onChanged: (bool? value) {
                setState(() {
                  resetOptions[3] = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Reset XP and Level'),
              value: resetOptions[4],
              onChanged: (bool? value) {
                setState(() {
                  resetOptions[4] = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Select All'),
              value: resetOptions.every((element) => element),
              onChanged: (bool? value) {
                setState(() {
                  for (int i = 0; i < resetOptions.length; i++) {
                    resetOptions[i] = value ?? false;
                  }
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _showConfirmResetDialog(context, resetOptions),
          child: const Text('Done'),
        ),
      ],
    );
  }

  void _showConfirmResetDialog(BuildContext context, List<bool> resetOptions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to reset the selected options?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                if (resetOptions[0]) appState.resetHistoryLog();
                if (resetOptions[1]) appState.deleteAllTasks();
                if (resetOptions[2]) appState.deleteRewards();
                if (resetOptions[3]) appState.resetCoins();
                if (resetOptions[4]) appState.resetXPAndLevel();
                // If all are selected, you can optionally call appState.resetAll()
                // or just rely on each individual reset if you'd rather keep them separate.

                Navigator.of(context).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close the reset dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}