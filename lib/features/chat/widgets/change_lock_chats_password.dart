import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/utils.dart';
import '../../authentication/controller/auth_controller.dart';

class ChangeLockedItemsPassWidget extends ConsumerStatefulWidget {
  const ChangeLockedItemsPassWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeLockedChatPassWidgetState();
}

class _ChangeLockedChatPassWidgetState
    extends ConsumerState<ChangeLockedItemsPassWidget> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool passVisibility = true;
  bool confirmPassVisibility = true;
  @override
  void dispose() {
    super.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    currentPasswordController.text = "";
    newPasswordController.text = "";
    confirmPasswordController.text = "";
    return GestureDetector(
      onTap: () {
        final key = GlobalKey<FormState>();
        ref.read(authControllerProvider).getUserData().then((value) {
          return showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Change Password'),
              content: StatefulBuilder(
                builder: (context, newSetState) {
                  return Form(
                    key: key,
                    child: SizedBox(
                      height: size.height * 0.26,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: currentPasswordController,
                            obscureText: passVisibility,
                            decoration: fieldStyle.copyWith(
                              hintText: "Enter Current Password",
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
                              } else if (val != value!.lockChatPassword) {
                                return 'password is incorrect';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: confirmPassVisibility,
                            decoration: fieldStyle.copyWith(
                              hintText: "New Password",
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
                                return 'new password is required';
                              } else if (value.length < 6) {
                                return 'Please Enter a Valid Password';
                              } else if (value.contains(' ')) {
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
                    if (key.currentState!.validate()) {
                      ref
                          .watch(authControllerProvider)
                          .setUserLockedChatsPassword(
                              confirmPasswordController.text.trim());
                      currentPasswordController.text = "";
                      newPasswordController.text = "";
                      confirmPasswordController.text = "";
                      passVisibility = true;
                      confirmPassVisibility = true;
                      Navigator.pop(context);
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
        });
      },
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.03),
        child: const Icon(Icons.lock),
      ),
    );
  }
}
