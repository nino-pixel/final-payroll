import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/leave_service.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leaveService = LeaveService();
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;
  final _reasonController = TextEditingController();

  List<Map<String, dynamic>> _leaveBalances = [];
  List<Map<String, dynamic>> _leaveHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final balances = await _leaveService.getLeaveBalances();
      final history = await _leaveService.getLeaveHistory();
      if (mounted) {
        setState(() {
          _leaveBalances = balances;
          _leaveHistory = history;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final days = _endDate!.difference(_startDate!).inDays + 1;

      final requestData = {
        'employee_id': 'EMP101',
        'leave_type_id': int.parse(_selectedLeaveType!),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'total_days': days,
        'reason': _reasonController.text,
      };

      await _leaveService.submitLeaveRequest(requestData);

      // Refresh data after successful submission
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted successfully')),
        );
        // Clear form
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedLeaveType = null;
          _reasonController.clear();
        });
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
        title: const Text('Leave Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave Balances Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Balances',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ..._leaveBalances.map((balance) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(balance['leave_type']['name']),
                                      Text(
                                          '${balance['remaining_days']}/${balance['total_days']} days'),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Leave Request Form
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Leave Request',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedLeaveType,
                                decoration: const InputDecoration(
                                  labelText: 'Leave Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: _leaveBalances
                                    .map((balance) => DropdownMenuItem(
                                          value: balance['leave_type']['id']
                                              .toString(),
                                          child: Text(
                                              balance['leave_type']['name']),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedLeaveType = value);
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a leave type';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      onTap: () => _selectDate(true),
                                      decoration: const InputDecoration(
                                        labelText: 'Start Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (_startDate == null) {
                                          return 'Please select start date';
                                        }
                                        return null;
                                      },
                                      controller: TextEditingController(
                                        text: _startDate == null
                                            ? ''
                                            : DateFormat('MMM dd, yyyy')
                                                .format(_startDate!),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      onTap: () => _selectDate(false),
                                      decoration: const InputDecoration(
                                        labelText: 'End Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (_endDate == null) {
                                          return 'Please select end date';
                                        }
                                        return null;
                                      },
                                      controller: TextEditingController(
                                        text: _endDate == null
                                            ? ''
                                            : DateFormat('MMM dd, yyyy')
                                                .format(_endDate!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _reasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Reason',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a reason';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitRequest,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                      _isLoading ? 'Submitting...' : 'Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Leave History Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Leave History',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _loadData,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_leaveHistory.isEmpty)
                              const Center(
                                child: Text('No leave history found'),
                              )
                            else
                              ...List.generate(
                                _leaveHistory.length > 3
                                    ? 3
                                    : _leaveHistory.length,
                                (index) {
                                  final leave = _leaveHistory[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ListTile(
                                      title: Text(leave['leave_type']),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['start_date']))} - '
                                            '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['end_date']))}',
                                          ),
                                          Text('Reason: ${leave['reason']}'),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(leave['status']),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                            if (_leaveHistory.length > 3) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) =>
                                          DraggableScrollableSheet(
                                        initialChildSize: 0.9,
                                        maxChildSize: 0.9,
                                        minChildSize: 0.5,
                                        builder: (context, scrollController) =>
                                            Container(
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              AppBar(
                                                title:
                                                    const Text('Leave History'),
                                                leading: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                  controller: scrollController,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  itemCount:
                                                      _leaveHistory.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final leave =
                                                        _leaveHistory[index];
                                                    return Card(
                                                      child: ListTile(
                                                        title: Text(leave[
                                                            'leave_type']),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['start_date']))} - '
                                                              '${DateFormat('MMM dd, yyyy').format(DateTime.parse(leave['end_date']))}',
                                                            ),
                                                            Text(
                                                                'Reason: ${leave['reason']}'),
                                                            Text(
                                                              'Days: ${leave['total_days']}',
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _getStatusColor(
                                                                leave[
                                                                    'status']),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Text(
                                                            leave['status']
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View All History'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
