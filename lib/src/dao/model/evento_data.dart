import 'package:ferplayapp/src/models/location_data.dart';
import 'package:ferplayapp/src/models/user.dart';
import 'package:flutter/material.dart';

class EventoData {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String imagePath;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final int playersPerTeam;
  final LocationData location;
  List<User> _joinList;

  EventoData(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      @required this.userEmail,
      @required this.userId,
      @required this.playersPerTeam,
      @required this.location,
      @required this.imagePath,
      this.isFavorite = false});

  void joinUser(User user) {
    _joinList.add(user);
  }

  List<User> get joinList {
    return List.from(_joinList);
  }
}
