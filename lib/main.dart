import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:udp/udp.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';

void main() {
  runApp(const MyApp());
  //reciveUsingUdp();
}

void sendUsingUdp() async {
  var sender = await UDP.bind(Endpoint.any(port: Port(65000)));

  // send a simple string to a broadcast endpoint on port 65001.
  var dataLength = await sender.send(
      'Hello World!'.codeUnits, Endpoint.broadcast(port: Port(65001)));

  stdout.writeln('$dataLength bytes sent.');

  // creates a new UDP instance and binds it to the local address and the port
  // 65002.

  // close the UDP instances and their sockets.
  sender.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String msg = "";
  Future<String?> reciveUsingUdp() async {
    //List<String> fragmentedData = [];
    final receivedFragments = <int, List<int>>{};
    if (kDebugMode) {
      print("determine multicast point");
    }
    var unicastEndpoint =
        Endpoint.unicast(InternetAddress.anyIPv4, port: const Port(65002));
    // creates a new UDP instance and binds it to the local address and the port
    // 65002.
    var receiver = await UDP.bind(unicastEndpoint);
    if (kDebugMode) {
      print(" start listening!!!");
    }
    // receiving\listening
    receiver.asStream().listen((datagram) {
      /*if (kDebugMode) {
        print("datagram recived!!!");
      }*/
      if (datagram != null) {
        final receivedData = datagram.data;
        final sequenceNumber = receivedData[2];
        receivedFragments.putIfAbsent(sequenceNumber, () => []);
        receivedFragments[sequenceNumber]!.addAll(receivedData.sublist(3));
        //print(receivedFragments.toString());
        //var message = String.fromCharCodes(datagram.data);
        // var message = '';
        //final totalFragments = 4;
        //fragmentedData.add(message);
        //print(message);
        //  if (receivedFragments.length == totalFragments) {}
        // Reassemble the data here.
        //print("ohhhhhhhhhhhhhhhhhhhhhhhhhhhhh!!!!!!!!!!! 4");
        /*final assembledData = List<int>.from(
            receivedFragments.values.expand((element) => element));*/
        var message = '';
        List<int> assembledData = [];
        List<String> assembledmsg = [];
        receivedFragments.values.forEach((fragmentList) {
          assembledData.addAll(fragmentList);
        });
        //print('Received UDP packet: ${String.fromCharCodes(assembledData)}');
        // print(assembledData.toString());
        message = String.fromCharCodes(assembledData);
        print(message);
        // Clear the received fragments for the next packet.
        receivedFragments.clear();
        //}
        //print(message);
        //print(fragmentedData.toString());
        setState(() {
          msg = msg + message;
        });

        //stdout.write(message);
      }
    });
    await Future.delayed(Duration(seconds: 5));
    return null;
    //receiver.close();
    /*virif (kDebugMode) {
    print(" stop listening!!!");
  }*/
    /* const port = 65002;
    const address = '192.168.99.226';

    final socket = await RawDatagramSocket.bind(address, port);
    socket.multicastHops = 1;
    socket.broadcastEnabled = true;
    socket.writeEventsEnabled = true;
    socket.listen((RawSocketEvent event) {
      print("still listening...");

      final packet = socket.receive();
      print("The packet was $packet");
      print("It came from ${packet?.address}");
    });*/
    /*socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram datagram = socket.receive(); // Receive a UDP packet.
      if (datagram != null) {
        // Handle the received packet.
        print('Received UDP packet from ${datagram.address}:${datagram.port}');
        print('Data: ${datagram.data}');
      }
    }
  });*/
  }

  @override
  void initState() {
    super.initState();
    reciveUsingUdp();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
    print(_counter);
    //stdout.write(_counter);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Expanded(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter' + '$msg',
                style: Theme.of(context).textTheme.headlineMedium,
                //expandText: 'show more',
                //collapseText: 'show less',
                //maxLines: 10,
                //linkColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: //_incrementCounter,
            //_incrementCounter,
            sendUsingUdp,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
