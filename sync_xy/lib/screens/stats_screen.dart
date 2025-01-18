import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_xy/providers/app_state_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final level = appState.level;
    final xp = appState.xp;
    final coins = appState.coins;
    final nextLevelXp = 100 * (1 << (level - 1)); // Double XP for each level
    final historyLog = appState.historyLog.where((log) {
      final logDate = DateTime.parse(log['date']);
      return logDate.year == _selectedDate.year &&
             logDate.month == _selectedDate.month &&
             logDate.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Color.fromARGB(255, 112, 73, 180)),
                title: const Text('Level'),
                subtitle: Text('$level'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Color.fromARGB(255, 112, 73, 180)),
                title: const Text('XP'),
                subtitle: Text('$xp / $nextLevelXp'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on, color: Color.fromARGB(255, 112, 73, 180)),
                title: const Text('Coins'),
                subtitle: Text('$coins'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Coins Earned Over Time', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                series: <ChartSeries>[
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: appState.historyLog,
                    xValueMapper: (log, _) => DateTime.parse(log['date']),
                    yValueMapper: (log, _) => log['coins'],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('History Log', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 112, 73, 180)),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: historyLog.length,
                itemBuilder: (context, index) {
                  final log = historyLog[index];
                  final name = log['name'] ?? 'Unknown';
                  final date = log['date'] ?? 'Unknown';
                  final action = log['action'] ?? 'Unknown';
                  return ListTile(
                    leading: const Icon(Icons.history, color: Color.fromARGB(255, 112, 73, 180)),
                    title: Text(name),
                    subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(date))),
                    trailing: Text(action),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}