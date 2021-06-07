import 'package:flutter/material.dart';
import 'package:food_delivery_app/user/Cart.dart';
import 'package:food_delivery_app/user/EatDaily.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/Chefdata.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'Utils.dart';

final now = new DateTime.now();

class MealDaily2 extends StatefulWidget {
  CartData cartData;
  Function type2;
  String type;
  Function refreshCartNumber;
  MealDaily2(this.type2, this.type, this.refreshCartNumber);
  @override
  _MealDaily2State createState() => _MealDaily2State();
}

class _MealDaily2State extends State<MealDaily2> {
  // Helper help=new Helper();
  CartData cartData;
  Map ll;
  final db = FirebaseFirestore.instance;
  CartData cartdata;
  Map chef = {};
  List<Dishes> dishes = [];

  void refresher_funct() {
    // (context as Element).reassemble();
    print("ssssssssssssssssssssssssssssssssssssssssss");
    // print()
    if (CartData.dishes.isNotEmpty)
      Fluttertoast.showToast(
          msg: "Showing " + CartData.dishes[0].dish.name + "'s food only",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Helper().button,
          textColor: Colors.white,
          fontSize: 16.0);
    setState(() {
      dishes = [];
    });
    // rebuildAllChildren(context);
    // EatNow(cartData: new CartData());

    // Navigator.push(context,
    //     new MaterialPageRoute(builder: (context) => this.build(context)));
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  @override
  void initState() {
    super.initState();

    this.cartdata = widget.cartData;
    // this.data();
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(children: [
          StreamBuilder<QuerySnapshot>(
            stream: db.collection('Food_items').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder<QuerySnapshot>(
                  stream: db.collection('Chef').snapshots(),
                  builder: (context, snapshot2) {
                    if (snapshot2.hasData) {
                      chef = {};
                      for (int i = 0; i < snapshot2.data.docs.length; i++) {
                        print(snapshot2.data.docs[i].data());
                        chef[snapshot2.data.docs[i].id] =
                            snapshot2.data.docs[i].data();
                      }
                      dishes = [];
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        if (snapshot.data.docs[i]["mealType"].toLowerCase() ==
                            widget.type.toLowerCase()) {
                          var chef_detail =
                              chef[snapshot.data.docs[i]["chefId"]];
                          var dd = snapshot.data.docs[i];
                          DateTime tomorrow;
                          TimeOfDay nowTime = TimeOfDay.now();
                          double currentTime = toDouble(nowTime);

                          double itemToTime1 =
                              double.parse(dd["toTime"].split(':')[0]);
                          double itemToTime2 =
                              double.parse(dd["toTime"].split(':')[1]);
                          double itemToTime = itemToTime1 + itemToTime2 / 60.0;

                          if (currentTime <= itemToTime) {
                            tomorrow = DateTime(now.year, now.month, now.day);
                          } else {
                            tomorrow =
                                DateTime(now.year, now.month, now.day + 1);
                          }
                          if (chef_detail != null) {
                            Dishes dish = new Dishes(
                                chef_detail["fname"].toString(),
                                chef_detail["chefAddress"].toString(),
                                chef_detail["rating"].toDouble(),
                                dd["dishName"].toString(),
                                dd["self_delivery"],
                                dd["price"].toDouble(),
                                dd["imageUrl"].toString(),
                                "25 min",
                                dd["mealType"],
                                dd["count"],
                                dd["chefId"],
                                dd["toTime"],
                                dd["fromTime"],
                                DateFormat('dd MMM y')
                                    .format(tomorrow)
                                    .toString());
                            dishes.add(dish);
                          }
                        }
                      }
                      print(dishes);

                      return Column(
                        children: [
                          Center(
                            child: OutlinedButton.icon(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (!states.contains(MaterialState.pressed))
                                      return Helper().button.withOpacity(0.8);
                                    return null; // Use the component's default.
                                  },
                                ),
                              ),
                              onPressed: () {
                                widget.type2("");
                              },
                              label: Text(
                                "BACK",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              icon: Icon(
                                Icons.arrow_left,
                                size: totalHeight * 30 / 700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Column(
                              children: dishes.map((data) {
                            print(ll);
                            if (CartData.dishes.length == 0 ||
                                data.getChefId() ==
                                    CartData.dishes[0].dish.getChefId()) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleCard(
                                    data.name,
                                    data.chefAddress,
                                    data.rating,
                                    data.getPrice(),
                                    data.getDishName(),
                                    data.getSelfDelivery(),
                                    data.getimage(),
                                    data.gettime(),
                                    data.getCount(),
                                    this.cartData,
                                    data.getCount(),
                                    data.getChefId(),
                                    data.getToTime(),
                                    data.getFromTime(),
                                    () => {
                                          widget.refreshCartNumber(),
                                          refresher_funct()
                                        }),
                              );
                            } else {
                              return Container();
                            }
                          }).toList()),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                );
                // for (int i = 0; i <elem; i++) {
                //   tp.add(snapshot.data.docs[i]);
                // }
                // print(tp);

              } else {
                return Container();
              }
            },
          )
        ]),
      ),
    );
  }

  // Widget Outline_button(String time, IconData icon) {
  //   return OutlinedButton.icon(
  //     style: ButtonStyle(
  //       backgroundColor: MaterialStateProperty.resolveWith<Color>(
  //         (Set<MaterialState> states) {
  //           if (!states.contains(MaterialState.pressed))
  //             return Helper().button.withOpacity(1);
  //           return null; // Use the component's default.
  //         },
  //       ),
  //     ),
  //     onPressed: () {
  //       // Respond to button press
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => FoodOrderPage(),
  //         ),
  //       );
  //     },
  //     label: Text(
  //       time,
  //       style: TextStyle(
  //           color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
  //     ),
  //     icon: Icon(
  //       icon,
  //       size: 30,
  //       color: Colors.white,
  //     ),
  //   );
  // }
}

