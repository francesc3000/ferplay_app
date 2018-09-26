import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:ferplayapp/src/dao/model/evento_data.dart';
import 'package:flutter/material.dart';
import 'package:ferplayapp/src/models/location_data.dart';
import 'package:ferplayapp/src/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:ferplayapp/src/repository/firebase_http_repository.dart';
import 'package:ferplayapp/src/shared/Injector.dart';

abstract class EventoDao{
  Future<Map<String, dynamic>> _uploadImage(File image, {String imagePath});
  Future<Map<String, dynamic>> addEvento({@required String title, @required String description, @required File image, 
    @required double price, @required LocationData locData});
  Future<Map<String, dynamic>> updateEvento(EventoData eventoData, File image);
  Future<Map<String, dynamic>> deleteEvento({@required String deletedEventoId});
  Future<Map<String, dynamic>> fetchEventos();
  Future<bool> addFavoriteEvento(String eventoId);
  Future<bool> deleteFavoriteEvento(String eventoId);
}

class EventoDaoFirebaseImpl implements EventoDao{
  FirebaseHttpRepository firebaseRepository;
  User _authenticatedUser;

  EventoDaoFirebaseImpl(){
    firebaseRepository = FirebaseHttpRepository();
    _authenticatedUser = Injector.currentUser;
  }

  @override
  Future<Map<String, dynamic>> _uploadImage(File image, {String imagePath}) async{
    
    try {
      final response = await firebaseRepository.uploadImage(_authenticatedUser.token, image, imagePath: imagePath);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;

    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> addEvento({String title, String description, File image, double price, LocationData locData}) async {

    final uploadData = await _uploadImage(image);

    if (uploadData == null) {
      print('Upload failed!');
      return null;
    }

    final Map<String, dynamic> eventoDataList = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address
    };
    
    try {
      final http.Response response = await firebaseRepository.addEvento(_authenticatedUser.token, eventoDataList);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      responseData.addAll(uploadData);

      return responseData;
    } catch (error) {
      print('Something went wrong adding new Evento');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> updateEvento(EventoData eventoData, File image) async{

    String localImageUrl;
    String localImagePath;
 
    if (eventoData.image != null && image != null){
      final uploadData = await _uploadImage(image);

      if (uploadData == null) {
        print('Upload failed!');
        return null;
      }

      localImageUrl = uploadData['imageUrl'];
      localImagePath = uploadData['imagePath'];
    }else{
      localImageUrl = eventoData.image;
      localImagePath = eventoData.imagePath;
    }
    
    final Map<String, dynamic> updateData = {
      'title': eventoData.title,
      'description': eventoData.description,
      'imageUrl': localImageUrl,
      'imagePath': localImagePath,
      'price': eventoData.price,
      'loc_lat': eventoData.location.latitude,
      'loc_lng': eventoData.location.longitude,
      'loc_address': eventoData.location.address,
      'userEmail': eventoData.userEmail,
      'userId': eventoData.userId
    };
    try {
      final http.Response response = await firebaseRepository.updateEvento(_authenticatedUser.token, eventoData.id, updateData);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong updating evento');
        print(json.decode(response.body));
        return null;
      }
    
      Map<String, dynamic> responseData = json.decode(response.body);

      return responseData;
    } catch (error) {
      print('Something went wrong updating Evento');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteEvento({String deletedEventoId}) async{

    try {
      final http.Response response = await firebaseRepository.deleteEvento(_authenticatedUser.token, deletedEventoId);

      Map<String, dynamic> responseData = json.decode(response.body);

      return responseData;

    }catch (error) {
      print('Something went wrong deleting Evento');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchEventos() async{
    try {
      var response = await firebaseRepository.fetchEventos(_authenticatedUser.token);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong fetching eventos');
        print(json.decode(response.body));
        return null;
      }

      final Map<String, dynamic> eventoListData = json.decode(response.body);

      return eventoListData;
  
    } catch (error) {
      return null;
    }
  }

  @override
  Future<bool> addFavoriteEvento(String eventoId) async{
    http.Response response = await firebaseRepository.addFavoriteEvento(eventoId, _authenticatedUser.id , _authenticatedUser.token);
    
    if (response.statusCode != 200 && response.statusCode != 201) 
      return false;

    return true;
  }

  @override
  Future<bool> deleteFavoriteEvento(String eventoId) async{
    http.Response response = await firebaseRepository.deleteFavoriteEvento(eventoId, _authenticatedUser.id ,_authenticatedUser.token);

    if (response.statusCode != 200 && response.statusCode != 201)
      return false;

    return true;
  }
}