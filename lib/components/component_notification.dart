import 'package:flutter/material.dart';

class ComponentNotification extends StatelessWidget {

  final int notification;

  const ComponentNotification({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text('$notification', style: const TextStyle(color: Colors.white, fontSize: 18),),
        ),
      ),
    );
  }
}
