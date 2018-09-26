// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/widgets/eventos/evento_fab.dart';
import 'package:ferplayapp/src/widgets/ui_elements/title_default.dart';

import 'package:map_view/map_view.dart';

class EventoPage extends StatelessWidget {
  final Evento evento;

  EventoPage(this.evento);

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', evento.location.latitude,
          evento.location.longitude)
    ];
    final cameraPosition = CameraPosition(
        Location(evento.location.latitude, evento.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(
        MapOptions(
            initialCameraPosition: cameraPosition,
            mapViewType: MapViewType.normal,
            title: 'Localización del evento'),
        toolbarActions: [
          ToolbarAction('Cerrar', 1),
        ]);
    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  Widget _buildAddressPriceRow(String address, double price) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _showMap,
          child: Text(
            address,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        ),
        // Container(
        //   margin: EdgeInsets.symmetric(horizontal: 5.0),
        //   child: Text(
        //     '|',
        //     style: TextStyle(color: Colors.grey),
        //   ),
        // ),
        Text(
          price.toString() + '€',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
    // WillPopScope(
    //   onWillPop: () {
    //     print('Back button pressed!');
    //     Navigator.pop(context, true);
    //     return Future.value(false);
    //   },
      // child: 
      Scaffold(
        // appBar: AppBar(b
        //   title: Text(evento.title),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(evento.title),
                background: Hero(
                  tag: evento.id,
                  child: FadeInImage(
                    image: NetworkImage(evento.image),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/wait.jpg'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: TitleDefault(evento.title),
                  ),
                  _buildAddressPriceRow(
                      evento.location.address, evento.price),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      evento.description,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: EventoFAB(evento),
      // ),
    );
  }
}
