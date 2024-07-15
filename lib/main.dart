// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables, avoid_renaming_method_parameters

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:insert_new_device/models/category.dart';
import 'package:insert_new_device/models/machine.dart';
import 'dart:async';
import 'dart:convert';

import 'package:insert_new_device/models/workCenters.dart';

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

class SearchMachine {
  String Name;
  int Code;
  SearchMachine({
    required this.Name,
    required this.Code,
  });
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
  State<MyHomePage> createState() => MyHomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyHomePageState extends State<MyHomePage> {
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

  List<SearchMachine> machines = [];
  static SearchMachine? MachineValue;

  void getMachinesList(var cat) async {
    machines.clear();
    machines.add(SearchMachine(Code: -1, Name: "-"));
    var response = await http.get(
        Uri.parse('${CustomDialogState.API_Link}/MES/machineList'),
        headers: {"catCode": "$cat"});
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      List<Machine>? list = ((jsonDecode("[$body]")) as List)
          .map((data) => Machine.fromJson(data))
          .toList();
      machines = List<SearchMachine>.generate(
          list[0].count,
          (int index) => SearchMachine(
              Code: list[0].items[index].code,
              Name: "${list[0].items[index].name}"),
          growable: true);
      setState(() {});
      if (machines.isNotEmpty) {
        setState(() {
          MachineValue = machines.first;
        });
      }
    }
  }

  static Category? CategoryValue;
  List<Category> CategoryList = [];
  Future<void> getMachinesCategoryList() async {
    CategoryList.clear();
    CategoryList.add(Category(code: -1, name: "-"));
    var response = await http.get(
        Uri.parse("${CustomDialogState.API_Link}/MES/machinesCategoriesList"));
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      List<MachinesCategories>? list = ((jsonDecode("[$body]")) as List)
          .map((data) => MachinesCategories.fromJson(data))
          .toList();
      for (int i = 0; i < list[0].count; i++) {
        CategoryList.add(
            Category(code: list[0].items[i].code, name: list[0].items[i].name));
      }
      if (CategoryList.isNotEmpty) {
        setState(() {
          CategoryValue = CategoryList.first;
        });
      }
    } else {}
  }

  static WC? WorkCenterValue;
  List<WC> workCentersList = [];
  Future<void> getWorkCenterList() async {
    workCentersList.clear();
    var response = await http.get(
        Uri.parse("${CustomDialogState.API_Link}/MES/workCenters"),
        headers: {"owner": "0"});
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      List<WorkCenters>? list = ((jsonDecode("[$body]")) as List)
          .map((data) => WorkCenters.fromJson(data))
          .toList();
      for (int i = 0; i < list[0].count; i++) {
        workCentersList
            .add(WC(code: list[0].items[i].code, name: list[0].items[i].name));
      }
      if (workCentersList.isNotEmpty) {
        setState(() {
          WorkCenterValue = workCentersList.first;
        });
      }
    } else {}
  }

  @override
  void initState() {
    getWorkCenterList();
    getMachinesCategoryList();
    getMachinesList(-1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color.fromRGBO(94, 189, 233, 0.886),
                Color.fromRGBO(20, 20, 190, 0.698),
              ],
              tileMode: TileMode.mirror,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(255, 165, 164, 164),
                  spreadRadius: 4,
                  blurRadius: 8),
            ],
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Color.fromARGB(255, 31, 31, 31),
              fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Card(
                elevation: 12,
                color: const Color.fromARGB(255, 233, 205, 226),
                shadowColor: const Color.fromARGB(255, 143, 145, 146),
                child: ListTile(
                  leading: const Icon(
                    Icons.category,
                    color: Color.fromARGB(255, 58, 1, 1),
                  ),
                  title: const Text(
                    "Categories",
                  ),
                  subtitle: DropdownButton<Category>(
                      isExpanded: true,
                      value: CategoryValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 24,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 1,
                        color: Colors.deepPurpleAccent,
                      ),
                      items: CategoryList.map<DropdownMenuItem<Category>>(
                          (Category value) {
                        return DropdownMenuItem<Category>(
                          value: value,
                          child: Text(
                            value.name,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                //fontSize: 20,
                                ),
                          ),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) async {
                        setState(
                          () {
                            CategoryValue = newValue!;
                          },
                        );
                        getMachinesList(CategoryValue?.code);
                      }),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Card(
                elevation: 12,
                color: const Color.fromARGB(255, 192, 218, 240),
                shadowColor: const Color.fromARGB(255, 143, 145, 146),
                child: ListTile(
                  leading: const Icon(
                    Icons.construction,
                    color: Color.fromARGB(255, 92, 0, 168),
                  ),
                  title: const Text(
                    "Machines",
                  ),
                  subtitle: DropdownButton<SearchMachine>(
                      isExpanded: true,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      value: MachineValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 24,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 1,
                        color: Colors.deepPurpleAccent,
                      ),
                      items: machines.map<DropdownMenuItem<SearchMachine>>(
                          (SearchMachine value) {
                        return DropdownMenuItem<SearchMachine>(
                          value: value,
                          child: Text(
                            value.Name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                //fontSize: 20,
                                ),
                          ),
                        );
                      }).toList(),
                      onChanged: (SearchMachine? newValue) {
                        setState(
                          () {
                            MachineValue = newValue!;
                          },
                        );
                      }),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Card(
                elevation: 12,
                color: const Color.fromARGB(255, 218, 192, 240),
                shadowColor: const Color.fromARGB(255, 143, 145, 146),
                child: ListTile(
                  leading: const Icon(
                    Icons.home_work_sharp,
                    color: Color.fromARGB(255, 3, 0, 168),
                  ),
                  title: const Text(
                    "Work Centers",
                  ),
                  subtitle: DropdownButton<WC>(
                      isExpanded: true,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      value: WorkCenterValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 24,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 1,
                        color: Colors.deepPurpleAccent,
                      ),
                      items:
                          workCentersList.map<DropdownMenuItem<WC>>((WC value) {
                        return DropdownMenuItem<WC>(
                          value: value,
                          child: Text(
                            "${value.name}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                //fontSize: 20,
                                ),
                          ),
                        );
                      }).toList(),
                      onChanged: (WC? newValue) {
                        setState(
                          () {
                            WorkCenterValue = newValue!;
                          },
                        );
                      }),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            ElevatedButton.icon(
                onPressed: () async {
                  scanQR();
                },
                icon: const Icon(
                  Icons.qr_code,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 16,
                  backgroundColor: const Color.fromARGB(255, 1, 18, 117),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                ),
                label: const Text("Scan Device Serial",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ))),
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});
  @override
  CustomDialogState createState() => CustomDialogState();
}

class CustomDialogState extends State<CustomDialog> {
  final TextEditingController Description = TextEditingController();

  @override
  void dispose() {
    Description.dispose();
    super.dispose();
  }

  static String API_Link =
      //"https://46.4.15.249:9090/ords/appsoft"; // appsoft
      //"http://46.4.15.249:9095/ords/mes"; //mes test schema
      "https://172.25.0.6:9090/ords/appsoft"; //sahinler local
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
          "machineCategoryCode": "${MyHomePageState.CategoryValue?.code}",
          "machineCode": "${MyHomePageState.MachineValue?.Code}",
          "workCenter": "${MyHomePageState.WorkCenterValue?.code}",
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
                              MyHomePageState._scanBarcode,
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
