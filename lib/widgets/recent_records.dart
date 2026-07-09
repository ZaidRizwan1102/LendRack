import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class RecentRecord{
  final String name;
  final String? description;
  final String amount;
  final String type;
  final String date;

  RecentRecord({
    required this.name,
    required this.description,
    required this.amount,
    required this.type,
    required this.date
  });
}
final List<RecentRecord> records = [
  RecentRecord(
    name: 'Felix Chen',
    description: 'Dinner split',
    amount: '\$45.50',
    type: 'LENDED',
    date: '2023-06-15',  
  ),
  RecentRecord(
    name: 'Sarah Jenkins',
    description: '',
    amount: '\$850.00',
    type: 'BORROWED',
    date: '2023-06-10',
  ),
  RecentRecord(
    name: 'Michael Ross',
    description: 'Concert tickets',
    amount: '\$120.00',
    type: 'LENDED',
    date: '2023-06-05',
  ),
  RecentRecord(
    name: 'Mishel Ross',
    description: 'Concert tickets',
    amount: '\$20.00',
    type: 'BORROWED',
    date: '2023-06-05',
  ),
];
class RecentRecords extends StatefulWidget {
  const RecentRecords({super.key});

  @override
  State<RecentRecords> createState() => _RecentRecordsState();
}

class _RecentRecordsState extends State<RecentRecords> {
  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder:
          (context,index){ 
        final record = records[index];
        final isLended = record.type == 'LENDED';
        return Container(
          margin: EdgeInsets.all(size.heightPerc(2)),
          padding: EdgeInsets.all(size.heightPerc(1.2)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.heightPerc(1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ]
          ),
           child: Row(
             children: [
              Column(
                children: [
                  Text(record.name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  if(record.description != null && record.description!.isNotEmpty)...[
                   SizedBox(height: size.heightPerc(1),),
                   Text(record.description!)
                  ]
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text(record.date),
                  SizedBox(height: size.heightPerc(1.3),),
                  Text('${isLended? '-':'+'}${record.amount}',
                  style: TextStyle(color: isLended? Colors.red:Colors.green.shade700,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),)

                ],
              )
             ],
           )
        );
      }
    );
  }
}