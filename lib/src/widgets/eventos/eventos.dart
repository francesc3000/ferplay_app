import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/widgets/eventos/evento_card.dart';

class Eventos extends StatelessWidget {
  final EventoBloc eventoBloc;

  Eventos(this.eventoBloc);

  @override
  Widget build(BuildContext context) {
    print('[Eventos Widget] build()');
    return StreamBuilder<List<Evento>>(
      stream: eventoBloc.outEventosList,
      builder: (BuildContext context, AsyncSnapshot<List<Evento>> snapshot) {
        var eventos = snapshot.data;
      return  _buildEventoList(eventos);
    },);
  }

  Widget _buildEventoList(List<Evento> eventos) {
    Widget eventoCards;
    if (eventos!=null && eventos.length > 0) {
      eventoCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EventoCard(eventos[index]),
        itemCount: eventos.length,
      );
    } else {
      eventoCards = Container();
    }
    return eventoCards;
  }
}
