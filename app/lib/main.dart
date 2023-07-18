import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'package:app/login.dart';
import 'package:app/auth_bloc.dart';

void main() {
  runApp(RutanApp());
}

class RutanApp extends StatelessWidget {
  final AuthBloc authBloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => authBloc,
      child: MaterialApp(
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => Login(),
              settings: settings,
            );
          }
          return null;
        },
        routes: {
          '/': (context) => AppNavigator(),
        },
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocBuilder<AuthBloc, bool>(
      builder: (context, isLoggedIn) {
        if (isLoggedIn) {
          print(authBloc.username);
        }
        return Navigator(
          pages: [
            if (isLoggedIn)
              MaterialPage(
                child: Home(username: authBloc.username),
              )
            else
              MaterialPage(
                child: Login(),
              ),
          ],
          onPopPage: (route, result) {
            authBloc.add(AuthEvent.logout);
            return route.didPop(result);
          },
        );
      },
    );
  }
}
