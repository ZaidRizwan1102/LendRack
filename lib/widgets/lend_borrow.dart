import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class LendBorrow extends StatefulWidget {
  const LendBorrow({super.key});

  @override
  State<LendBorrow> createState() => _LendBorrowState();
}

class _LendBorrowState extends State<LendBorrow> {
  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Padding(
      padding: EdgeInsets.only(left: size.widthPerc(4), right: size.widthPerc(4)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: size.widthPerc(50),
              height: size.heightPerc(17),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: size.widthPerc(2),
                    color: Colors.green
                  )
                ),
                borderRadius: BorderRadius.circular(size.widthPerc(3)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: size.widthPerc(3), top: size.widthPerc(3)),
                        child: Container(
                          width: size.widthPerc(10),
                          height: size.heightPerc(6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: BorderRadius.circular(size.widthPerc(2))
                          ),
                          child: Icon(Icons.south_west, color: Colors.green.shade800,),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: size.widthPerc(3), top: size.widthPerc(3)),
                        child: Text('Borrowed', style:
                          TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500
                          ),),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.widthPerc(4.5)),
                    child: Text('\$2,340',
                      style: TextStyle( fontSize: 27,
                          fontWeight: FontWeight.w600, color: Colors.green.shade800
                    ),
                    ),
                  )
                ],
              ),
            ),
          ),


          SizedBox(width: size.widthPerc(4),),


          Expanded(
            child: Container(
              width: size.widthPerc(50),
              height: size.heightPerc(17),
              decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          width: size.widthPerc(2),
                          color: Colors.redAccent
                      )
                  ),
                  borderRadius: BorderRadius.circular(size.widthPerc(3)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: size.widthPerc(3), top: size.widthPerc(3)),
                        child: Container(
                          width: size.widthPerc(10),
                          height: size.heightPerc(6),
                          decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(size.widthPerc(2))
                          ),
                          child: Icon(Icons.north_east, color: Colors.red.shade800,),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: size.widthPerc(3), top: size.widthPerc(3)),
                        child: Text('Lended', style:
                        TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500
                        ),),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.widthPerc(4.5)),
                    child: Text('\$2,340',
                      style: TextStyle( fontSize: 27,
                          fontWeight: FontWeight.w600, color: Colors.red
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
