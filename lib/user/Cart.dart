import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:food_delivery_app/user/Chefdata.dart';
import 'package:food_delivery_app/user/EmptyCart.dart';
import 'package:food_delivery_app/user/Utils.dart';
import 'package:food_delivery_app/user/Menucard.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final User user = auth.currentUser;
String userName;

class FoodOrderPage extends StatefulWidget {
  final String address;
  Function refreshCartNumber;
  FoodOrderPage({Key key, this.address, this.refreshCartNumber})
      : super(key: key);
  @override
  _FoodOrderPageState createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  int counter = 3;
  List<SingleCartItem> dishes;
  Helper help = new Helper();
  dynamic totalCost = 0;
  int count = 0;
  // int page_refresher = 1;

  @override
  void initState() {
    dishes = CartData().getItem();
    dishes.where((element) => element.quantity != 0);
    print(dishes);
    totalCost = CartData().calculateTotal(dishes);
    super.initState();
  }

  void deleteItem(int quantity) => {
        setState(() {
          quantity = 0;
        })
      };

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Helper().background,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "Item Carts",
            style:
                TextStyle(color: Helper().heading, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: dishes.length > 0
          ? SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('User')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          for (int i = 0; i < snapshot.data.docs.length; i++) {
                            if (user.phoneNumber ==
                                snapshot.data.docs[i]['phoneNum']) {
                              String fname = snapshot.data.docs[i]['fname'];
                              String lname = snapshot.data.docs[i]['lname'];
                              userName = fname + " " + lname;
                              print("name = $userName");
                              break;
                            }
                          }
                        }
                        return Container();
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Your Food Cart",
                            style: TextStyle(
                                fontSize: totalHeight * 20 / 700,
                                color: Helper().heading,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: totalWidth * 100 / 420,
                        ),
                        InkWell(
                          onTap: () {
                            CartData.dishes.clear();
                            Fluttertoast.showToast(
                                msg: "Emptied Cart Successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Helper().button,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            setState(() {
                              dishes = [];
                              count = CartData.dishes.length;
                              widget.refreshCartNumber();
                              refresher_funct();
                            });
                          },
                          child: Container(
                            width: totalWidth * 100 / 420,
                            height: totalHeight * 35 / 700,
                            decoration: BoxDecoration(
                              color: Helper().button,
                              // border: Border.all(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Center(
                              child: Text(
                                'Empty Cart',
                                style: new TextStyle(
                                    fontSize: totalHeight * 12 / 700,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: totalHeight * 10 / 700,
                    ),
                    ListView(
                        shrinkWrap: true,
                        children: dishes.map((data) {
                          // print(data);

                          return CartItem(
                              productName: data.dish.getDishName(),
                              productPrice: data.dish.getPrice().toString(),
                              productImage: data.dish.getimage(),
                              productCartQuantity: data.quantity.toString(),
                              toTime: data.dish.getToTime(),
                              fromTime: data.dish.getFromTime(),
                              selectedDate: data.dish.getSelectedDate(),
                              delItem: () {
                                setState(() => {
                                      dishes.removeWhere((element) =>
                                          element.dish.getDishName() ==
                                              data.dish.getDishName() &&
                                          element.dish.name == data.dish.name),
                                    });

                                totalCost = CartData().calculateTotal(dishes);
                                widget.refreshCartNumber();
                                print(data.dish.getDishName());
                              },
                              deliveryTime: data.dish.gettime(),
                              addItem: () {
                                setState(() => {
                                      data.quantity = Helper().addQuantity(
                                        data.quantity,
                                      )
                                    });
                              },
                              removeItem: () {
                                setState(() => {
                                      data.quantity = Helper().delQuantity(
                                        data.quantity,
                                      )
                                    });
                              },
                              updateCost: () {
                                setState(() {
                                  totalCost = CartData().calculateTotal(dishes);
                                });
                              });
                        }).toList()),
                    PromoCodeWidget(),
                    SizedBox(
                      height: totalHeight * 10 / 700,
                    ),
                    TotalCalculationWidget(totalCost),
                    SizedBox(
                      height: totalHeight * 10 / 700,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Payment Method",
                        style: TextStyle(
                            fontSize: totalHeight * 20 / 700,
                            color: Color(0xFF3a3a3b),
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: totalHeight * 10 / 700,
                    ),
                    PaymentMethodWidget(),
                    SizedBox(
                      height: totalHeight * 5 / 700,
                    ),
                    addressWidget(totalWidth, totalHeight, widget.address),
                    SizedBox(
                      height: totalHeight * 5 / 700,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            totalWidth * 0.2,
                            totalHeight * 0.02,
                            totalWidth * 0.2,
                            totalHeight * 0.02),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              uploadOrderToFirebase(dishes, widget.address);
                              CartData.dishes.clear();
                              refresher_funct();
                            },
                            child: Text(
                              'Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: totalWidth * 0.06),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                primary: Color(0xFFFF785B)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : EmptyShoppingCartScreen(),
    );
  }

  Widget addressWidget(double totalWidth, double totalHeight, String address) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Icon(Icons.home),
          SizedBox(width: totalWidth * 0.01),
          Text("Delivery Location:",
              style: TextStyle(
                  fontSize: totalHeight * 18 / 700,
                  fontFamily: "Robonto",
                  fontWeight: FontWeight.bold)),
        ],
      ),
      Text(
        address,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        style: TextStyle(
          color: Colors.black,
          fontSize: totalHeight * 15 / 700,
        ),
      ),
    ]);
  }

  final orders = FirebaseFirestore.instance.collection('Orders');

  void uploadOrderToFirebase(List<SingleCartItem> dishes, String address) {
    addOrder(dishes);
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "Success",
        description: "Order Placed Successfully ! Delicious Food en route",
        buttonText: "Okay",
        address: address,
      ),
    );
  }

  void refresher_funct() {
    // (context as Element).reassemble();
    print("ssssssssssssssssssssssssssssssssssssssssss");
    // print()
    if (CartData.dishes.isNotEmpty)
      Fluttertoast.showToast(
          msg: "Emptying Cart",
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

  Future<void> addOrder(List<SingleCartItem> dishes) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMM y kk:mm').format(now);
    // DateTime selectedDate = new DateTime(now.year, now.month, now.day);
    // String dateToBeDelivered =
    //     DateFormat('dd MMM y').format(widget.selectedDate).toString();
    String phone = user.phoneNumber;
    List<String> productName = [],
        deliveryTime = [],
        productPrice = [],
        productCartQuantity = [],
        toTimeList = [],
        fromTimeList = [],
        dateToBeDelivered = [];

    List<bool> self_delivery = [], isDelivered = [];

    String chefId = "";
    String chefAddress = "";
    double totalCost;
    print("dishes = $dishes");

    List order = dishes.map((data) {
      productName.add(data.dish.getDishName());
      productPrice.add(data.dish.getPrice().toString());
      productCartQuantity.add(data.quantity.toString());
      deliveryTime.add(data.dish.gettime());
      toTimeList.add(data.dish.getToTime());
      fromTimeList.add(data.dish.getFromTime());
      dateToBeDelivered.add(data.dish.getSelectedDate());
      self_delivery.add(data.dish.getSelfDelivery());
      isDelivered.add(false);
      chefId = data.dish.getChefId();
      chefAddress = data.dish.chefAddress;
      totalCost = CartData().calculateGrandTotal();
    }).toList();

    // for (int i = 0; i < dishes.length; i++)
    // print(
    //     "Order = $productName $productPrice $productCartQuantity $deliveryTime $totalCost\n");
    // Future<String> userName;
    // userName = getUserName(phone);

    return orders
        .add({
          "dishName": productName,
          "pricePerServing": productPrice,
          "quantity": productCartQuantity,
          "totalCost": totalCost,
          "isDelivered": isDelivered,
          "timeOrderPlaced": formattedDate,
          "address": widget.address,
          "toTime": toTimeList,
          "fromTime": fromTimeList,
          "dateToBeDelivered": dateToBeDelivered,
          "chefId": chefId,
          "chefAddress": chefAddress,
          "self_delivery": self_delivery,
          "userId": user.uid,
          "userName": userName,
          "userPhone": phone,
          "rating": 0.0,
          "feedback": "".toString()
        })
        .then(
          (value) => print("Order Uploaded on Firestore"),
        )
        .catchError(
          (error) => print("Failed to add Order: $error"),
        );
  }
}

