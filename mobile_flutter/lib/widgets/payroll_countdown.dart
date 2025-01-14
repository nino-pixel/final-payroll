import 'package:flutter/material.dart';
import 'dart:async';

class PayrollCountdown extends StatefulWidget {
  const PayrollCountdown({super.key});

  @override
  State<PayrollCountdown> createState() => _PayrollCountdownState();
}

class _PayrollCountdownState extends State<PayrollCountdown> {
  late Timer _timer;
  Map<String, int> _countdown = {'days': 0, 'hours': 0, 'minutes': 0};
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer =
        Timer.periodic(const Duration(minutes: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final nextPayday = _getNextPayday();
    final diff = nextPayday.difference(now);

    setState(() {
      _countdown = {
        'days': diff.inDays,
        'hours': diff.inHours % 24,
        'minutes': diff.inMinutes % 60,
      };

      // Calculate progress (assuming 15 days between payrolls)
      final totalDays = 15;
      _progress = (totalDays - diff.inDays) / totalDays;
    });
  }

  DateTime _getNextPayday() {
    final now = DateTime.now();
    final nextPayday = DateTime(now.year, now.month, 15);

    if (now.day >= 15) {
      return DateTime(now.year, now.month + 1, 15);
    }
    return nextPayday;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next Payroll',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeBlock('Days', _countdown['days']!),
                const Text(':',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeBlock('Hours', _countdown['hours']!),
                const Text(':',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildTimeBlock('Minutes', _countdown['minutes']!),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
