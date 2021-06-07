import 'package:flutter/material.dart';
import 'package:food_delivery_app/user/Utils.dart';
import '../user/Chefdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

final now = new DateTime.now();

class EatLater extends StatefulWidget {
  Function refreshCartNumber;
  EatLater({this.refreshCartNumber});
  @override
  _EatLaterState createState() => _EatLaterState();
}

class _EatLaterState extends State<EatLater> {
  EatNowData items = new EatNowData();
  List<Dishes> l;
  Map ll;
  final db = FirebaseFirestore.instance;
  List<Dishes> dishes = [];
  Map chef = {};

  Map timetable = {7: "Breakfast", 12: "Lunch", 17: "Dinner"};

  @override
  void initState() {
    super.initState();
    this.l = items.getData();
    l.map((e) => print(e.name));
  }

  String tellMeType(int p) {
    if (p >= 7 && p <= 12) {
      return "Lunch";
    } else if (p > 12 && p <= 17) {
      return "Dinner";
    } else {
      return "BreakFast";
    }
  }

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
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: new Helper().background,
      body: ListView(children: [
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
                      final now = new DateTime.now();

                      // var fmt = DateFormat("HH:mm");
                      // print(fmt.format(now));

                      // DateTime tempDate = new DateFormat("hh:mm")
                      //     .parse(snapshot.data.docs[i]['fromTime']);

                      // DateTime tempDate2 = new DateFormat("hh:mm")
                      //     .parse(snapshot.data.docs[i]['toTime']);

                      // String sort_key = "";

                      // int flag = 0;
                      // timetable.forEach((key, value) {
                      //   if (now.hour >= key && flag == 0) {
                      //     print(key);
                      //     sort_key = timetable[(key + 5) > 17 ? 17 : key + 5];
                      //     flag = 1;
                      //   }
                      // });
                      // print(sort_key);

                      // now.hour >= tempDate.hour &&
                      // now.hour <= tempDate2.hour &&

                      if (snapshot.data.docs[i]['mealType'].toLowerCase() ==
                          this.tellMeType(now.hour).toLowerCase()) {
                        var chef_detail = chef[snapshot.data.docs[i]["chefId"]];
                        // print(chef_detail);
                        var dd = snapshot.data.docs[i];
                        // if (snapshot.data.docs[i]['mealType'].toLowerCase() ==
                        //     "breakfast") {
                        //   tomorrow = DateTime(now.year, now.month, now.day + 1);
                        // } else {
                        //   tomorrow = DateTime(now.year, now.month, now.day + 1);
                        // }
                        if (chef_detail != null) {
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
                        children: dishes.map((data) {
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
                              "07:00",
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
                    }).toList());
                  } else {
                    return Container(
                      child: Center(
                        child: Text('Sorry....No Items are availble'),
                      ),
                    );
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

      // ListView(
      //   children: l.map((data) {
      //     return Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: SingleCard(data.name, data.rating, data.getDishName(),
      //           data.getimage(), '07:00', 1),
      //     );
      //   }).toList(),
      // ),
    );
  }
}

class SingleCard extends StatefulWidget {
  String name, chefAddress, dishName, image, time, chefId, toTime, fromTime;
  bool self_delivery;
  dynamic rating;
  int quantity, count;
  dynamic price;
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
      this.chefId,
      this.toTime,
      this.fromTime,
      this.refresh);
  @override
  _SingleCardState createState() => _SingleCardState();
}

class _SingleCardState extends State<SingleCard> {
  Helper help = new Helper();
  TimeOfDay _ttime = TimeOfDay(hour: 7, minute: 15);
  var canAdd = 1;
  var canIncrease = 1;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
    // var total_remaining_time = int.parse(widget.time);
    checkCart_add();
  }

  void _selectTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _ttime,
    );
    if (newTime != null) {
      setState(() {
        _ttime = newTime;
        widget.time = (_ttime.hour.toString() + ':' + _ttime.minute.toString())
            .toString();
      });
    }
  }

  void checkCart_add() {
    for (int i = 0; i < CartData.dishes.length; i++) {
      // if (CartData.dishes.length != 0) {
      //   if ((CartData.dishes[i].dish.name != widget.name) ||
      //       (CartData.dishes[i].dish.getDishName() == widget.dishName &&
      //           CartData.dishes[i].dish.name == widget.name)) {
      //     setState(() {
      //       canAdd = 0;
      //     });
      //   }
      // }

      if (CartData.dishes[i].dish.getDishName() == widget.dishName &&
          CartData.dishes[i].dish.name == widget.name) {
        setState(() {
          canAdd = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Card(
      color: help.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
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
                            Text(widget.name, style: TextStyle(fontSize: 16.0)),
                            Text('Rating ' + widget.rating.toString() + ' ⭐',
                                style: TextStyle(
                                    fontSize: totalHeight * 10 / 700,
                                    fontWeight: FontWeight.w300)),
                          ])
                    ],
                  ),
                  SizedBox(
                    height: totalHeight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      widget.dishName,
                      style: TextStyle(
                          color: help.heading, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: totalHeight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      widget.price.toString() + "₹ (per serve)",
                      style: TextStyle(
                          color: help.normalText, fontWeight: FontWeight.w100),
                    ),
                  ),
                  SizedBox(
                    height: totalHeight * 0.01,
                  ),
                  // Padding(
                  //     padding: const EdgeInsets.all(0.0),
                  //     child: OutlinedButton.icon(
                  //       style: ButtonStyle(
                  //         backgroundColor:
                  //             MaterialStateProperty.resolveWith<Color>(
                  //           (Set<MaterialState> states) {
                  //             if (!states.contains(MaterialState.pressed))
                  //               return help.button;
                  //             return null; // Use the component's default.
                  //           },
                  //         ),
                  //       ),
                  //       onPressed: _selectTime,
                  //       label: Text(
                  //         widget.time,
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold, color: Colors.white),
                  //       ),
                  //       icon: Icon(
                  //         Icons.timer_rounded,
                  //         size: totalHeight * 20 / 700,
                  //         color: Colors.white,
                  //       ),
                  //     )),
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
                                    new Radius.circular(10.0)),
                                color: help.button),
                            padding:
                                new EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
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
                  height: totalHeight * 1.3 / 7,
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
                // Text("Delivered Between\n${widget.fromTime}-${widget.toTime}",
                //     textAlign: TextAlign.right),
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.red.withOpacity(0.6),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      '${widget.fromTime}-${widget.toTime}',
                      style: TextStyle(
                          fontSize: totalHeight * 12 / 700,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.all(4.0),
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
                        // Respond to button press
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
                              msg: "Successfully Added",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Helper().button,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          checkCart_add();
                          widget.refresh();
                        }
                      },
                      label: Text(
                        "ADD +",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(
                        Icons.delivery_dining,
                        size: totalHeight * 30 / 700,
                        color: Colors.white,
                      ),
                    ))
              ])
            ]),
      ),
    );
  }

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
}
