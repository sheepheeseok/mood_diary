import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef OnDateSelected = void Function(DateTime selectedDate);

class CalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final OnDateSelected onDateSelected;

  const CalendarPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _showCalendarDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF7A70DD),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF7A70DD)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final displayDate = DateFormat('MMMM yyyy').format(selectedDate);

    return GestureDetector(
      onTap: _showCalendarDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF7F5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF7A70DD)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayDate,
              style: TextStyle(
                color: Color(0xFF7A70DD),
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                fontFamily: 'Kufam',
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.calendar_today, color: Color(0xFF7A70DD)),
          ],
        ),
      ),
    );
  }
}
