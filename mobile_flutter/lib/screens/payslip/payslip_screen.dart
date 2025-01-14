import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/payslip_service.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  final _payslipService = PayslipService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _payslips = [];

  @override
  void initState() {
    super.initState();
    _loadPayslips();
  }

  Future<void> _loadPayslips() async {
    try {
      final payslips = await _payslipService.getPayslips();
      if (mounted) {
        setState(() {
          _payslips = payslips;
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

  String _formatPeriod(Map<String, dynamic> payslip) {
    try {
      if (payslip['period_start'] != null) {
        return DateFormat('MMMM yyyy').format(
          DateTime.parse(payslip['period_start'].toString()),
        );
      }
      return 'No date';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildPayslipSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildPayslipDetails(Map<String, dynamic> payslip) {
    print('Building payslip details: $payslip');

    return Column(
      children: [
        _buildPayslipSection(
          'Earnings',
          [
            _buildPayslipRow('Base Salary', payslip['base_salary'] ?? 0),
            _buildPayslipRow(
                'Total Increases', payslip['total_increases'] ?? 0),
          ],
        ),
        if ((payslip['details'] as List?)?.isNotEmpty ?? false) ...[
          const Divider(height: 32),
          _buildPayslipSection(
            'Increases',
            [
              for (var detail in (payslip['details'] as List)
                  .where((d) => d['type'] == 'increase'))
                _buildPayslipRow(
                  detail['name'],
                  detail['amount'],
                  description: detail['description'],
                ),
            ],
          ),
          const Divider(height: 32),
          _buildPayslipSection(
            'Deductions',
            [
              for (var detail in (payslip['details'] as List)
                  .where((d) => d['type'] == 'deduction'))
                _buildPayslipRow(
                  detail['name'],
                  detail['amount'],
                  description: detail['description'],
                  isDeduction: true,
                ),
            ],
          ),
        ],
        const Divider(height: 32),
        _buildPayslipSection(
          'Net Pay',
          [
            _buildPayslipRow('Net Salary', payslip['net_salary'] ?? 0,
                isBold: true),
          ],
        ),
        if (payslip['attendance_summary'] != null) ...[
          const Divider(height: 32),
          _buildPayslipSection(
            'Attendance Summary',
            [
              if (payslip['attendance_summary'] is Map)
                for (var entry
                    in (payslip['attendance_summary'] as Map).entries)
                  _buildPayslipRow(
                    entry.key.toString(),
                    entry.value ?? 0,
                    showPeso: false,
                  ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPayslipRow(String label, dynamic value,
      {bool isBold = false,
      bool showPeso = true,
      String? description,
      bool isDeduction = false}) {
    final formattedValue = showPeso
        ? value is num
            ? value.toStringAsFixed(2)
            : value.toString()
        : value is num
            ? '${value.toInt()} days'
            : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    if (description != null)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${isDeduction ? "-" : ""}${showPeso ? "₱" : ""}$formattedValue',
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isDeduction ? Colors.red : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslips'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPayslips,
              child: _payslips.isEmpty
                  ? const Center(child: Text('No payslips found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _payslips.length,
                      itemBuilder: (context, index) {
                        final payslip = _payslips[index];
                        return Card(
                          child: ListTile(
                            title: Text(_formatPeriod(payslip)),
                            subtitle: Text(
                              'Net Pay: ₱${(payslip['net_salary'] ?? 0.0).toStringAsFixed(2)}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showPayslipDetails(payslip),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showPayslipDetails(Map<String, dynamic> payslip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          child: Column(
            children: [
              AppBar(
                title: Text('Payslip - ${_formatPeriod(payslip)}'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPayslipDetails(payslip),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
