import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/utils.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../chat/controller/chat_controller.dart';
import '../../chat/screens/locked_chats_screen.dart';

class LockedChatsIconWidget extends ConsumerStatefulWidget {
  const LockedChatsIconWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LockedChatsIconWidgetState();
}

class _LockedChatsIconWidgetState extends ConsumerState<LockedChatsIconWidget> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool passVisibility = true;
  bool confirmPassVisibility = true;
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    currentPasswordController.text = "";
    newPasswordController.text = "";
    confirmPasswordController.text = "";
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        ref.read(authControllerProvider).getUserData().then((value) {
          if (value!.lockChatPassword == "") {
            return showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Text('Add Password'),
                content: StatefulBuilder(
                  builder: (context, newSetState) {
                    return Form(
                      key: _key,
                      child: SizedBox(
                        height: size.height * 0.20,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: passVisibility,
                              decoration: fieldStyle.copyWith(
                                hintText: "New Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    newSetState(() {
                                      setState(() {
                                        passVisibility = !passVisibility;
                                      });
                                    });
                                  },
                                  icon: Icon(passVisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'new password is required';
                                } else if (value.length < 6) {
                                  return 'Please Enter a Valid Password';
                                }
                                if (value.contains(' ')) {
                                  return "password should not contain spaces";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: confirmPassVisibility,
                              decoration: fieldStyle.copyWith(
                                hintText: "Confirm Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    newSetState(() {
                                      setState(() {
                                        confirmPassVisibility =
                                            !confirmPassVisibility;
                                      });
                                    });
                                  },
                                  icon: Icon(confirmPassVisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'confirm password is required';
                                } else if (value.length < 6) {
                                  return 'Please Enter a Valid Password';
                                } else if (confirmPasswordController.text !=
                                    newPasswordController.text) {
                                  return 'confirm password does\'nt match';
                                } else if (value.contains(' ')) {
                                  return "password should not contain spaces";
                                }
                                return null;
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      newPasswordController.text = "";
                      confirmPasswordController.text = "";
                      passVisibility = true;

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: textStyle,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        if (newPasswordController.text ==
                            confirmPasswordController.text) {
                          ref
                              .watch(authControllerProvider)
                              .setUserLockedChatsPassword(
                                  confirmPasswordController.text.trim());
                          newPasswordController.text = "";
                          confirmPasswordController.text = "";
                          passVisibility = true;
                          confirmPassVisibility = true;
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text(
                      'Done',
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Unlock Chats'),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: StatefulBuilder(
                  builder: (context, newSetState) {
                    return Form(
                      key: _key,
                      child: SizedBox(
                        height: size.height * 0.13,
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            TextFormField(
                              controller: currentPasswordController,
                              obscureText: passVisibility,
                              decoration: fieldStyle.copyWith(
                                hintText: "Enter Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    newSetState(() {
                                      setState(() {
                                        passVisibility = !passVisibility;
                                      });
                                    });
                                  },
                                  icon: Icon(passVisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              validator: (val) {
                                if (val == null) {
                                  return 'password is required';
                                } else if (val.length < 6) {
                                  return 'Please Enter a Valid Password';
                                } else if (currentPasswordController.text
                                        .trim() !=
                                    value.lockChatPassword) {
                                  return "password is incorrect";
                                }
                                return null;
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      currentPasswordController.text = "";

                      Navigator.pop(context, 'Ok');
                    },
                    child: const Text(
                      'Cancel',
                      style: textStyle,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_key.currentState!.validate()) {
                        if (currentPasswordController.text.trim() ==
                            value.lockChatPassword) {
                          currentPasswordController.text = "";
                          passVisibility = true;
                          ref.watch(lockedChatsProvider.notifier).state = true;
                          Navigator.of(context).pop();
                          Navigator.pushNamed(
                              context, LockedChatsScreen.routeName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Password is incorrect")));
                        }
                      }
                    },
                    child: const Text(
                      'Unlock',
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            );
          }
        });
      },
      child: SizedBox(
        // height: MediaQuery.of(context).size.height * 0.082,
        height: size.height * 0.06,

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/deepfake.png',
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
