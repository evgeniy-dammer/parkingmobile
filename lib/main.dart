import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:connectivity/connectivity.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MyApp());
}

class CarType {
  const CarType(this.id,this.type);

  final String type;
  final String id;
}

class NationalityType {
  const NationalityType(this.id,this.type);

  final String type;
  final String id;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Parking App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var autoNumber = TextEditingController();

  double balance = 0.0;

  CarType carType;
  NationalityType nationalityType;

  List<CarType> carTypes = <CarType>[
    const CarType("a8766eff-2f0e-4cb4-ab0c-5b4fd166e945",'Yenil awtoulag'),
    const CarType("5a91f0dd-3675-43c3-ac41-ee6b5566d35b",'Yuk, mikrawtobus 3 ton cenli'),
    const CarType("2c2b1109-c2f4-4f6d-8b79-18ec8096ef16",'Yuk, awtobus 3 tonnadan agyr'),
    const CarType("d155046f-396a-47aa-91dd-fdfbd5fb5ed4",'Tirkegli, yarym trk, uzyn awtobus'),
    const CarType("4494de27-639f-40a1-8de9-2df38ca2af28",'Motosikl, moroller, motokolyaska'),
    const CarType("53652c41-2017-4c0b-a29c-12fbfa6912fe",'Tirkegli motosikl'),
    const CarType("9a3e82ee-1adb-4082-b1f1-405fa6696aae",'Moped, welosiped'),
    const CarType("4659dd31-bcbd-4f08-ac6b-6c18129aae54",'Yenil awto satlyk ucin'),
  ];

  List<NationalityType> nationalityTypes = <NationalityType>[
    const NationalityType("8438f408-bfa8-4408-92c7-b5292471d8c5",'Turkmenistanyn rayat'),
    const NationalityType("a1cf2b5e-e2fe-4222-adbb-85d7eb0f4b91",'Dasary yurt rayat'),
  ];

  SharedPreferences prefs;
  @override
  void initState(){
    _doThis();
    super.initState();
  }

  @override
  void dispose(){
    autoNumber.dispose();
    super.dispose();
  }

  _doThis() async {




    prefs = await _prefs;
    String autoNum = prefs.getString('autoNumber');

    carType = carTypes[0];
    prefs.setString("autoType", carType.id);

    nationalityType = nationalityTypes[0];
    prefs.setString("nationalityType", nationalityType.id);

    autoNumber.text = autoNum;

    await _getBalance(autoNum);

  }

  _getBalance(String autoNum) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
      var response = await http.get(Uri.encodeFull('http://192.168.0.153:8181/api/balance/'+ autoNum), headers: {"Accept": "application/json"});

      setState(()
      {
        var extractdata = json.decode(response.body);
        balance = double.parse(extractdata["balance"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10.0),
              TextField(
                  controller: autoNumber,
                  onChanged: (text) async {
                    prefs.setString("autoNumber", text);
                  },
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 18),
                      hintText: 'Insert Auto Number',
                      border: new OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(const Radius.circular(15.0))
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(const Radius.circular(15.0))
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0, color: Theme.of(context).primaryColor),
                          borderRadius: const BorderRadius.all(const Radius.circular(15.0))
                      )
                  )
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                height: 60.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 2.0)
                ),
                child: DropdownButton<CarType>(
                  value: carType,
                  onChanged: (CarType newValue) {
                    setState(() {
                      carType = newValue;
                      prefs.setString("autoType", carType.id);
                    });
                  },
                  items: carTypes.map((CarType carTypes) {
                    return new DropdownMenuItem<CarType>(
                      value: carTypes,
                      child: new Text(
                        carTypes.type,
                        style: new TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                height: 60.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 2.0)
                ),
                child: DropdownButton<NationalityType>(
                  value: nationalityType,
                  onChanged: (NationalityType newValue) {
                    setState(() {
                      nationalityType = newValue;
                      prefs.setString("nationalityType", nationalityType.id);
                    });
                  },
                  items: nationalityTypes.map((NationalityType nationalityTypes) {
                    return new DropdownMenuItem<NationalityType>(
                      value: nationalityTypes,
                      child: new Text(
                        nationalityTypes.type,
                        style: new TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ButtonTheme(
                      height: 60,
                      child: new FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
                            side: BorderSide(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 2.0)
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text('Scan QR Code', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQRCodePage()));
                        }
                      )
                    )
                  ),
                ]
              ),
              SizedBox(height: 10.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: ButtonTheme(
                            height: 60,
                            child: new FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
                                    side: BorderSide(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 2.0)
                                ),
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                child: Text('Generate QR Code', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => _buildAboutDialog(context),
                                  );
                                }
                            )
                        )
                    ),
                  ]
              ),
              SizedBox(height: 20.0),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Text("Your balance:", style: TextStyle(fontSize: 23.0))
                    ),
                    new SizedBox(width: 5.0),
                    Expanded(
                        child: Text(balance.toString(), style: TextStyle(fontSize: 23.0))
                    )
                  ]
              ),
              SizedBox(height: 10.0),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: ButtonTheme(
                            height: 60,
                            child: new FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(const Radius.circular(15.0)),
                                    side: BorderSide(color: Theme.of(context).primaryColor, style: BorderStyle.solid, width: 2.0)
                                ),
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                child: Text('Refresh balance', style: TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  _getBalance(prefs.getString('autoNumber'));
                                }
                            )
                        )
                    )
                  ]
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildAboutDialog(BuildContext context) {
    return new AlertDialog(
        title: Text('Payment Method'),
        content: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                  child: ListTile(
                      title: Text('Online'),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GenerateQRCodeOnline()));
                      }
                  )
              ),
              Card(
                  child: ListTile(
                      title: Text('Cash'),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GenerateQRCodeCash()));
                      }
                  )
              )
            ]
        )
    );
  }
}

