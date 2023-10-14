import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/home.dart';
import 'package:app/login.dart';
import 'package:app/auth_bloc.dart';
import 'notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(RutanApp());
}
// void main() {
//   runApp(RutanApp());
// }

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
                child: userHomeScreen(uname: authBloc.username, status: "1"),
              )
            ] else if (isLoggedIn && authBloc.status == "2") ...[
              MaterialPage(
                child: userHomeScreen(uname: authBloc.username, status: "2"),
              )
            ] else if (isLoggedIn && authBloc.status == "3") ...[
              MaterialPage(
                child: userHomeScreen(uname: authBloc.username, status: "3"),
              )
            ] else if (isLoggedIn && authBloc.status == "4") ...[
              MaterialPage(
                child: userHomeScreen(uname: authBloc.username, status: "4"),
              )
            ] else ...[
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
