import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/user/Utils.dart';
import '../user/Chefdata.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EatNow extends StatefulWidget {
  CartData cartData;
  Function refreshCartNumber;
  EatNow({@required this.cartData, this.refreshCartNumber});
  @override
  _EatNowState createState() => _EatNowState();
}

class _EatNowState extends State<EatNow> {
  EatNowData items = new EatNowData();
  List<Dishes> l;
  CartData cartdata;
  Map ll;
  final db = FirebaseFirestore.instance;
  Map timetable = {7: "Breakfast", 12: "Lunch", 17: "Dinner"};
  int page_refresher = 1;
  Map chefs = {};
  List<Dishes> dishes = [];

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
                    print(chefs);
                    dishes = [];
                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      final now = new DateTime.now();

                      var timeparser = new DateFormat("HH:mm");

                      int checkTime = (timeparser
                                      .parse(snapshot.data.docs[i]['toTime'])
                                      .hour *
                                  60 +
                              timeparser
                                  .parse(snapshot.data.docs[i]['toTime'])
                                  .minute) -
                          (now.hour * 60 + now.minute);

                      if (snapshot.data.docs[i]['mealType'].toLowerCase() ==
                              this.tellMeType(now.hour).toLowerCase() &&
                          checkTime > 0) {
                        var chef_detail =
                            chefs[snapshot.data.docs[i]["chefId"]];
                        // print(chef_detail);
                        var dd = snapshot.data.docs[i];

                        //Take the difference of the toTime of item from now

                        var leftTime = timeparser
                            .parse(snapshot.data.docs[i]['toTime'])
                            .difference(timeparser.parse(now.hour.toString() +
                                ":" +
                                now.minute.toString()));

                        var leftseconds = new DateFormat("HH:mm:ss")
                                    .parse(leftTime.toString())
                                    .hour *
                                60 +
                            new DateFormat("HH:mm:ss")
                                .parse(leftTime.toString())
                                .minute;

                        Dishes dish = new Dishes(
                            chef_detail["fname"].toString(),
                            chef_detail["rating"].toDouble(),
                            dd["dishName"].toString(),
                            dd["price"].toDouble(),
                            dd["imageUrl"].toString(),
                            leftseconds.toString(),
                            dd["mealType"],
                            dd["count"],
                            dd["chefId"]);
                        dishes.add(dish);
                      }
                    }
                    print(dishes);

                    return Column(
                        children: dishes.map((data) {
                      if (CartData.dishes.length == 0 ||
                          data.getChefId().toString() ==
                              CartData.dishes[0].dish.getChefId().toString()) {
                        print(ll);

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleCard(
                              data.name,
                              data.rating,
                              data.getPrice(),
                              data.getDishName(),
                              data.getimage(),
                              data.gettime(),
                              1,
                              this.cartdata,
                              data.getChefId().toString(),
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
  String name, dishName, image, time, chefId;
  dynamic rating;
  int quantity, count;
  dynamic price;
  CartData cartData;
  Function refresh;
  SingleCard(this.name, this.rating, this.price, this.dishName, this.image,
      this.time, this.quantity, this.cartData, this.chefId, this.refresh);
  @override
  _SingleCardState createState() => _SingleCardState();
}

class _SingleCardState extends State<SingleCard> {
  Helper help = new Helper();

  int _counter;
  Timer _timer;
  var canAdd = 1;

  int hour = 0, minute = 0, sec = 0;

  void _startTimer(int time) {
    _counter = time;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
          // hour=_counter/
        } else {
          _timer.cancel();
          setState(() {
            canAdd = 0;
          });
        }
      });
    });
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
  void initState() {
    super.initState();
    // var total_remaining_time = int.parse(widget.time);
    checkCart_add();
    _startTimer(int.parse(widget.time) * 60);
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
                            child: Text(widget.quantity.toString(),
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
                          // Ink(
                          //   decoration: ShapeDecoration(
                          //     color: Colors.red,
                          //     shape: CircleBorder(),
                          //   ),
                          //   child: IconButton(
                          //   icon: Icon(
                          //     Icons.add,
                          //     color: Color.fromRGBO(232, 140, 48, 1),
                          //   ),
                          //   tooltip: 'Add',
                          //   onPressed: () => {
                          //     setState(() {
                          //       widget.quantity =
                          //           help.addQuantity(widget.quantity);
                          //       print(widget.quantity);
                          //     })
                          //   },
                          // ),
                          // ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: Helper().button,
                              size: totalHeight * 28 / 700,
                            ),
                            tooltip: 'Add',
                            onPressed: () => {
                              setState(() {
                                widget.quantity =
                                    help.addQuantity(widget.quantity);
                                print(widget.quantity);
                              })
                            },
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
                                widget.quantity =
                                    help.delQuantity(widget.quantity);
                                print(widget.quantity);
                              })
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
                          widget.cartData.addItem(
                              Dishes(
                                  widget.name,
                                  widget.rating,
                                  widget.dishName,
                                  widget.price,
                                  widget.image,
                                  widget.time,
                                  widget.dishName,
                                  widget.count,
                                  widget.chefId.toString()),
                              widget.quantity);
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
                      color: Colors.red.withOpacity(0.6),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      (_counter ~/ 3600).toString() +
                          ":" +
                          ((_counter % 3600) ~/ 60).toString() +
                          ":" +
                          ((_counter % 60)).toString(),
                      style: TextStyle(
                          fontSize: totalHeight * 12 / 700,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.all(4.0),
                  ),
                )
              ])
            ]),
      ),
      // child: Column(
      //   children: [
      //     ListTile(
      //       leading: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Icon(Icons.person),
      //       ),
      //       title: Text(name),
      //       subtitle: Text(
      //         'Rating ' + rating.toString() + ' ⭐',
      //         style: TextStyle(color: Colors.black.withOpacity(0.6)),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Text(
      //         dishName,
      //         style: TextStyle(color: Colors.black.withOpacity(1)),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.all(16.0),
      //       child: Image(
      //         image: AssetImage("assets/images/$image"),
      //       ),
      //     ),
      //     ButtonBar(
      //       alignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         ButtonBar(
      //           alignment: MainAxisAlignment.start,
      //           children: [
      //             Container(
      //               child: Text("5",
      //                   style: new TextStyle(
      //                       color: Colors.white, fontWeight: FontWeight.w900)),
      //               decoration: new BoxDecoration(
      //                   borderRadius:
      //                       new BorderRadius.all(new Radius.circular(10.0)),
      //                   color: Colors.grey),
      //               padding: new EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      //             ),
      //             ElevatedButton(
      //               onPressed: () {
      //                 // Perform some action
      //                 // f.getdata().map((e) => print(e.name));
      //               },
      //               style: ButtonStyle(
      //                   backgroundColor:
      //                       MaterialStateProperty.resolveWith<Color>(
      //                     (Set<MaterialState> states) {
      //                       if (states.contains(MaterialState.pressed))
      //                         return Colors.green;
      //                       return null; // Use the component's default.
      //                     },
      //                   ),
      //                   shape: MaterialStateProperty
      //                       .all<RoundedRectangleBorder>(RoundedRectangleBorder(
      //                           borderRadius: BorderRadius.circular(240.0),
      //                           side: BorderSide(color: Colors.transparent)))),
      //               child: Icon(Icons.add),
      //             ),
      //             ElevatedButton(
      //               onPressed: () {
      //                 // Perform some action
      //               },
      //               style: ButtonStyle(
      //                   shape: MaterialStateProperty
      //                       .all<RoundedRectangleBorder>(RoundedRectangleBorder(
      //                           borderRadius: BorderRadius.circular(140.0),
      //                           side: BorderSide(color: Colors.transparent)))),
      //               child: Icon(Icons.remove),
      //             ),
      //           ],
      //         ),
      //         ElevatedButton(
      //           onPressed: () {
      //             // Perform some action
      //           },
      //           style: ButtonStyle(
      //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //                   RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(140.0),
      //                       side: BorderSide(color: Colors.transparent)))),
      //           child: Icon(Icons.add_shopping_cart),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