class CustomDialog extends StatelessWidget {
  static const double padding = 4.0;
  static const double avatarRadius = 11.0;
  final String title, description, buttonText;
  String address;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.address,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, address),
    );
  }

  dialogContent(BuildContext context, String address) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: avatarRadius + padding,
            bottom: padding,
            left: padding,
            right: padding,
          ),
          margin: EdgeInsets.only(top: avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 10.0,
                offset: const Offset(0.0, 0.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: totalHeight * 5.0 / 100,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: totalHeight * 10.0 / 100),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: totalHeight * 3.0 / 100,
                ),
              ),
              SizedBox(height: totalHeight * 10.0 / 100),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MenuOptionSide(automatic: false, address: address),
                      ),
                    );
                  },
                  child: Text(buttonText.toString()),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: padding,
          right: padding,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: avatarRadius,
            child: Text(
              "",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentMethodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: totalHeight * 60 / 700,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: totalWidth * 10 / 420,
              right: totalWidth * 30 / 420,
              top: totalHeight * 10 / 700,
              bottom: totalHeight * 10 / 700),
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Icon(Icons.credit_card),
              ),
              Text(
                "Credit/Debit Card",
                style: TextStyle(
                    fontSize: totalHeight * 16 / 700,
                    color: Color(0xFF3a3a3b),
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TotalCalculationWidget extends StatefulWidget {
  double totalCost;
  TotalCalculationWidget(this.totalCost);
  @override
  _TotalCalculationWidgetState createState() => _TotalCalculationWidgetState();
}

class _TotalCalculationWidgetState extends State<TotalCalculationWidget> {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: totalHeight * 150 / 700,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: totalWidth * 25 / 420,
              right: totalWidth * 30 / 420,
              top: totalHeight * 10 / 700,
              bottom: totalHeight * 10 / 700),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: totalHeight * 15 / 700,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Item Total",
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    widget.totalCost.toString(),
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  )
                ],
              ),
              SizedBox(
                height: totalHeight * 15 / 700,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Delivery Charge",
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "50Rs",
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  )
                ],
              ),
              SizedBox(
                height: totalHeight * 15 / 700,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Grand Total",
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    CartData().calculateGrandTotal().toString(),
                    style: TextStyle(
                        fontSize: totalHeight * 18 / 700,
                        color: Color(0xFF3a3a3b),
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoCodeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
            left: totalWidth * 3 / 420, right: totalWidth * 3 / 420),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color(0xFFfae3e2).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ]),
        child: TextFormField(
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFe6e1e1), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFe6e1e1), width: 1.0),
                  borderRadius: BorderRadius.circular(7)),
              fillColor: Colors.white,
              hintText: 'Add Your Promo Code',
              filled: true,
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.local_offer,
                    color: Color(0xFFfd2c2c),
                  ),
                  onPressed: () {
                    debugPrint('222');
                  })),
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  String productName;
  String productPrice;
  String productImage;
  String productCartQuantity;
  String deliveryTime;
  String toTime;
  String fromTime;
  String selectedDate;
  Function delItem;
  Function updateCost, addItem, removeItem;
  CartItem(
      {Key key,
      @required this.productName,
      @required this.productPrice,
      @required this.productImage,
      @required this.productCartQuantity,
      @required this.delItem,
      @required this.deliveryTime,
      @required this.toTime,
      @required this.fromTime,
      @required this.selectedDate,
      @required this.updateCost,
      @required this.addItem,
      @required this.removeItem})
      : super(key: key);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    print('selectedDate = ${widget.selectedDate}');
    return Card(
        color: Helper().card,
        // color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Padding(
          // alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: totalWidth * 10 / 420,
              right: totalWidth * 10 / 420,
              top: totalHeight * 10 / 700,
              bottom: totalHeight * 10 / 700),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                        widget.productImage,
                      ),
                      fit: BoxFit.cover),
                ),
                height: totalHeight * 80 / 700,
                width: totalWidth * 120 / 420,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${widget.productName}",
                              style: TextStyle(
                                  fontSize: totalHeight * 16 / 700,
                                  color: Helper().heading,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              widget.deliveryTime != '0'
                                  ? "${widget.productPrice}"
                                  : "Subscription",
                              style: TextStyle(
                                  fontSize: totalHeight * 12 / 700,
                                  color: Helper().normalText,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "Delivered On ${widget.selectedDate.split(' 20')[0]}\nBetween ${widget.fromTime}-${widget.toTime}",
                              style: TextStyle(
                                  fontSize: totalHeight * 12 / 700,
                                  color: Helper().normalText,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: totalWidth * 30 / 420,
                        ),
                        Container(
                          // alignment: Alignment.centerRight,
                          child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => {widget.delItem()}),
                        )
                      ],
                    ),
                    widget.deliveryTime != '0'
                        ? Container(
                            alignment: Alignment.centerRight,
                            child: AddToCartMenu(
                                int.parse(widget.productCartQuantity),
                                widget.updateCost,
                                widget.addItem,
                                widget.removeItem),
                          )
                        : new Container(width: 0.0, height: 0.0)
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class CartIconWithBadge extends StatelessWidget {
  int counter = 3;

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.business_center,
              color: Color(0xFF3a3737),
            ),
            onPressed: () {}),
        counter != 0
            ? Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: totalWidth * 14 / 700,
                    minHeight: totalHeight * 14 / 700,
                  ),
                  child: Text(
                    '$counter',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: totalHeight * 8 / 700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}

