import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/pdf/pdf.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/screens/screens.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: FutureBuilder(
        future: dashboardHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return futureWaitingLoading();
          } else if (snapshot.hasError) {
            if (snapshot.error == 'Network Error') {
              return futureNetworkError();
            } else {
              return futureDisplayError(content: snapshot.error.toString());
            }
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  dashboardHandler = getDashboard();
                });
              },
              child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (MediaQuery.of(context).size.width ~/ 150).toInt(),
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: dashboardList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Videos(
                                      heading: dashboardList[index].heading!,
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: blueLightColor,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.book_1,
                                    size: 30,
                                    color: blueDarkColor,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    dashboardList[index].heading!,
                                    style: TextStyle(
                                      color: blueDarkColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Videos(
                                                heading: dashboardList[index]
                                                    .heading!,
                                              )));
                                },
                                icon: Icon(
                                  Iconsax.arrow_circle_right,
                                  color: redDarkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
        },
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back_ios_new_rounded, color: whiteColor),
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
      iconTheme: IconThemeData(color: whiteColor),
      backgroundColor: redColor,
      title: Text(
        "Dashboard",
        style: TextStyle(color: whiteColor),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.book,
            color: Colors.white,
          ),
          onPressed: () => Navigator.push(
              context, CupertinoPageRoute(builder: (context) => const Pdf())),
        ),
        IconButton(
            onPressed: () {
              showMenuSheet();
            },
            icon: const Icon(Iconsax.menu)),
      ],
    );
  }

  Future? dashboardHandler;
  List<DashboardModel> dashboardList = [];

  Future getDashboard() async {
    setState(() {
      dashboardList.clear();
    });
    try {
      await DashboardService().getDashboard().then((value) {
        if (value != []) {
          var data = value["head"]["msg"];
          for (var item in data) {
            DashboardModel dashboardModel = DashboardModel();
            dashboardModel.heading = item["heading"];

            setState(() {
              dashboardList.add(dashboardModel);
            });
          }
        }
      });
    } on SocketException catch (e) {
      throw "Network Error. $e";
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  initState() {
    dashboardHandler = getDashboard();
    super.initState();
  }

  showMenuSheet() {
    showModalBottomSheet(
      backgroundColor: whiteColor,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const MenuList();
      },
    ).then((value) {});
  }
}
