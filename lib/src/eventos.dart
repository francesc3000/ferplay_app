import 'package:flutter/material.dart';

class Eventos extends StatelessWidget {
  final List<Map<String, dynamic>> eventos;

  Eventos(this.eventos) {
    print('[Eventos Widget] Constructor');
  }

  @override
  Widget build(BuildContext context) {
    print('[Eventos Widget] build()');
    return _buildEventoList();
  }

  Widget _buildEventoItem(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(eventos[index]['image']),
          Text(eventos[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Details'),
                onPressed: () => Navigator
                        .pushNamed<bool>(
                            context, '/evento/' + index.toString())
                ,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEventoList() {
    Widget eventoCards;
    if (eventos.length > 0) {
      eventoCards = ListView.builder(
        itemBuilder: _buildEventoItem,
        itemCount: eventos.length,
      );
    } else {
      eventoCards = Container();
    }
    return eventoCards;
  }
}
