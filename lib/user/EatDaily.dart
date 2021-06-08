import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/user/Utils.dart';
import '../user/Chefdata.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

final now = new DateTime.now();
final tomorrow = DateTime(now.year, now.month, now.day + 1);

class EatTomorrow extends StatefulWidget {
  CartData cartData;
  Function refreshCartNumber;
  EatTomorrow({this.refreshCartNumber});
  @override
  _EatTomorrowState createState() => _EatTomorrowState();
}

class _EatTomorrowState extends State<EatTomorrow> {
  EatNowData items = new EatNowData();
  List<Dishes> l;
  CartData cartdata;
  Map ll;
  final db = FirebaseFirestore.instance;
  Map timetable = {7: "Breakfast", 12: "Lunch", 17: "Dinner"};
  List<Dishes> dishes = [];
  Map chefs = {};

  String tellMeType(int p) {
    if (p >= 7 && p <= 12) {
      return "Breakfast";
    } else if (p > 12 && p <= 17) {
      return "Lunch";
    } else {
      return "Dinner";
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

  @override
  void initState() {
    super.initState();
    this.l = items.getData();
    this.cartdata = widget.cartData;
  }

  @override
  Widget build(BuildContext context) {
    int count_dish;
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 248, 1),
      body: ListView(children: [
        StreamBuilder<QuerySnapshot>(
          stream: db.collection('Food_items').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<QuerySnapshot>(
                stream: db.collection('Chef').snapshots(),
                builder: (context, snapshot2) {
                  if (snapshot2.hasData) {
                    chefs = {};
                    for (int i = 0; i < snapshot2.data.docs.length; i++) {
                      // print(snapshot2.data.docs[i].data());
                      chefs[snapshot2.data.docs[i].id] =
                          snapshot2.data.docs[i].data();
                    }
                    // print(chefs);
                    dishes = [];
                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      final now = new DateTime.now();

                      var tmprser = new DateFormat("dd-MM-yyyy HH:mm");
                      var tmprser2 = new DateFormat("dd-MM-yyyy");
                      print("\t" +
                          tmprser
                              .parse(snapshot.data.docs[i]["fromDate"]
                                      .toString() +
                                  " " +
                                  snapshot.data.docs[i]["toTime"].toString())
                              .toString());
                      // var nextDate = tmprser.parse(
                      //     snapshot.data.docs[i]["fromDate"].toString() +
                      //         " " +
                      //         snapshot.data.docs[i]["toTime"].toString());
                      var checkTime = tmprser2
                          .parse(snapshot.data.docs[i]["fromDate"].toString())
                          .compareTo(tmprser2.parse(now.day.toString() +
                              "-" +
                              now.month.toString() +
                              "-" +
                              now.year.toString()));
                      // " " +
                      // now.hour.toString() +
                      // ":" +
                      // now.minute.toString()));
                      print("\n" + checkTime.toString());
                      if (checkTime > 0) {
                        // print("\n" + checkTime.toString());

                        var chef_detail =
                            chefs[snapshot.data.docs[i]["chefId"]];
                        // print(chef_detail);
                        var dd = snapshot.data.docs[i];
                        //Take the difference of the toTime of item from now
                        var leftTime = tmprser
                            .parse(
                                (snapshot.data.docs[i]["fromDate"].toString() +
                                    " " +
                                    snapshot.data.docs[i]["toTime"]
                                        .toString()
                                        .toString()))
                            .difference(tmprser.parse(now.day.toString() +
                                "-" +
                                now.month.toString() +
                                "-" +
                                now.year.toString() +
                                " " +
                                now.hour.toString() +
                                ":" +
                                now.minute.toString().toString()));
                        print("LeftTime" + leftTime.inMinutes.toString());
                        // var leftsecond_format =
                        //     new DateFormat("dd-MM-yyyy HH:mm")
                        //         .parse(leftTime.inHours.toString());
                        // var leftseconds = leftsecond_format.day * 24 * 60 +
                        //     leftsecond_format.hour * 60 +
                        //     leftsecond_format.minute;
                        var leftseconds = leftTime.inMinutes.toString();
                        // print(leftTime);
                        print("\n");
                        print(leftseconds);
                        if (chef_detail != null) {
                          // var toTime =
                          //     new DateFormat("HH:mm").parse(dd["toTime"]);
                          // print(toTime);
                          // var fromTime =
                          //     new DateFormat("HH:mm").parse(dd["fromTime"]);

                          // int remaining_time = (toTime.hour) * 60 +
                          //     toTime.minute -
                          //     (now.hour * 60 + now.minute);

                          // print(remaining_time.toString() + "ending");

                          Dishes dish = new Dishes(
                              chef_detail["fname"].toString(),
                              chef_detail["chefAddress"].toString(),
                              chef_detail["rating"].toDouble(),
                              dd["dishName"].toString(),
                              dd["self_delivery"],
                              dd["price"].toDouble(),
                              dd["imageUrl"].toString(),
                              "leftseconds".toString(),
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
                      print(ll);
                      if (CartData.dishes.length == 0 ||
                          data.getChefId() ==
                              CartData.dishes[0].dish.getChefId()) {
                        print(ll);
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
                              this.cartdata,
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
    );
  }
}

class SingleCard extends StatefulWidget {
  String name, chefAddress, dishName, image, time, chefId, toTime, fromTime;
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
      this.chefId,
      this.toTime,
      this.fromTime,
      this.refresh);
  @override
  _SingleCardState createState() => _SingleCardState();
}

class _SingleCardState extends State<SingleCard> {
  Helper help = new Helper();

  int _counter;
  Timer _timer;
  var canAdd = 1;
  int canIncrease = 1;
  int itemCount = 1;

  // int hour = 0, minute = 0, sec = 0;

  // void _startTimer(int time) {
  //   _counter = time;
  //   if (_timer != null) {
  //     _timer.cancel();
  //   }
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setState(() {
  //       if (_counter > 0) {
  //         _counter--;
  //         // hour=_counter/
  //       } else {
  //         _timer.cancel();
  //         setState(() {
  //           canAdd = 0;
  //         });
  //       }
  //     });
  //   });
  // }

  void checkCart_add() {
    for (int i = 0; i < CartData.dishes.length; i++) {
      if (CartData.dishes.length != 0) {
        if ((CartData.dishes[i].dish.name != widget.name) ||
            (CartData.dishes[i].dish.getDishName() == widget.dishName &&
                CartData.dishes[i].dish.name == widget.name)) {
          setState(() {
            canAdd = 0;
          });
        }
      }

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
    // _startTimer(int.parse(widget.time) * 60);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();

    // canAdd=0;
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
                                    fontSize: 16.0, color: help.heading)),
                            Text('Rating ' + widget.rating.toString() + ' ⭐',
                                style: TextStyle(
                                    fontSize: 10.0,
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
                  right: 4,
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
                        if (canAdd == 1) {
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
              ])
            ]),
      ),
    );
  }
}
