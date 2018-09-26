import 'package:ferplayapp/src/dao/evento_dao.dart';
import 'package:ferplayapp/src/dao/user_dao.dart';

class FactoryDao{
  static const String FIREBASE = "Firebase";
  static String _defaultDB = FIREBASE;
  static UserDao _userDao;
  static EventoDao _eventoDao;

  static UserDao get userDao{
    switch (_defaultDB) {
      case FIREBASE:
        if(_userDao==null)
          _userDao = UserDaoFirebaseImpl();

        return _userDao;
        break;
      default:
        return null;
    }
  }

  static EventoDao get eventoDao{
    switch (_defaultDB) {
      case FIREBASE:
        if(_eventoDao==null)
          _eventoDao = EventoDaoFirebaseImpl();

        return _eventoDao;
        break;
      default:
        return null;
    }
  }
}