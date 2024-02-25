// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  HttpOverrides.global =
      MyHttpOverrides(); // this line for accepting certificate of https
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insert Device',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Insert A New Device'),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
} //this class to accept https certificate

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _MyHomePageState extends State<MyHomePage> {
  static var _scanBarcode;
  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);
      debugPrint("baaaaaaaaaaaaaaaaaaaaaaaar is $_scanBarcode");
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (barcodeScanRes != "-1") {
      showDialog(
          //useSafeArea: true,
          barrierDismissible: false,
          //context: context,
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return const CustomDialog();
          });
    } else {
      debugPrint("Canceled");
    }
    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    debugPrint("bar code is: $barcodeScanRes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
            onPressed: () async {
              scanQR();
            },
            icon: const Icon(Icons.qr_code),
            label: const Text("Scan Device Serial")),
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final TextEditingController Description = TextEditingController();

  @override
  void dispose() {
    Description.dispose();
    super.dispose();
  }

  String API_Link = "https://46.4.15.249:9090/ords/appsoft"; // appsoft
  //"http://46.4.15.249:9095/ords/mes"; //mes test schema
  //"https://172.25.0.6:9090/ords/appsoft"; //sahinler local
  //"https://46.4.15.249:9090/ords/sahinler"; // sahinler cloud

  Future PostNewDevice(
      var serial, var desc, int? isShared, BuildContext context2) async {
    //var machineCode,
    var response = await http.post(Uri.parse('$API_Link/MES/insertNewDevice'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "deviceSerial": "$serial",
          "deviceDesc": "$desc",
          //"machineCode": "$machineCode",
          "isShared": "$isShared"
        }));
    if (response.statusCode == 200) {
      final snackBar = SnackBar(
        duration: const Duration(seconds: 5),
        content: const Text("Device has been inserted"),
        backgroundColor: (const Color.fromARGB(255, 4, 247, 105)),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context2).showSnackBar(snackBar);
      return print("Done");
    } else {
      final snackBar = SnackBar(
        duration: const Duration(seconds: 5),
        content: const Text("Device has NOT been inserted"),
        backgroundColor: (const Color.fromARGB(255, 136, 11, 2)),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context2).showSnackBar(snackBar);
      return print("error");
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool _value = false;
  @override
  Widget build(BuildContext context1) {
    return Center(
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: AlertDialog(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Device Information'),
              Divider(
                color: Color.fromARGB(255, 1, 57, 83),
                endIndent: 20,
                indent: 20,
                //height: 20,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  //obscureText: true,
                  controller: Description,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter device Description please";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 1, 58, 105), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 3, 205, 212), width: 2),
                    ),
                    labelText: "Device Description",
                    hintText: "Enter Description here",
                    icon: const Icon(Icons.description,
                        color: Color.fromARGB(255, 3, 111, 212)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(Icons.label_important,
                      color: Color.fromARGB(255, 3, 111, 212)),
                  Expanded(
                    child: CheckboxListTile(
                        title: const Text("Shared Device"),
                        subtitle: const Text("Is this device shared ?"),
                        value: _value,
                        onChanged: (value) {
                          setState(() {
                            _value = value!;
                          });
                        }),
                  ),
                ],
              )
            ],
          ),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context1).pop();
                          PostNewDevice(
                              _MyHomePageState._scanBarcode,
                              Description.text,
                              _value ? 1 : 0,
                              _scaffoldKey.currentContext!);
                        }
                      },
                      child: const Text("Done")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context1).pop();
                      },
                      child: const Text("Cancal")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
