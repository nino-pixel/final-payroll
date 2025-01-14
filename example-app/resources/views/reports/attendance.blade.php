<!-- filepath: /E:/payroll6/example-app/resources/views/reports/attendance.blade.php -->
<!DOCTYPE html>
<html>
<head>
    <title>Attendance Report</title>
    <style>
        @page {
            margin: 20mm;
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .header {
            text-align: center;
            padding: 20px 0; 
            background-color: #f4f4f4;
            border-bottom: 2px solid #ddd;
        }
        .header h2 {
            margin: 0;
            font-size: 24px;
            color: #4CAF50;
        }
        .header p {
            margin: 5px 0;
            font-size: 14px;
            color: #666;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            font-size: 12px;
            text-align: left;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .footer {
            text-align: right;
            font-size: 10px;
            color: #666;
            padding: 10px 0;
            border-top: 2px solid #ddd;
        }
        .logo {
            width: 100px;
            height: auto;
            margin-bottom: 10px;
        }
        .status-present {
            color: green;
            font-weight: bold;
        }
        .status-absent {
            color: red;
            font-weight: bold;
        }
        .status-late {
            color: orange;
            font-weight: bold;
        }
        .status-on-leave {
            color: blue;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="{{ public_path('images/payroll_logo.png') }}" alt="Company Logo" class="logo">
        <h2>Attendance Report</h2>
        @if($type === 'yearly')
            <p>Annual Report for {{ $year }}</p>
        @elseif($type === 'monthly')
            <p>For {{ date('F', mktime(0, 0, 0, $month, 1)) }} {{ $year }}</p>
        @else
            <p>From {{ date('M d, Y', strtotime($startDate)) }} to {{ date('M d, Y', strtotime($endDate)) }}</p>
        @endif
    </div>

    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Employee ID</th>
                <th>Name</th>
                <th>Department</th>
                <th>Time In</th>
                <th>Time Out</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            @forelse($attendances as $attendance)
                <tr>
                    <td>{{ \Carbon\Carbon::parse($attendance->date)->format('M d, Y') }}</td>
                    <td>{{ $attendance->employee->employee_id ?? 'N/A' }}</td>
                    <td>{{ $attendance->employee->first_name ?? '' }} {{ $attendance->employee->last_name ?? '' }}</td>
                    <td>{{ $attendance->employee->department->name ?? 'N/A' }}</td>
                    <td>{{ $attendance->time_in ? \Carbon\Carbon::parse($attendance->time_in)->format('h:i A') : '-' }}</td>
                    <td>{{ $attendance->time_out ? \Carbon\Carbon::parse($attendance->time_out)->format('h:i A') : '-' }}</td>
                    <td class="status-{{ strtolower($attendance->status) }}">
                        {{ ucfirst($attendance->status) }}
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center">No attendance records found</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        Generated on: {{ \Carbon\Carbon::parse($generatedAt)->format('M d, Y h:i A') }}
    </div>
</body>
</html>