class AddToCartMenu extends StatefulWidget {
  int productCounter;
  Function updateCost, addItem, removeItem;
  AddToCartMenu(
      this.productCounter, this.updateCost, this.addItem, this.removeItem);

  @override
  _AddToCartMenuState createState() => _AddToCartMenuState();
}

class _AddToCartMenuState extends State<AddToCartMenu> {
  Helper helper = new Helper();

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery.of(context).size.width;
    double totalHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () => {
              setState(
                () => {
                  widget.removeItem(),
                  widget.updateCost(),
                },
              )
            },
            icon: Icon(Icons.remove_circle),
            color: Helper().button,
            iconSize: totalHeight * 28 / 700,
          ),
          InkWell(
            onTap: () => print('hello'),
            child: Container(
              width: totalWidth * 60 / 420,
              height: totalHeight * 35 / 700,
              decoration: BoxDecoration(
                color: Helper().button,
                // border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Text(
                  'Add To ${widget.productCounter}',
                  style: new TextStyle(
                      fontSize: totalHeight * 12 / 700,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Fluttertoast.showToast(
                  msg: "Only deletion is allowed in cart",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Helper().button,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            icon: Icon(Icons.add_circle),
            color: Colors.grey,
            iconSize: totalHeight * 28 / 700,
          ),
        ],
      ),
    );
  }
}
