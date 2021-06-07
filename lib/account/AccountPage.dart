import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/user/Start.dart';
import 'package:food_delivery_app/user/Utils.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:food_delivery_app/account/app_colors.dart';
import 'package:food_delivery_app/account/ui_helper.dart';
import 'package:food_delivery_app/account/custom_divider_view.dart';
import 'package:food_delivery_app/account/dotted_seperator_view.dart';
import 'package:food_delivery_app/auth_screens/sign_in.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
String phone = user.phoneNumber;

class AccountScreen extends StatelessWidget {
  final List<String> titles = [
    'My Account',
    'Food App SUPER',
    'Food App Money',
    'Help',
  ];
  final List<String> body = [
    'Address, Payments, Favourties, Referrals & Offers',
    'You had a great savings run. Get SUPER again',
    'Balance & Transactions',
    'FAQ & Links',
  ];

  @override
  Widget build(BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height;
    String name = "";
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('User').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      if (phone == snapshot.data.docs[i]['phoneNum']) {
                        String fname = snapshot.data.docs[i]['fname'];
                        String lname = snapshot.data.docs[i]['lname'];
                        name = fname + " " + lname;
                        break;
                      }
                    }
                  }
                  return _AppBar(name: name.toUpperCase());
                },
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: titles.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => _ListItem(
                  title: titles[index],
                  body: body[index],
                  isLastItem: (titles.length - 1) == index,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15.0),
                height: totalHeight * 50.0 / 820,
                color: Colors.grey[200],
                child: Text(
                  'ONGOING ORDERS',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Colors.grey[700],
                      fontSize: totalHeight * 14.0 / 820,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _PastOrderListView(ongoing: true),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 10, left: 15.0),
                height: totalHeight * 50.0 / 820,
                color: Colors.grey[200],
                child: Text(
                  'PAST ORDERS',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Colors.grey[700],
                      fontSize: totalHeight * 14.0 / 820,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _PastOrderListView(ongoing: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatefulWidget {
  final String name;
  _AppBar({Key key, @required this.name}) : super(key: key);

  @override
  __AppBarState createState() => __AppBarState();
}

class __AppBarState extends State<_AppBar> {
  @override
  Widget build(BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height;
    final subtitleStyle = Theme.of(context).textTheme.bodyText1;
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.name,
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: totalHeight * 18.0 / 820,
                    ),
              ),
            ],
          ),
          UIHelper.verticalSpaceSmall(),
          Row(
            children: <Widget>[
              Text(phone, style: subtitleStyle),
              UIHelper.horizontalSpaceSmall(),
              ClipOval(
                child: Container(
                  height: totalHeight * 3.0 / 820,
                  width: totalHeight * 3.0 / 820,
                  color: Colors.grey[700],
                ),
              ),
              UIHelper.horizontalSpaceSmall(),
            ],
          ),
          UIHelper.verticalSpaceLarge(),
          CustomDividerView(
            dividerHeight: totalHeight * 1.8 / 820,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    Key key,
    @required this.title,
    @required this.body,
    this.isLastItem = false,
  })  : assert(title != '', body != ''),
        super(key: key);

  final String title;
  final String body;
  final bool isLastItem;

  @override
  Widget build(BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: totalHeight * 15.0 / 820),
                    ),
                    UIHelper.verticalSpaceExtraSmall(),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: totalHeight * 13.0 / 820,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Spacer(),
              UIHelper.horizontalSpaceSmall(),
              Icon(Icons.keyboard_arrow_right)
            ],
          ),
          UIHelper.verticalSpaceLarge(),
          isLastItem
              ? SizedBox()
              : CustomDividerView(
                  dividerHeight: totalHeight * 0.8 / 820,
                  color: Colors.black26,
                ),
        ],
      ),
    );
  }
}

class _PastOrderListView extends StatefulWidget {
  bool ongoing;
  _PastOrderListView({@required this.ongoing});
  @override
  __PastOrderListViewState createState() => __PastOrderListViewState();
}

class __PastOrderListViewState extends State<_PastOrderListView> {
  final db = FirebaseFirestore.instance;
  List<String> dishNameOrder = [],
      quantityOrder = [],
      chefNameOrder = [],
      costOrder = [],
      timeOrder = [],
      foods = [],
      docIdOrder = [],
      rated = [],
      l2 = [];

  List<bool> isDeliveredOrder = [];
  bool visibility = false;

  Map chefs = {};

