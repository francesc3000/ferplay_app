import 'package:ferplayapp/src/models/user.dart';

class Injector {
  static final Injector _singleton = new Injector._internal();
  // static Flavor _flavor;
  static User currentUser;

  // static void configure(Flavor flavor) {
  //   _flavor = flavor;
  // }

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  // static DatabaseReference get eventoRepository {
  //   switch(_flavor) {
  //     case Flavor.DEV:
  //       return FirebaseDatabase.instance.reference().child("DEV").child(Strings.eventosBD);
  //     default: // Flavor.PRO:
  //       return FirebaseDatabase.instance.reference().child("PRO").child(Strings.eventosBD);
  //   }
  // }

  // static DatabaseReference get userRepository {
  //   switch(_flavor) {
  //     case Flavor.DEV:
  //       return FirebaseDatabase.instance.reference().child("DEV").child(Strings.usersBD);
  //     default: // Flavor.PRO:
  //       return FirebaseDatabase.instance.reference().child("PRO").child(Strings.usersBD);
  //   }
  // }

  // static DatabaseReference get favoriteRepository {
  //   switch(_flavor) {
  //     case Flavor.DEV:
  //       return FirebaseDatabase.instance.reference().child("DEV").child(Strings.favoritesBD);
  //     default: // Flavor.PRO:
  //       return FirebaseDatabase.instance.reference().child("PRO").child(Strings.favoritesBD);
  //   }
  // }
}