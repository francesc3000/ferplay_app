import 'package:ferplayapp/src/pages/evento_join_page.dart';
import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/evento.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;

  EventoCard(this.evento);

  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    return Card(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Hero(
              tag: evento.id,
              child: FadeInImage(
                image: NetworkImage(evento.image),
                height: 300.0,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/wait.jpg'),
              ),
            ),
            onTap: () {
              _eventoBloc.selectEvento(evento.id);
              Navigator.pushNamed<bool>(context, '/evento/' + evento.id)
                  .then((_) => _eventoBloc.selectEvento(null));
            },
          ),
          _buildTitlePriceRow(),
          SizedBox(
            height: 10.0,
          ),
          AddressTag(evento.location.address),
          _buildActionButtons(context)
        ],
      ),
    );
  }

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: TitleDefault(evento.title),
          ),
          Flexible(
            child: SizedBox(
              width: 8.0,
            ),
          ),
          Flexible(
            child: PriceTag(evento.price.toString()),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ButtonBar(alignment: MainAxisAlignment.center, children: <Widget>[
      // IconButton(
      //   icon: Icon(evento.isFavorite ? Icons.favorite : Icons.favorite_border),
      //   color: Colors.red,
      //   onPressed: () {
      //     _eventoBloc.selectEvento(evento.id);
      //     _eventoBloc.toggleEventoFavoriteStatus();
      //   },
      // ),
      RaisedButton(
        splashColor: Theme.of(context).primaryColor,
        child: Text('Apuntarme'),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
            return EventoJoinPage(evento: this.evento);
            }),);
        },
      )
    ]);
  }
}
