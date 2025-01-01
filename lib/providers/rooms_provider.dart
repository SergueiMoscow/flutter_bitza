import 'package:flutter/cupertino.dart';
import 'package:flutter_s3_app/api/rent_api.dart';
import 'package:flutter_s3_app/models/room_summary.dart';

class RoomsProvider with ChangeNotifier{
  List<RoomSummary> _roomSummary = [];
  bool _isLoading = false;

  List<RoomSummary> get rooms => _roomSummary;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _roomSummary = await RentApiService().fetchRoomSummary();
    } catch (e) {
      _roomSummary = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}