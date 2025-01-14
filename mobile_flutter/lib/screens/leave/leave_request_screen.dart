import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/leave_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leaveService = LeaveService();
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;
  final _reasonController = TextEditingController();

  List<Map<String, dynamic>> _leaveBalances = [];

  @override
  void initState() {
    super.initState();
    _loadLeaveBalances();
  }

  Future<void> _loadLeaveBalances() async {
    setState(() => _isLoading = true);
    try {
      final balances = await _leaveService.getLeaveBalances();
      setState(() => _leaveBalances = balances);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
          // Reset end date if it's before new start date
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

      print('Submitting leave request: $requestData');

      await _leaveService.submitLeaveRequest(requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted successfully')),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Leave'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave balances section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Leave Balances',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._leaveBalances.map((balance) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(balance['leave_type']['name']),
                                      Text(
                                          '${balance['remaining_days']} days remaining'),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Leave type dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLeaveType,
                      decoration: const InputDecoration(
                        labelText: 'Leave Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _leaveBalances
                          .map((balance) => DropdownMenuItem(
                                value: balance['leave_type']['id'].toString(),
                                child: Text(balance['leave_type']['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedLeaveType = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a leave type';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date selection
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () => _selectDate(true),
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
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () => _selectDate(false),
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

                    // Reason text field
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

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_isLoading ? 'Submitting...' : 'Submit'),
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
