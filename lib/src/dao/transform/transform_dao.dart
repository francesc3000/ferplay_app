import 'package:ferplayapp/src/dao/model/evento_data.dart';
import 'package:ferplayapp/src/models/evento.dart';

class TransformDao {

  static EventoData evento2EventoDao(Evento evento) {
    EventoData eventoData = EventoData(
          id: evento.id,
          userEmail: evento.userEmail,
          userId: evento.userId,
          title: evento.title,
          description: evento.description,
          image: evento.image,
          imagePath: evento.imagePath,
          price: evento.price,
          playersPerTeam: evento.playersPerTeam,
          location: evento.location );

          evento.joinList.forEach((user){
            eventoData.joinUser(user);
          });

    return eventoData;
  }
}