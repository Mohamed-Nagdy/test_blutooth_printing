import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:blutooth_print_app/pdf_creator.dart';
import 'package:blutooth_print_app/pdf_to_img_conveter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth Printing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Test Blutooth Printing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  BluetoothDevice? choosedDevice;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bluetoothPrint.state.listen((state) async {
      log('cur device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            connected = true;
          });
          bluetoothPrint.stopScan();
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            connected = false;
          });
          bluetoothPrint.stopScan();
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
            },
            icon: const Icon(Icons.bluetooth_searching),
          ),
          if (connected)
            IconButton(
              onPressed: () {
                printInvoice();
              },
              icon: const Icon(Icons.print),
            ),
        ],
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothPrint.scanResults,
        initialData: const [],
        builder: (c, snapshot) => Column(
          children: snapshot.data
                  ?.map(
                    (d) => ListTile(
                      title: Text(d.name ?? ''),
                      subtitle: Text(d.address ?? ''),
                      onTap: () async {
                        final dResult = await bluetoothPrint.disconnect();
                        log('Disconnecting Result $dResult');
                        setState(() {
                          choosedDevice = d;
                        });
                        if (choosedDevice != null) {
                          final result =
                              await bluetoothPrint.connect(choosedDevice!);
                          log('Connecting result $result');
                        }
                      },
                      trailing: choosedDevice != null &&
                              choosedDevice?.address == d.address
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : null,
                    ),
                  )
                  .toList() ??
              [],
        ),
      ),
    );
  }

  Future<void> printInvoice() async {
    List<LineText> list = [];
    File pdfFile = await PdfGenerator.createInvoicePdf();
    File imgFile = await PdfConverter.convertToImage(pdfFile.path);
    List<int> data = await imgFile.readAsBytes();
    String base64Image = base64Encode(data);
    list.add(
      LineText(
        type: LineText.TYPE_IMAGE,
        content: base64Image,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ),
    );
    await bluetoothPrint.printReceipt({}, list);
  }
}
