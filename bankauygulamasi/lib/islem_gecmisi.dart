import 'package:bankauygulamasi2/database_db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IslemGecmisi extends StatefulWidget {
  IslemGecmisi({Key? key}) : super(key: key);

  @override
  State<IslemGecmisi> createState() => _IslemGecmisiState();
}

class _IslemGecmisiState extends State<IslemGecmisi> {
  late Future<List<Map<String, dynamic>>> futislemler;

  @override
  void initState() {
    super.initState();
    futislemler = DataBaseGets().getIslemler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İşlemler')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futislemler,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('İşlem Tarihi')),
                    DataColumn(label: Text('Açıklama')),
                    DataColumn(label: Text('Tutar')),
                    DataColumn(label: Text('Bakiye'))
                  ],
                  rows: List<DataRow>.generate(
                    snapshot.data!.length,
                    (index) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(DateFormat.MMMMd().add_Hm().format(
                            DateTime.fromMillisecondsSinceEpoch(snapshot
                                .data![index]['islem tarihi']
                                .millisecondsSinceEpoch)))),
                        DataCell(
                            Text(snapshot.data![index]['açıklama'].toString())),
                        DataCell(
                            Text(snapshot.data![index]['tutar'].toString())),
                        DataCell(
                            Text(snapshot.data![index]['bakiye'].toString())),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
