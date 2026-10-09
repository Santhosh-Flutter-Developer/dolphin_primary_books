import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import '/constants/constants.dart';
import '/services/services.dart';
import '/screens/screens.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
// Create focus nodes for both fields
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill, image: AssetImage(ImageAssests.background))),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ImageAssests.logo,
                      height: 100,
                      width: 100,
                    ),
                    TextFormField(
                      autofocus: true,
                      controller: username,
                      focusNode: _usernameFocusNode, // Assign focus node
                      onEditingComplete: () {
                        // Move focus to password field when "Go" is pressed
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      textInputAction:
                          TextInputAction.go, // This shows "Go" on keyboard
                      decoration: InputDecoration(
                        hintText: "Username",
                        filled: true,
                        fillColor: whiteColor,
                        prefixIcon: const Icon(Iconsax.user),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: redColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter username";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FocusableActionDetector(
                      shortcuts: {
                        LogicalKeySet(LogicalKeyboardKey.arrowUp):
                            const ActivateIntent(),
                      },
                      actions: {
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (ActivateIntent intent) {
                            FocusScope.of(context)
                                .requestFocus(_usernameFocusNode);
                            return null;
                          },
                        ),
                      },
                      child: TextFormField(
                        focusNode: _passwordFocusNode,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(_loginFocusNode);
                        },
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: password,
                        decoration: InputDecoration(
                          hintText: "Password",
                          filled: true,
                          fillColor: whiteColor,
                          prefixIcon: const Icon(Iconsax.key),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: redColor),
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
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          submitForm();
                        }
                      },
                      child: Focus(
                        focusNode: _loginFocusNode,
                        onFocusChange: (hasFocus) {
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _loginFocusNode.hasFocus
                                ? redColor
                                : redColor.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  bool passwordvisable = true;
  var formKey = GlobalKey<FormState>();
  final FocusNode _loginFocusNode = FocusNode();

  submitForm() async {
    try {
      futureLoading(context);
      await AuthService()
          .checkLogin(username: username.text, password: password.text)
          .then((value) async {
        Navigator.pop(context);
        if (value != []) {
          if (value["head"]["code"] == 200) {
            var sessionData = value["head"]["session_data"];

            var books = [];
            var booksResponse = await http.post(
              Uri.parse("$rootUrl/include/api/videotutorial_api.php"),
              headers: await AuthService().getHeaders(),
              body: json.encode(
                  {"get_section_school_id": sessionData["user_id"].toString()}),
            );

            if (booksResponse.statusCode == 200) {
              var booksJsonResponse = json.decode(booksResponse.body);
              var booksJson = booksJsonResponse['head']['msg'];

              if (booksJson != null && booksJson is List) {
                for (var i in booksJson) {
                  books.add(i["pdf"]);
                }
              }
            }

            await LocalDBConfig()
                .newUserLogin(
              userId: sessionData["user_id"].toString(),
              userName: sessionData["user_name"].toString(),
              userLoginId: sessionData["user_login_id"].toString(),
              userType: sessionData["user_type"].toString(),
              books: books.map((e) => json.encode(e)).toList(),
            )
                .then((value) {
              showSnackbar(context,
                  content: "Login Successfully", isSuccess: true);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Dashboard()));
            });
          } else {
            showSnackbar(context,
                content: value["head"]["msg"].toString(), isSuccess: false);
          }
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }
}