class ScanQRCodePage extends StatefulWidget {
  const ScanQRCodePage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQRCodePageState();
}

class _ScanQRCodePageState extends State<ScanQRCodePage> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;
  @override
  void initState(){
    _doThis();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _doThis() async {
    prefs = await _prefs;
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        controller.dispose();
        Navigator.popUntil(context, ModalRoute.withName('/'));

        var connectivityResult = await (Connectivity().checkConnectivity());

        if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
          Map<dynamic, dynamic> data = {
            'parkingId': result.code.toString(),
            'carPlate': prefs.getString('autoNumber').toString(),
            'carType': prefs.getString('autoType').toString(),
            'nationalityType': prefs.getString('nationalityType').toString(),
          };

          String body = json.encode(data);
          http.Response response = await http.post(Uri.encodeFull('http://192.168.0.153:8181/api/parkingin'), headers: <String, String>{"Accept": "application/json", 'Content-Type': 'application/json; charset=UTF-8'}, body: body);

          if (response.statusCode == 200) {

          }
        }
      }
    });
  }
}

class GenerateQRCodeCash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Generate QR Code Cash"),
        ),
        body: GenerateQRCodeCashPage()
    );
  }
}

class GenerateQRCodeCashPage extends StatefulWidget {
  GenerateQRCodeCashPage();

  @override
  _GenerateQRCodeCashPageState createState(){
    return _GenerateQRCodeCashPageState();
  }
}

class _GenerateQRCodeCashPageState extends State<GenerateQRCodeCashPage> {
  String text = "";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;

  _getDoThis() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

    prefs = await _prefs;
    setState(() {
      text = "M/" + prefs.getString('autoNumber') + "/" + formatter.format(now) + "/C";
      //print(text);
    });
  }

  @override
  void initState(){
    _getDoThis();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          QrImage(
            data: text,
            version: QrVersions.auto,
            size: 300,
            gapless: true,
          )
        ]
      )
   );
  }
}

class GenerateQRCodeOnline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Generate QR Code Online"),
        ),
        body: GenerateQRCodeOnlinePage()
    );
  }
}

class GenerateQRCodeOnlinePage extends StatefulWidget {
  GenerateQRCodeOnlinePage();

  @override
  _GenerateQRCodeOnlinePageState createState(){
    return _GenerateQRCodeOnlinePageState();
  }
}

class _GenerateQRCodeOnlinePageState extends State<GenerateQRCodeOnlinePage> {
  String text = "";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;

  _getDoThis() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

    prefs = await _prefs;
    setState(() {
      text = "M/" + prefs.getString('autoNumber') + "/" + formatter.format(now) + "/O";
      //print(text);
    });
  }

  @override
  void initState(){
    _getDoThis();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              QrImage(
                data: text,
                version: QrVersions.auto,
                size: 300,
                gapless: true,
              )
            ]
        )
    );
  }
}