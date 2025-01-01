import 'package:flutter/material.dart';
import 'package:flutter_s3_app/providers/contract_payments_provider.dart';
import 'package:flutter_s3_app/providers/rooms_provider.dart';
import 'package:flutter_s3_app/components/common_app_bar.dart';
import 'package:flutter_s3_app/components/contract_payments_component.dart';
import 'package:provider/provider.dart';
import 'package:flutter_s3_app/models/room_summary.dart';

import '../widgets/room_tile.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  RoomSummary? _selectedRoom;

  @override
  void initState() {
    super.initState();
  }

  void _selectRoom(RoomSummary roomSummary) {
    setState(() {
      _selectedRoom = roomSummary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomsProvider()..fetchRooms(),
      builder: (context, _) {
        final roomsProvider = Provider.of<RoomsProvider>(context);
        return Scaffold(
          appBar: CommonAppBar(),
          body: Row(
            children: [
              Expanded(
                flex: 1,
                child: roomsProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: roomsProvider.rooms.length,
                        itemBuilder: (ctx, index) {
                          RoomSummary room = roomsProvider.rooms[index];
                          bool isSelected = _selectedRoom?.id == room.id;
                          return GestureDetector(
                            onTap: () => _selectRoom(room),
                            child: RoomTile(room: room, isSelected: isSelected),
                          );
                        },
                      ),
              ),
              VerticalDivider(width: 1),
              Expanded(
                  flex: 2,
                  child: _selectedRoom == null
                      ? Center(child: Text('Выберите комнату'))
                      : ChangeNotifierProvider(
                          key: ValueKey(_selectedRoom!.id),
                          create: (_) => ContractPaymentsProvider(
                              roomId: _selectedRoom!.id)
                            ..fetchRoomPayments(),
                          child:
                              ContractPaymentsComponent(room: _selectedRoom!),
                        ))
            ],
          ),
        );
      },
    );
  }
}
