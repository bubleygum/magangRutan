import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthEvent { login, logout, checkLogin }

class AuthBloc extends Bloc<AuthEvent, bool> {
  late String username;
  late String status;
  AuthBloc() : super(false) {
    add(AuthEvent.checkLogin); 
  }

  @override
  Stream<bool> mapEventToState(AuthEvent event) async* {
    switch (event) {
      case AuthEvent.login:
        yield true;
        break;
      case AuthEvent.logout:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        yield false;
        break;
      case AuthEvent.checkLogin:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        username = prefs.getString('username') ?? '';
        status = prefs.getString('status') ?? '';
        yield isLoggedIn;
        break;
    }
  }
}
