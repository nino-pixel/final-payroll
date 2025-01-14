import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/leave_service.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  final _leaveService = LeaveService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaveHistory = [];

  @override
  void initState() {
    super.initState();
    _loadLeaveHistory();
  }

  Future<void> _loadLeaveHistory() async {
    try {
      final history = await _leaveService.getLeaveHistory();
      if (mounted) {
        setState(() {
          _leaveHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaveHistory,
              child: _leaveHistory.isEmpty
                  ? const Center(
                      child: Text('No leave history found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _leaveHistory.length,
                      itemBuilder: (context, index) {
                        final leave = _leaveHistory[index];
                        return Card(
                          child: ListTile(
                            title: Text(leave['leave_type']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['start_date']))} - '
                                  '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['end_date']))}',
                                ),
                                Text('Reason: ${leave['reason']}'),
                                Text(
                                  'Days: ${leave['total_days']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(leave['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                leave['status'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
