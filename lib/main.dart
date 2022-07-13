import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdemo/service/link_service.dart';
import 'package:flutterdemo/service/log_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await runZonedGuarded(() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String deeplink = "no link";

  final remoteConfig = FirebaseRemoteConfig.instance;
  final Map<String, dynamic> availableBackgroundColors = {
    "red": Colors.red,
    "yellow": Colors.yellow,
    "blue": Colors.blue,
    "green": Colors.green,
    "white": Colors.white
  };
  String backgroundColor = "white";

  @override
  void initState() {
    super.initState();
    LinkService.retrieveDynamicLink().then((value) => {
          setState(() {
            if (value != null) {
              deeplink = value.toString();
              // need to save data locally...
            } else {
              deeplink = "No Link";
            }
          })
        });
    LinkService.createShortLink("200002");
    //initConfig();
  }

  /**
   * Remote Config Functions
   */
  void initConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(
          seconds: 1), // a fetch will wait up to 10 seconds before timing out
      minimumFetchInterval: const Duration(
          seconds:
              10), // fetch parameters will be cached for a maximum of 1 hour
    ));

    await remoteConfig.setDefaults(const {
      "background_color": "white",
    });
    fetchConfig();
  }

  void fetchConfig() async {
    await remoteConfig.fetchAndActivate().then((value) => {
          setState(() {
            backgroundColor =
                remoteConfig.getString('background_color').isNotEmpty
                    ? remoteConfig.getString('background_color')
                    : "white";
          }),
          LogService.d(value.toString())
        });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      //FirebaseCrashlytics.instance.crash();
      //LinkService.createShortLink("200002");
      //LinkService.createLongLink("100001");
      //fetchConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: availableBackgroundColors[backgroundColor],
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              deeplink,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
