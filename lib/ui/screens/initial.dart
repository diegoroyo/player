import 'package:app/providers/auth_provider.dart';
import 'package:app/ui/screens/data_loading.dart';
import 'package:app/ui/screens/login.dart';
import 'package:app/ui/widgets/spinner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatefulWidget {
  static const routeName = '/';

  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _resolveAuthenticatedUser();
  }

  Future<void> _resolveAuthenticatedUser() async {
    // no internet and stored token -> load data, skip connections
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      if (context.read<AuthProvider>().hasStoredToken) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DataLoadingScreen(),
          transitionDuration: Duration.zero,
        ));
      } else {
        await Navigator.of(context, rootNavigator: true).pushReplacementNamed(
          LoginScreen.routeName,
        );
      }
    }

    context.read<AuthProvider>().tryGetAuthUser().then((user) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            user == null ? const LoginScreen() : const DataLoadingScreen(),
        transitionDuration: Duration.zero,
      ));
    }, onError: (_) async {
      await Navigator.of(context, rootNavigator: true).pushReplacementNamed(
        LoginScreen.routeName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ContainerWithSpinner();
  }
}
