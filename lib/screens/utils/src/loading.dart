import 'package:flutter/material.dart';
import '/screens/screens.dart';

futureLoading(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
          ),
          child: CircularProgressIndicator(
            color: redColor,
          ),
        ),
      ),
    ),
  );
}

futureWaitingLoading() {
  return Center(
    child: CircularProgressIndicator(
      color: redColor,
    ),
  );
}
