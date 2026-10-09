import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/screens/screens.dart';

futureError({required String title, required String content}) {
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: whiteColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          content,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    ),
  );
}

futureDisplayError({required String content}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(LottieAssets.error, frameRate: const FrameRate(100)),
        Text(
          "Error",
          style: TextStyle(
            color: blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          content,
          style: TextStyle(color: blackColor, fontSize: 14),
        ),
      ],
    ),
  );
}

noDataError() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(LottieAssets.notFound, height: 200, width: 200),
        const Text(
          "Sorry! No Data Found",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

futureNetworkError() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(LottieAssets.error,
            height: 150, width: 150, frameRate: const FrameRate(100)),
        Text(
          "Network Error",
          style: TextStyle(
            color: blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Please check your network",
          style: TextStyle(color: blackColor, fontSize: 14),
        ),
      ],
    ),
  );
}
