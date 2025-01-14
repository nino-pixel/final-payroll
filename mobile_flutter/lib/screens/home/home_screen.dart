import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../attendance/attendance_screen.dart';
import '../leave/leave_screen.dart';
import '../payslip/payslip_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/payroll_countdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _employeeData;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final data = await _authService.getStoredEmployeeData();
    if (mounted) {
      setState(() {
        _employeeData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayrollEmp'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              accountName: Text(
                _employeeData != null
                    ? '${_employeeData!['first_name'] ?? ''} ${_employeeData!['last_name'] ?? ''}'
                    : 'Loading...',
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(
                _employeeData?['email'] ?? 'Loading...',
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _employeeData?['first_name']
                          ?.toString()
                          .substring(0, 1)
                          .toUpperCase() ??
                      'E',
                  style: TextStyle(
                    fontSize: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Payslips'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PayslipScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('Leave Management'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaveScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _employeeData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PayrollCountdown(),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, ${_employeeData!['first_name'] ?? 'Employee'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                              'ID', _employeeData!['employee_id'] ?? 'N/A'),
                          _buildInfoRow(
                            'Name',
                            '${_employeeData!['first_name'] ?? ''} ${_employeeData!['last_name'] ?? ''}',
                          ),
                          _buildInfoRow('Department',
                              _employeeData!['department'] ?? 'N/A'),
                          _buildInfoRow(
                              'Position', _employeeData!['position'] ?? 'N/A'),
                          _buildInfoRow(
                              'Email', _employeeData!['email'] ?? 'N/A'),
                          _buildInfoRow(
                              'Status', _employeeData!['status'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
