import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDeveloperSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Developer Settings', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<AppStateProvider>(context, listen: false).scheduleDailyTaskCheck();
                    debugPrint('Developer Settings: Scheduled daily task check');
                  },
                  child: const Text('Test Schedule Daily Task Check'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<AppStateProvider>(context, listen: false).checkAndUpdateTasks();
                    debugPrint('Developer Settings: Checked and updated tasks');
                  },
                  child: const Text('Check and Update Tasks'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.developer_mode),
          title: const Text('Developer Settings'),
          onTap: () => _showDeveloperSettingsDialog(context),
        ),
      ],
    );
  }
}