  @override
  void initState() {
    super.initState();
    visibility = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getChefName(String chefId) {
    String cname = '';
    var b = StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Chef').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            if (chefId == snapshot.data.docs[i]['chefId']) {
              cname = snapshot.data.docs[i]['fname' + ' ' + 'lname'];
            }
          }
        }
        return Container();
      },
    );
    return cname;
  }

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<QuerySnapshot>(
                stream: db.collection('Chef').snapshots(),
                builder: (context, snapshot2) {
                  if (snapshot2.hasData) {
                    chefs = {};
                    for (int i = 0; i < snapshot2.data.docs.length; i++) {
                      chefs[snapshot2.data.docs[i].id] =
                          snapshot2.data.docs[i].data();
                    }
                    dishNameOrder.clear();
                    quantityOrder.clear();
                    chefNameOrder.clear();
                    costOrder.clear();
                    timeOrder.clear();
                    foods.clear();

                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      var chef_detail = chefs[snapshot.data.docs[i]["chefId"]];
                      bool isDelOrder = false;
                      var dd = snapshot.data.docs[i];
                      bool flag = true;
                      for (int j = 0; j < dd["isDelivered"].length; j++) {
                        if (dd["isDelivered"][j] == false) {
                          flag = false;
                          break;
                        }
                      }
                      if (flag == true) {
                        isDelOrder = true;
                      } else {
                        isDelOrder = false;
                        flag = true;
                      }

                      if (user.uid == snapshot.data.docs[i]['userId']) {
                        if (widget.ongoing != isDelOrder) {
                          FirebaseFirestore.instance
                              .collection('Orders')
                              .get()
                              .then(
                                (QuerySnapshot snapshot) => {
                                  snapshot.docs.forEach(
                                    (f) {
                                      docIdOrder.add(f.reference.id.toString());
                                    },
                                  ),
                                },
                              );
                          if (dd['rating'] == 0.0 || dd['rating'] == null) {
                            rated.add("false");
                          } else {
                            rated.add("true");
                          }
                          dishNameOrder.add(dd['dishName'].toString());
                          quantityOrder.add(dd['quantity'].toString());
                          chefNameOrder.add(
                            chef_detail["fname"].toString(),
                          );
                          costOrder.add(dd['totalCost'].toString());
                          timeOrder.add(dd['timeOrderPlaced'].toString());
                          foods.add(
                              '${dishNameOrder[dishNameOrder.length - 1]} x ${quantityOrder[quantityOrder.length - 1]}');
                        }
                      }
                      // print('onging = ${widget.ongoing}');
                      // print('dno=$dishNameOrder');
                      // print('qno=$quantityOrder');
                      // print('chefno=$chefNameOrder');
                      // print('costno=$costOrder');
                      // print('tno=$timeOrder');
                      Set<String> set = new Set<String>.from(docIdOrder);
                      l2 = new List<String>.from(set);
                    }
                  }
                  return Container();
                },
              );
            }
            return Container();
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: timeOrder.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _PastOrdersListItemView(
              docIdOrder: l2,
              ongoing: widget.ongoing,
              chefNameOrder: chefNameOrder[index],
              costOrder: costOrder[index],
              timeOrder: timeOrder[index],
              foodItem: foods[index],
              rated: rated[index]),
        ),
        if (widget.ongoing && visibility == false)
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: totalWidth * 1.5 / 320, color: Colors.deepOrange),
              ),
              child: Text(
                ' VIEW ONGOING ORDERS',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: darkOrange),
              ),
              onPressed: () {
                setState(() {
                  visibility = true;
                });
              },
            ),
          ),
        if (!(widget.ongoing) && visibility == false)
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    width: totalWidth * 1.5 / 320, color: Colors.deepOrange),
              ),
              child: Text(
                ' VIEW PAST ORDERS',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: darkOrange),
              ),
              onPressed: () {
                setState(() {
                  visibility = true;
                });
              },
            ),
          ),
        UIHelper.verticalSpaceSmall(),
        CustomDividerView(),
        if (widget.ongoing == false)
          InkWell(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  ModalRoute.withName("/signin"));
            },
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10.0),
                  height: totalHeight * 50.0 / 820,
                  child: Text(
                    'LOGOUT',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(fontSize: totalHeight * 16.0 / 820),
                  ),
                ),
                Spacer(),
                new IconButton(
                  icon: Icon(Icons.power_settings_new),
                  color: Colors.black,
                  onPressed: () {},
                ),
                // Icon(Icons.power_settings_new),
                UIHelper.horizontalSpaceSmall(),
              ],
            ),
          ),
        if (widget.ongoing == false)
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 20.0),
            height: totalHeight * 130.0 / 820,
            color: Colors.grey[200],
            child: Text(
              'Food App Version v1.0.0',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.grey[700], fontSize: 13.0),
            ),
          )
      ],
    );
  }
}

class _PastOrdersListItemView extends StatefulWidget {
  const _PastOrdersListItemView({
    Key key,
    @required this.docIdOrder,
    @required this.ongoing,
    @required this.rated,
    @required this.chefNameOrder,
    @required this.foodItem,
    @required this.timeOrder,
    @required this.costOrder,
  })  : assert(foodItem != ''),
        super(key: key);
  final String foodItem;
  final chefNameOrder;
  final costOrder;
  final timeOrder;
  final ongoing;
  final rated;
  final docIdOrder;

  @override
  __PastOrdersListItemViewState createState() =>
      __PastOrdersListItemViewState();
}

