import 'package:ferplayapp/src/widgets/eventos/eventos.dart';
import 'package:flutter/material.dart';
import 'package:ferplayapp/src/blocs/bloc_provider.dart';
import 'package:ferplayapp/src/blocs/evento_bloc.dart';
import 'package:ferplayapp/src/widgets/ui_elements/adapative_progress_indicator.dart';

class EventosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EventoBloc _eventoBloc = BlocProvider.of<EventoBloc>(context);
    return StreamBuilder<bool>(
      stream: _eventoBloc.outLoading,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var _isLoading;
        snapshot.hasData ? _isLoading = snapshot.data : _isLoading = false;
        Widget content = Center(child: Text('No se han encontrado Eventos!'));

        if (_isLoading)
          content = Center(child: AdaptiveProgressIndicator());
        else
          content = Eventos(_eventoBloc);

        return RefreshIndicator(
          onRefresh: _eventoBloc.fetchEventos,
          child: content,
        );
      },
    );
  }
}
