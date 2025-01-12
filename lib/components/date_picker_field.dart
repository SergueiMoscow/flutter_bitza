import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        TextField(
          controller: TextEditingController(
            text: selectedDate.toLocal().toString().split(' ')[0],
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != selectedDate) {
              onDateChanged(picked);
            }
          },
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Выберите дату',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }
}
