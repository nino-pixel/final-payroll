import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _attendanceService = AttendanceService();
  bool _isLoading = false;
  Map<String, dynamic>? _currentStatus;
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final status = await _attendanceService.getCurrentStatus();
      final history = await _attendanceService.getAttendanceHistory();
      if (mounted) {
        setState(() {
          _currentStatus = status;
          _attendanceHistory = history;
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

  Future<void> _markAttendance(String type) async {
    setState(() => _isLoading = true);
    try {
      await _attendanceService.markAttendance(type);
      await _loadData(); // Refresh data after marking attendance
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type marked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentStatusCard(),
                      const SizedBox(height: 24),
                      _buildHistoryCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn('Time In', _currentStatus?['time_in']),
                _buildTimeColumn('Time Out', _currentStatus?['time_out']),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceButton(
                  'Time In',
                  _currentStatus?['time_in'] != null,
                  () => _markAttendance('time_in'),
                  Theme.of(context).primaryColor,
                ),
                _buildAttendanceButton(
                  'Time Out',
                  _currentStatus?['time_in'] == null ||
                      _currentStatus?['time_out'] != null,
                  () => _markAttendance('time_out'),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String? time) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(
          time ?? '--:--',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceButton(
    String label,
    bool isDisabled,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  Widget _buildHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHistoryHeader(),
            const SizedBox(height: 16),
            _buildHistoryList(),
            if (_attendanceHistory.length > 5) _buildViewAllButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_attendanceHistory.isEmpty) {
      return const Center(child: Text('No attendance history found'));
    }

    return Column(
      children: List.generate(
        _attendanceHistory.length > 5 ? 5 : _attendanceHistory.length,
        (index) => _buildHistoryItem(_attendanceHistory[index]),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> attendance) {
    return Card(
      child: ListTile(
        title: Text(
          DateFormat('MMM dd, yyyy').format(
            DateTime.parse(attendance['date']),
          ),
        ),
        subtitle: Text(
          'In: ${attendance['time_in'] ?? '--:--'} | Out: ${attendance['time_out'] ?? '--:--'}',
        ),
        trailing: _buildStatusBadge(attendance['status']),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: TextButton(
        onPressed: _showFullHistory,
        child: const Text('View All History'),
      ),
    );
  }

  void _showFullHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _buildFullHistorySheet(
          scrollController,
        ),
      ),
    );
  }

  Widget _buildFullHistorySheet(ScrollController scrollController) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBar(
            title: const Text('Attendance History'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _attendanceHistory.length,
              itemBuilder: (context, index) =>
                  _buildHistoryItem(_attendanceHistory[index]),
            ),
          ),
        ],
      ),
    );
  }
}
