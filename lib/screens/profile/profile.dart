import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/screens/screens.dart';
import '/utils/utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      bottomNavigationBar: isTv ? null : bottomAppbar(context),
      body: FutureBuilder(
          future: profileHandler,
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
                      profileHandler = getProfile();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: ListView(children: [
                        const Text(
                          "Profile Details",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "School Name(*)",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: schoolNameController,
                          textInputAction: TextInputAction.done,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Name",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.user),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter username";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Address(*)",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: addressController,
                          textInputAction: TextInputAction.done,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Address",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.location),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address name is required';
                            }
                            if (value.length > 300) {
                              return 'Address must be less 300 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "City",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: cityController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "City",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.location),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length > 200) {
                                return 'City must be less 200 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                                return 'City can only contain letters, spaces';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Pincode",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: pincodeController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Pincode",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.code),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length != 6) {
                                return 'Pincode must be 6 characters';
                              }
                              if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                return 'Pincode must contain only numbers';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Username",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: usernameController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Username",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.key),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length > 50) {
                                return 'Username must be less 50 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z\s.]*$').hasMatch(value)) {
                                return 'Username must be letters, spaces, "."';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Password",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "Password",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.key_square),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  passwordvisable = !passwordvisable;
                                });
                              },
                              icon: Icon(passwordvisable
                                  ? Iconsax.eye_slash
                                  : Iconsax.eye),
                              color: const Color(0xff686868),
                            ),
                          ),
                          obscureText: passwordvisable,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Give at least one uppercase letter';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return 'Give at least one lowercase letter';
                              }
                              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                  .hasMatch(value)) {
                                return 'Give at least one special character';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Give at least one number';
                              }
                              if (value.length > 20) {
                                return 'Password must be at most 20 characters long';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Landline",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: landlineController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Landline",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.call),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                return 'Must contain numbers';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Mobile Number",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: mobileNumberController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Phone Number",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.call),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length != 10) {
                                return 'Mobile No. must be 10 characters';
                              }
                              if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                return 'Mobile No. must contain only numbers';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Email",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Email",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final RegExp emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );

                              if (!emailRegex.hasMatch(value)) {
                                return 'Invalid Email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Website",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: websiteController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Website",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.global),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final RegExp urlRegex = RegExp(
                                r'^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\+#]*[\w\-@?^=%&/~\+#]$',
                              );

                              if (!urlRegex.hasMatch(value)) {
                                return 'Please enter a valid URL';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Login From",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: loginFromController,
                          textInputAction: TextInputAction.done,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Login From",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.calendar),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Login To",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: loginToController,
                          textInputAction: TextInputAction.done,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Login To",
                            filled: true,
                            fillColor: whiteColor,
                            prefixIcon: const Icon(Iconsax.calendar),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: redColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ]),
                    ),
                  ));
            }
          }),
    );
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: whiteColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: whiteColor),
      backgroundColor: redColor,
      title: Text(
        "Profile",
        style: TextStyle(color: whiteColor),
      ),
    );
  }

  Future? profileHandler;
  List<ProfileModel> profileList = [];
  bool isTv = false;

  Future getProfile() async {
    setState(() {
      profileList.clear();
    });
    try {
      isTv = await isAndroidTV();
      await ProfileService().getProfile().then((value) {
        if (value != null && value.isNotEmpty) {
          var data = value["head"]["msg"];

          ProfileModel profileModel = ProfileModel();
          profileModel.schoolName = data["name"].toString();
          profileModel.address = data["address"].toString();
          profileModel.city = data["city"].toString();
          profileModel.pincode = data["pincode"].toString();
          profileModel.username = data["school_login_id"].toString();
          profileModel.password = data["password"].toString();
          profileModel.landline = data["landline_number"].toString();
          profileModel.mobileNumber = data["mobile_number"].toString();
          profileModel.email = data["email"].toString();
          profileModel.website = data["website"].toString();
          profileModel.loginFrom = data["login_from_date"].toString();
          profileModel.loginTo = data["login_to_date"].toString();

          setState(() {
            profileList.add(profileModel);
          });
        }
      });
    } on SocketException catch (e) {
      throw "Network Error. $e";
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }

  final formKey = GlobalKey<FormState>();
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController landlineController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController loginFromController = TextEditingController();
  TextEditingController loginToController = TextEditingController();
  bool passwordvisable = true;

  @override
  void initState() {
    profileHandler = getProfile().whenComplete(initSetting);
    super.initState();
  }

  initSetting() {
    if (profileList.isNotEmpty) {
      schoolNameController.text = profileList.first.schoolName!;
      addressController.text = profileList.first.address!;
      cityController.text = profileList.first.city!;
      pincodeController.text = profileList.first.pincode!;
      usernameController.text = profileList.first.username!;
      passwordController.text = profileList.first.password!;
      landlineController.text = profileList.first.landline!;
      mobileNumberController.text = profileList.first.mobileNumber!;
      emailController.text = profileList.first.email!;
      websiteController.text = profileList.first.website!;
      loginFromController.text = profileList.first.loginFrom!;
      loginToController.text = profileList.first.loginTo!;
    }
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: GestureDetector(
        onTap: () {
          if (formKey.currentState!.validate()) {
            submitForm();
          }
        },
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: redColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Submit",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: whiteColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  submitForm() async {
    var schoolId = await LocalDBConfig().getUserId();
    Map formData = {
      "school_change_id": schoolId,
      "address": addressController.text,
      "city": cityController.text,
      "pincode": pincodeController.text,
      "school_login_id": usernameController.text,
      "password": passwordController.text,
      "landline_number": landlineController.text,
      "mobile_number": mobileNumberController.text,
      "email": emailController.text,
      "website": websiteController.text
    };
    try {
      futureLoading(context);
      await ProfileService().updateProfile(formData: formData).then((value) {
        Navigator.pop(context);
        if (value["head"]["code"] == 200) {
          showSnackbar(context,
              content: "Updated Successfully", isSuccess: true);
          Navigator.pop(context);
        } else {
          showSnackbar(context,
              content: value["head"]["msg"], isSuccess: false);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }
}
