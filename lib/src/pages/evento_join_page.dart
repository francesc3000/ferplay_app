import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/widgets/ui_elements/adapative_progress_indicator.dart';
import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';

class EventoJoinPage extends StatefulWidget {
  final Evento evento;
  EventoJoinPage({@required this.evento});

  @override
  _EventoJoinPageState createState() => _EventoJoinPageState();
}

class _EventoJoinPageState extends State<EventoJoinPage> {
  int _currentIntValue;

  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);

    _eventoBloc.inJoinPartnerNumber.add(1);

    return Scaffold(
      body: StreamBuilder<int>(
        stream: _eventoBloc.outJoinPartner,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if(!snapshot.hasData)
            return AdaptiveProgressIndicator();

          _currentIntValue = snapshot.data;

          double _price = widget.evento.price * _currentIntValue;

          return ListView(
            children: <Widget>[
              Text('¿Te apuntas sólo o con alguien más?'),
              NumberPicker.integer(
                 initialValue: _currentIntValue,
                 minValue: 1,
                 maxValue: widget.evento.playersPerTeam,
                 step: 1,
                onChanged: ((value) {
                  _currentIntValue = value;
                  _eventoBloc.inJoinPartnerNumber.add(_currentIntValue);
                }),
              ),
              Text('En total tendrás que abonar cuando estés en el evento:'),
              Text(_price.toString()),
              RaisedButton(
                splashColor: Theme.of(context).primaryColor,
                child: Text('Apuntarme'),
                onPressed: () {
                  _eventoBloc.joinUser2Event(widget.evento.id);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