class __PastOrdersListItemViewState extends State<_PastOrdersListItemView> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('sent_food=${widget.foodItem}');
    String tempFood = widget.foodItem.split('] x [')[0].split('[')[1];
    String tempQuantity = widget.foodItem.split('] x [')[1].split(']')[0];
    List<String> foodList = tempFood.split(', ');
    List<String> quantityList = tempQuantity.split(', ');
    String food = '';
    for (int i = 0; i < foodList.length; i++) {
      food += '${foodList[i]} x ${quantityList[i]}';
      food += '\n';
    }
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Chef ${widget.chefNameOrder}',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    UIHelper.verticalSpaceSmall(),
                    Row(
                      children: <Widget>[
                        Text('Rs. ${widget.costOrder}'),
                        UIHelper.horizontalSpaceExtraSmall(),
                        Icon(Icons.keyboard_arrow_right,
                            color: Colors.grey[600])
                      ],
                    )
                  ],
                ),
                Spacer(),
                if (!widget.ongoing)
                  Text('Delivered',
                      style: Theme.of(context).textTheme.subtitle2),
                if (!widget.ongoing) UIHelper.horizontalSpaceSmall(),
                if (!widget.ongoing)
                  ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(2.2),
                      color: Colors.green,
                      child: Icon(Icons.check,
                          color: Colors.white, size: totalHeight * 14.0 / 820),
                    ),
                  ),
                if (widget.ongoing)
                  Text('On the way',
                      style: Theme.of(context).textTheme.subtitle2),
                if (widget.ongoing) Icon(Icons.delivery_dining)
              ],
            ),
          ),
          UIHelper.verticalSpaceSmall(),
          DottedSeperatorView(),
          UIHelper.verticalSpaceMedium(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Order Placed At: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.timeOrder)
                ],
              ),
              Text(
                '\nFood Items Ordered:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              UIHelper.verticalSpaceExtraSmall(),
              Text(food),
              // Text(temp3.toString()),
              UIHelper.verticalSpaceExtraSmall(),
              UIHelper.verticalSpaceSmall(),
              if (widget.ongoing == false && widget.rated == "false")
                Center(
                  child: RatingPage(
                      docIdOrder: widget.docIdOrder,
                      costOrder: widget.costOrder,
                      timeOrder: widget.timeOrder),
                ),
              if (widget.ongoing == false && widget.rated == "true")
                Center(
                  child: AlreadyRatedPage(),
                ),
              UIHelper.verticalSpaceMedium(),
              CustomDividerView(
                  dividerHeight: totalHeight * 1.5 / 820, color: Colors.black)
            ],
          )
        ],
      ),
    );
  }
}

class AlreadyRatedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side:
            BorderSide(width: totalWidth * 1.5 / 320, color: Colors.deepOrange),
      ),
      child: Text(
        'You have already rated this order',
        style:
            Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.black),
      ),
      onPressed: () {},
    );
  }
}

class RatingPage extends StatefulWidget {
  final docIdOrder;
  final costOrder, timeOrder;
  RatingPage(
      {@required this.docIdOrder,
      @required this.costOrder,
      @required this.timeOrder});
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  @override
  void initState() {
    super.initState();
    print('doc=${widget.docIdOrder}');
    print('costdoc=${widget.costOrder}');
    print('timedoc=${widget.timeOrder}');
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _rating;
  String selectedId;
  TextEditingController feedbackController = new TextEditingController();
  String feedbackOut;
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Column(children: <Widget>[
      RatingBar.builder(
        initialRating: 5,
        direction: Axis.horizontal,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: totalWidth * 4.0 / 320),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return Container();
          }
        },
        onRatingUpdate: (rating) {
          setState(() {
            _rating = rating;
          });
        },
        updateOnDrag: true,
      ),
      TextFormField(
          controller: feedbackController,
          autovalidateMode: AutovalidateMode.always,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'What did you like/dislike about the food?',
            labelText: 'Feedback',
          ),
          onFieldSubmitted: (feedback) {
            feedback = feedbackController.text;
            print("feedback=$feedback");
            print("ratings=$_rating");
            Fluttertoast.showToast(
                msg: "Thank you for your feedback 😃",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Helper().button,
                textColor: Colors.white,
                fontSize: totalHeight * 16.0 / 820);
            setState(() {
              feedbackOut = feedback;
            });
          }),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              if (user.uid == snapshot.data.docs[i]['userId'].toString()) {
                selectedId = widget.docIdOrder[i];
                if (_rating == null) {
                  _rating = 0.0;
                }
                FirebaseFirestore.instance
                    .collection('Orders')
                    .doc(selectedId)
                    .update({
                  "rating": _rating.toDouble(),
                  "feedback": feedbackOut.toString()
                }).then((result) {
                  print("Updated Rating");
                }).catchError((onError) {
                  print("error");
                });
              }
            }
          }
          return Container();
        },
      )
    ]);
  }
}
