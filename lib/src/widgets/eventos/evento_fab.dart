import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/models/evento.dart';

import 'package:url_launcher/url_launcher.dart';

class EventoFAB extends StatefulWidget {
  final Evento evento;

  EventoFAB(this.evento);

  @override
  State<StatefulWidget> createState() {
    return _EventoFABState();
  }
}

class _EventoFABState extends State<EventoFAB> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'contact',
              mini: true,
              onPressed: () async {
                final url = 'mailto:${widget.evento.userEmail}';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch!';
                }
              },
              child: Icon(
                Icons.mail,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              heroTag: 'favorite',
              mini: true,
              onPressed: () {
                _eventoBloc.toggleEventoFavoriteStatus();
              },
              child: StreamBuilder<bool>(
                  stream: _eventoBloc.outToggleEventoFavoriteStatus,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                         bool isFavorite;
                    if (!snapshot.hasData) 
                      isFavorite = _eventoBloc.selectedEvento.isFavorite;
                    else
                      isFavorite = snapshot.data;
                      
                    return Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    );
                  }),
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: 'options',
          onPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                child: Icon(
                    _controller.isDismissed ? Icons.more_vert : Icons.close),
              );
            },
          ),
        ),
      ],
    );
  }
}
