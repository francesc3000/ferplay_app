import 'dart:async';
//import 'dart:collection';
import 'dart:io';

import 'package:ferplayapp/src/dao/factory_dao.dart';
import 'package:ferplayapp/src/dao/transform/transform_dao.dart';
import 'package:ferplayapp/src/models/location_data.dart';
import 'package:ferplayapp/src/models/user.dart';
import 'package:ferplayapp/src/shared/Injector.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:rxdart/rxdart.dart';

class EventoBloc extends BlocBase {
  String _selEventoId;
  List<Evento> _eventos = [];
  bool _showFavorites = false;
  int _joinPartnerNumber;

  // ##########  STREAMS  ##############
  ///
  /// Interface that informs is loading
  ///
  BehaviorSubject<bool> _isLoadingController =
      BehaviorSubject<bool>(seedValue: false);
  Sink<bool> get _inLoading => _isLoadingController.sink;
  Stream<bool> get outLoading => _isLoadingController.stream;

  ///
  /// We are going to need the list of movies to be displayed
  ///
  // PublishSubject<List<Evento>> _eventosController = PublishSubject<List<Evento>>();
  BehaviorSubject<List<Evento>> _eventosController =
      BehaviorSubject<List<Evento>>();
  Sink<List<Evento>> get _inEventosList => _eventosController.sink;
  Stream<List<Evento>> get outEventosList => _eventosController.stream;

  ///
  /// Interface that toggle between favorite and unfavorite
  ///
  BehaviorSubject<bool> _toggleEventoFavoriteStatusController =
      BehaviorSubject<bool>();
  Sink<bool> get _inToggleEventoFavoriteStatus =>
      _toggleEventoFavoriteStatusController.sink;
  Stream<bool> get outToggleEventoFavoriteStatus =>
      _toggleEventoFavoriteStatusController.stream;

  ///
  /// Interface that toggle between favorite and unfavorite
  ///
  BehaviorSubject<bool> _toggleeDisplayModeController = BehaviorSubject<bool>();
  Sink<bool> get _inToggleDisplayMode => _toggleeDisplayModeController.sink;
  Stream<bool> get outToggleDisplayMode => _toggleeDisplayModeController.stream;

  ///
  /// Interface that spin join Partner
  ///
  BehaviorSubject<int> _joinPartnerController = BehaviorSubject<int>();
  Sink<int> get _inJoinPartner => _joinPartnerController.sink;
  Stream<int> get outJoinPartner => _joinPartnerController.stream;

  ///
  /// Interface that save join Partner number
  ///
  BehaviorSubject<int> _joinPartnerNumberController = BehaviorSubject<int>();
  Sink<int> get inJoinPartnerNumber => _joinPartnerNumberController.sink;
  //Stream<int> get _outJoinPartnerNumber => _joinPartnerNumberController.stream;

  ///
  /// Constructor
  ///
  EventoBloc() {
    _toggleEventoFavoriteStatusController.listen(_toggleEventoFavoriteStatus);
    _joinPartnerNumberController.listen(_joinPartnerNumberStatus);
  }

  @override
  void dispose() {
    // closeControllers();
  }

  void closeControllers() {
    _isLoadingController.close();
    _eventosController.close();
    _toggleEventoFavoriteStatusController.close();
    _toggleeDisplayModeController.close();
    _joinPartnerController.close();
    _joinPartnerNumberController.close();
  }

  Future<bool> addEvento(String title, String description, File image,
      double price, LocationData locData) async {
    var authenticatedUser = Injector.currentUser;
    if (authenticatedUser == null) return false;

    try {
      _inLoading.add(true);
      var responseData = await FactoryDao.eventoDao.addEvento(
          title: title,
          description: description,
          image: image,
          price: price,
          locData: locData);

      if (responseData = null) {
        _inLoading.add(false);
        return false;
      }

      final Evento newEvento = Evento(
          id: responseData['name'],
          title: title,
          description: description,
          image: responseData['imageUrl'],
          imagePath: responseData['imagePath'],
          price: price,
          location: locData,
          userEmail: authenticatedUser.email,
          userId: authenticatedUser.id,
          playersPerTeam: int.parse(responseData['playersPerTeam']));
      _eventos.add(newEvento);
      _inLoading.add(false);
      return true;
    } catch (error) {
      _inLoading.add(false);
      return false;
    }
  }

  Future<bool> updateEvento(String title, String description, File image,
      double price, LocationData locData) async {
    final authenticatedUser = Injector.currentUser;
    if (authenticatedUser == null) return false;

    try {
      _inLoading.add(true);
      var responseData = await FactoryDao.eventoDao.updateEvento(TransformDao.evento2EventoDao(selectedEvento), image);

      if (responseData == null) {
        _inLoading.add(false);
        return false;
      }

      final Evento updatedEvento = Evento(
          id: selectedEvento.id,
          title: title,
          description: description,
          image: responseData['imageUrl'],
          imagePath: responseData['imagePath'],
          price: price,
          location: locData,
          userEmail: selectedEvento.userEmail,
          userId: selectedEvento.userId,
          playersPerTeam: selectedEvento.playersPerTeam);
      _eventos[selectedEventoIndex] = updatedEvento;
      _inEventosList.add(_eventos);
      _inLoading.add(false);
      return true;
    } catch (error) {
      _inLoading.add(false);
      return false;
    }
  }

  Future<bool> deleteEvento() async {
    final authenticatedUser = Injector.currentUser;
    if (authenticatedUser == null) return false;

    try {
      final deletedEventoId = selectedEvento.id;
      _eventos.removeAt(selectedEventoIndex);
      _selEventoId = null;
      //TODO: No se muy bien a quien tengo que notificar en este punto
      //notifyListeners();

      var responseData = await FactoryDao.eventoDao
          .deleteEvento(deletedEventoId: deletedEventoId);

      _inLoading.add(false);
      if (responseData == null) return false;

      return true;
    } catch (error) {
      _inLoading.add(false);
      return false;
    }
  }

