import 'package:flutter/material.dart';
import '../providers/order.dart' as ord;
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/cart.dart';

class OrderItem extends StatefulWidget {

  final ord.OrderItem order;

  OrderItem({required this.order});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with SingleTickerProviderStateMixin{

  bool isExpanded = false;



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.blueGrey,
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: ListTile(
              title:Text("Total \$${widget.order.amount}", style: TextStyle(color: Colors.white),),
              subtitle: Text("${DateFormat("dd/MM/yyyy hh:mm").format(widget.order.time)}",style: TextStyle(color: Colors.white),),
              trailing: IconButton(
                icon: Icon(isExpanded? Icons.expand_less : Icons.expand_more),
                onPressed: (){
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                },
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isExpanded ? widget.order.products.length*85 : 0,
            child: Column(
                  children: widget.order.products.map((prodItem) => CardOfOrderItem(item: prodItem, isExpanded: isExpanded )).toList(),
              )
            ),
        ],
      ),
    );
  }
}

class CardOfOrderItem extends StatelessWidget {

  final CartItem item;
  bool isExpanded;

  CardOfOrderItem({required this.item,required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 290),
      height: isExpanded ? 82 : 0,
      child: Card(
        child: Container(
          margin: EdgeInsets.all(5),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: FittedBox(child: Text("\$${item.price}")),
              ),
            ),
            title: Text(item.title),
            subtitle: Text("Total \$${(item.quantity*item.price).toStringAsFixed(2)}"),
            trailing: Text("Q  ${item.quantity}")

          ),
        ),
      ),
    );
  }
}
