import 'package:app/admin_home.dart';
import 'package:app/cs_chatList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'package:app/login.dart';
import 'package:app/auth_bloc.dart';

void main() {
  runApp(RutanApp());
}

class RutanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(),
          ),
        ],
        child: AppNavigator(),
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
            if (isLoggedIn && authBloc.status == "1") ...[
              MaterialPage(
                child: adminHome(username: authBloc.username),
              )
            ] else if (isLoggedIn && authBloc.status == "2") ...[
              MaterialPage(
                child: csChatList(username: authBloc.username),
              )
            ] else if (isLoggedIn && authBloc.status == "3") ...[
              MaterialPage(
                child: userHomeScreen(uname: authBloc.username),
              )
            ]else ...[
              MaterialPage(
                child: Login(),
              ),
            ]
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
