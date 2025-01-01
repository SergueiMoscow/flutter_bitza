import 'package:flutter/material.dart';
import 'package:flutter_s3_app/models/room_summary.dart';

class RoomTile extends StatelessWidget {
  final RoomSummary room;
  final bool isSelected;
  const RoomTile({super.key, required this.room, required this.isSelected});

  Color _getColor(String debtStatus) {
    switch (debtStatus) {
      case 'room_little_debt':
        return Colors.yellow;
      case 'room_no_debt':
        return Colors.green;
      case 'room_big_debt':
        return Colors.red;
      case 'current':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.cyan : _getColor(room.debtStatus),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      child: Center(child: Text(
        room.id,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: isSelected? 28 : 14,

        ),
      ),),
    );
  }
}
