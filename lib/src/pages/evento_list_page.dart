import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/models/evento.dart';
import 'package:ferplayapp/src/pages/evento_edit_page.dart';

class EventoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    return StreamBuilder<List<Evento>>(
      stream: _eventoBloc.outEventosList,
      builder: (BuildContext context, AsyncSnapshot<List<Evento>> snapshot) {
        List<Evento> eventos;
        int eventosLength;
        snapshot.hasData ? eventos = snapshot.data : eventos = [];
        snapshot.hasData
            ? eventosLength = eventos.length
            : eventosLength = 0;

        return ListView.builder(
          itemCount: eventosLength,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(eventos[index].title),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  _eventoBloc.selectEvento(eventos[index].id);
                  _eventoBloc.deleteEvento();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Swiped start to end');
                } else {
                  print('Other swiping');
                }
              },
              background: Container(color: Colors.red),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(eventos[index].image),
                    ),
                    title: Text(eventos[index].title),
                    subtitle: Text('\$${eventos[index].price.toString()}'),
                    trailing: _buildEditButton(
                        context, eventos[index], _eventoBloc),
                  ),
                  Divider()
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditButton(
      BuildContext context, Evento evento, EventoBloc eventoBloc) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        eventoBloc.selectEvento(evento.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return EventoEditPage();
            },
          ),
        ).then((_) {
          eventoBloc.selectEvento(null);
        });
      },
    );
  }
}