  Future<Null> fetchEventos(
      {onlyForUser = false, clearExisting = false}) async {
    final User authenticatedUser = Injector.currentUser;

    if (authenticatedUser == null) return;

    _inLoading.add(true);
    if (clearExisting) {
      _eventos = [];
    }

    _inEventosList.add(_eventos);
    try {
      //   var eventoListData = await FactoryDao.eventoDao.fetchEventos();

      //   if (eventoListData == null) {
      //     _inLoading.add(false);
      //     return;
      //   }

      Map<String, dynamic> eventoListData = {
        '123': {
          'title': 'Dummy',
          'description': 'Dummy description',
          'imageUrl':
              'https://www.las2orillas.co/wp-content/uploads/2014/08/Futbol-13.jpg',
          'imagePath': '',
          'price': 22.0,
          'loc_address': 'Calle del pepino 123',
          'loc_lat': 41.350771,
          'loc_lng': 2.069653,
          'userEmail': 'francesc3000@hotmail.com',
          'userId': '123',
          'playersPerTeam': '2'
        }
      };

      final List<Evento> fetchedEventoList = [];

      eventoListData.forEach((String eventoId, dynamic eventoData) {
        final Evento evento = Evento(
            id: eventoId,
            title: eventoData['title'],
            description: eventoData['description'],
            image: eventoData['imageUrl'],
            imagePath: eventoData['imagePath'],
            price: eventoData['price'],
            location: LocationData(
                address: eventoData['loc_address'],
                latitude: eventoData['loc_lat'],
                longitude: eventoData['loc_lng']),
            userEmail: eventoData['userEmail'],
            userId: eventoData['userId'],
            playersPerTeam: int.parse(eventoData['playersPerTeam']),
            isFavorite: eventoData['wishlistUsers'] == null
                ? false
                : (eventoData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(authenticatedUser.id));
        fetchedEventoList.add(evento);
      });
      _eventos = onlyForUser
          ? fetchedEventoList.where((Evento evento) {
              return evento.userId == authenticatedUser.id;
            }).toList()
          : fetchedEventoList;

      //_inEventosList.add(UnmodifiableListView(_eventos));
      _inEventosList.add(_eventos);
      _inLoading.add(false);
      //_selEventoId = null;
      return;
    } catch (error){
      print(error);
      _inLoading.add(false);
      return;
    }
  }

  int get selectedEventoIndex {
    return _eventos.indexWhere((Evento evento) {
      return evento.id == _selEventoId;
    });
  }

  String get selectedEventoId {
    return _selEventoId;
  }

  Evento get selectedEvento {
    if (selectedEventoId == null || _eventos == null) {
      return null;
    }

    return _eventos.firstWhere((Evento evento) {
      return evento.id == _selEventoId;
    });
  }

  void selectEvento(String eventoId) {
    _selEventoId = eventoId;
    if (eventoId != null) {
      //_inEventosList.add(_eventos);
    }
  }

  void _toggleEventoFavoriteStatus(bool isFavorite) async {
    final User _authenticatedUser = Injector.currentUser;

    if (_authenticatedUser == null) return;

    final bool newFavoriteStatus = isFavorite;

    // final Evento updatedEvento = Evento(
    //     id: selectedEvento.id,
    //     title: selectedEvento.title,
    //     description: selectedEvento.description,
    //     price: selectedEvento.price,
    //     image: selectedEvento.image,
    //     imagePath: selectedEvento.imagePath,
    //     location: selectedEvento.location,
    //     userEmail: selectedEvento.userEmail,
    //     userId: selectedEvento.userId,
    //     isFavorite: newFavoriteStatus);
    // _eventos[selectedEventoIndex] = updatedEvento;
    // _inEventosList.add(_eventos);

    var responseData;
    if (newFavoriteStatus)
      responseData =
          await FactoryDao.eventoDao.addFavoriteEvento(selectedEvento.id);
    else
      responseData =
          await FactoryDao.eventoDao.deleteFavoriteEvento(selectedEvento.id);

    if (responseData) {
      final Evento updatedEvento = Evento(
          id: selectedEvento.id,
          title: selectedEvento.title,
          description: selectedEvento.description,
          price: selectedEvento.price,
          image: selectedEvento.image,
          imagePath: selectedEvento.imagePath,
          location: selectedEvento.location,
          userEmail: selectedEvento.userEmail,
          userId: selectedEvento.userId,
          playersPerTeam: selectedEvento.playersPerTeam,
          isFavorite: newFavoriteStatus);
      _eventos[selectedEventoIndex] = updatedEvento;
      _inEventosList.add(_eventos);
    }
    //_selEventoId = null;
  }

  void toggleEventoFavoriteStatus() {
    bool isFavorite = !selectedEvento.isFavorite;
    _inToggleEventoFavoriteStatus.add(isFavorite);
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    _inToggleDisplayMode.add(_showFavorites);
  }

  void joinUser2Event(String eventId) {
    var authenticatedUser = Injector.currentUser;

    Evento evento = _eventos.firstWhere((evento){
      if(evento.id==eventId)
        return true;
    });

    if(evento!=null){
      evento.joinUser(authenticatedUser);
      
      FactoryDao.eventoDao.updateEvento(TransformDao.evento2EventoDao(evento), null);
    }
  }

  void _joinPartnerNumberStatus(int joinPartnerNumber) async{
    _joinPartnerNumber = joinPartnerNumber;
    _inJoinPartner.add(_joinPartnerNumber);
  }
}
