import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/services/services.dart';
import '/screens/screens.dart';
import '/utils/utils.dart';

class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  String domain = '';
  String phoneNumber = '';
  String? currentVersion;
  bool isTv = false;

  @override
  void initState() {
    getUserDetails();

    super.initState();
  }

  getUserDetails() async {
    isTv = await isAndroidTV();
    final dbDomain = await LocalDBConfig().getUsername();
    final dbPhoneNum = await LocalDBConfig().getUserType();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      domain = dbDomain ?? '';
      phoneNumber = dbPhoneNum ?? '';
      currentVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  splashRadius: 20,
                  constraints: const BoxConstraints(
                    maxWidth: 40,
                    maxHeight: 40,
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            )
          ],
          backgroundColor: whiteColor,
          surfaceTintColor: whiteColor,
          title: Text(
            "Menu",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: blackColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider(
            //   color: Colors.grey.withOpacity(0.5),
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Image.asset(
                      ImageAssests.logo,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.user,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            domain,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.building,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            phoneNumber,
                            style: TextStyle(fontSize: 14, color: blackColor),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade300),
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    title: 'Dashboard',
                    icon: Iconsax.grid_2,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Favorites',
                    icon: Icons.favorite_border_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Favorite(),
                        ),
                      );
                    },
                  ),
                  if (!isTv)
                    _buildListTile(
                      context,
                      title: 'Downloads',
                      icon: Iconsax.arrow_down,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Downloads(),
                          ),
                        );
                      },
                    ),
                  _buildListTile(
                    context,
                    title: 'Profile',
                    icon: Iconsax.personalcard,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Profile(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    title: 'Logout',
                    icon: CupertinoIcons.power,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const ConfirmDialog(
                          title: "Alert",
                          content: "Do you want Confirm to Logout?",
                        ),
                      ).then((result) async {
                        if (result != null && result) {
                          await LocalDBConfig().logout().then((value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          });
                        }
                      });
                    },
                  ),
                  if (currentVersion != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          "App Version $currentVersion",
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: const Icon(Iconsax.mobile, size: 25),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
      required IconData icon,
      required void Function() onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        leading: Icon(icon, size: 25),
        onTap: onTap,
        // trailing: const Icon(LineIcons.arrowRight),
      ),
    );
  }
}