class SingleCard extends StatefulWidget {
  String name, chefAddress, dishName, image, time, chefId, fromTime, toTime;
  bool self_delivery;
  dynamic rating;
  int quantity, count;
  dynamic price;
  CartData cartData;
  Function refresh;
  SingleCard(
      this.name,
      this.chefAddress,
      this.rating,
      this.price,
      this.dishName,
      this.self_delivery,
      this.image,
      this.time,
      this.quantity,
      this.cartData,
      this.count,
      this.chefId,
      this.fromTime,
      this.toTime,
      this.refresh);
  @override
  _SingleCardState createState() => _SingleCardState();
}

class _SingleCardState extends State<SingleCard> {
  Helper help = new Helper();
  var canAdd = 1;
  int canIncrease = 1;
  int itemCount = 1;

  void checkCart_add() {
    for (int i = 0; i < CartData.dishes.length; i++) {
      if (CartData.dishes[i].dish.getDishName() == widget.dishName &&
          CartData.dishes[i].dish.name == widget.name) {
        setState(() {
          canAdd = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // var total_remaining_time = int.parse(widget.time);
    checkCart_add();
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Card(
      color: help.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(totalHeight * 26.0 / 820),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.person),
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.name,
                                style: TextStyle(
                                    fontSize: totalHeight * 16.0 / 820,
                                    color: help.heading)),
                            Text('Rating ' + widget.rating.toString() + ' ⭐',
                                style: TextStyle(
                                    fontSize: totalHeight * 10.0 / 820,
                                    fontWeight: FontWeight.w300)),
                          ])
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.dishName,
                      style: TextStyle(
                          color: help.heading, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.price.toString() + "₹ (per serve)",
                      style: TextStyle(
                          color: help.normalText, fontWeight: FontWeight.w100),
                    ),
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(itemCount.toString(),
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900)),
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(
                                        totalHeight * 10.0 / 820)),
                                color: help.button),
                            padding: new EdgeInsets.fromLTRB(
                                totalHeight * 16.0 / 820,
                                totalHeight * 10.0 / 820,
                                totalHeight * 16.0 / 820,
                                totalHeight * 10.0 / 820),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: Helper().button,
                              size: totalHeight * 28 / 700,
                            ),
                            tooltip: 'Delete',
                            onPressed: () => {
                              setState(() {
                                itemCount = help.delQuantity(itemCount);
                                print(itemCount);
                              }),
                              if (itemCount < widget.quantity)
                                {
                                  setState(() {
                                    canIncrease = 1;
                                  })
                                },
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: canIncrease == 1
                                  ? Helper().button
                                  : Colors.grey,
                              size: totalHeight * 28 / 700,
                            ),
                            tooltip: 'Add',
                            onPressed: () => {
                              if (widget.quantity > itemCount)
                                {
                                  setState(() {
                                    itemCount = help.addQuantity(itemCount);
                                    print(itemCount);
                                  }),
                                  if (widget.quantity == itemCount)
                                    {
                                      setState(() {
                                        canIncrease = 0;
                                      })
                                    }
                                }
                              else
                                {
                                  setState(() {
                                    canIncrease = 0;
                                  }),
                                  Fluttertoast.showToast(
                                      msg: "Order Limit Exceeded",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Helper().button,
                                      textColor: Colors.white,
                                      fontSize: 16.0)
                                }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Stack(children: [
                Container(
                  height: totalHeight * 1.5 / 7,
                  width: totalWidth * 3 / 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    image: DecorationImage(
                        image: NetworkImage(
                          widget.image,
                        ),
                        fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                    right: 5,
                    bottom: -5,
                    left: 5,
                    child: OutlinedButton.icon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (canAdd != 1) {
                              return Colors.grey.withOpacity(0.8);
                            }
                            if (!states.contains(MaterialState.pressed))
                              return help.button.withOpacity(0.8);
                            return null; // Use the component's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        if (canAdd == 1) {
                          DateTime tomorrow;
                          TimeOfDay nowTime = TimeOfDay.now();
                          double currentTime = toDouble(nowTime);

                          double itemToTime1 =
                              double.parse(widget.toTime.split(':')[0]);
                          double itemToTime2 =
                              double.parse(widget.toTime.split(':')[1]);
                          double itemToTime = itemToTime1 + itemToTime2 / 60.0;

                          if (currentTime <= itemToTime) {
                            tomorrow = DateTime(now.year, now.month, now.day);
                          } else {
                            tomorrow =
                                DateTime(now.year, now.month, now.day + 1);
                          }
                          String msg;
                          if (CartData.dishes.length < 1) {
                            msg = "Showing " + widget.name + "'s food only";
                          } else {
                            msg = "Successfully Added";
                          }
                          Fluttertoast.showToast(
                              msg: msg,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Helper().button,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          CartData().addItem(
                              Dishes(
                                  widget.name,
                                  widget.chefAddress,
                                  widget.rating,
                                  widget.dishName,
                                  widget.self_delivery,
                                  widget.price,
                                  widget.image,
                                  widget.time,
                                  widget.dishName,
                                  widget.count,
                                  widget.chefId,
                                  widget.toTime,
                                  widget.fromTime,
                                  DateFormat('dd MMM y')
                                      .format(tomorrow)
                                      .toString()),
                              itemCount);
                          Fluttertoast.showToast(
                              msg: "Showing " + widget.name + "'s food only",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Helper().button,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          widget.refresh();
                          checkCart_add();
                        }
                      },
                      label: Text(
                        "ADD",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(
                        Icons.delivery_dining,
                        size: totalHeight * 30 / 700,
                        color: Colors.white,
                      ),
                    )),
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      widget.time,
                      style: TextStyle(
                          fontSize: totalHeight * 12 / 700,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.all(4.0),
                  ),
                )
              ])
            ]),
      ),
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
}
