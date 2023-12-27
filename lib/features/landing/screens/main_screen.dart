import 'package:deepfake_prevention_app/features/deepfake/screens/deepfake_data_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:no_screenshot/no_screenshot.dart';

import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/rounded_body.dart';
import '../../../services/notification_services.dart';
import '../../authentication/controller/auth_controller.dart';
import '../../authentication/screens/profile_screen.dart';
import '../../chat/widgets/contacts_list.dart';
import '../../deepfake/screens/deepfake_prevention.dart';
import '../../select_contacts/screens/select_contacts_screen.dart';
import '../widgets/locked_icon_widget.dart';

final searchProvider = StateProvider<TextEditingController>((ref) {
  final searchController = TextEditingController();
  return searchController;
});

final searchTextProvider = StateProvider<String>((ref) {
  return ref.watch(searchProvider).text;
});

final searchEnabledProvider = StateProvider<bool>((ref) {
  return false;
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  static const routeName = '/main-screen';
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _noScreenshot = NoScreenshot.instance;
  late TabController tabBarController;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool passVisibility = true;
  bool confirmPassVisibility = true;
  final key = GlobalKey<FormState>();

  void handleTabSelection() {
    if (tabBarController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    NotificationServices notificationServices = NotificationServices();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
    tabBarController = TabController(length: 2, vsync: this);
    tabBarController.addListener(handleTabSelection);
    WidgetsBinding.instance.addObserver(this);
    tabBarController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabBarController.removeListener(handleTabSelection);
    tabBarController.dispose();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _noScreenshot.screenshotOff();

    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserOnlineStatus(true);
        break;
      default:
        ref.read(authControllerProvider).setUserOnlineStatus(false);
        break;
    }
  }

  void startSearch() {
    ref.read(searchEnabledProvider.notifier).state = true;
  }

  void endSearch() {
    ref.read(searchProvider).clear();
    ref.read(searchEnabledProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: false,
        title: ref.watch(searchEnabledProvider)
            ? TextField(
                controller: ref.read(searchProvider),
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  ref.read(searchTextProvider.notifier).state = value;
                },
              )
            : const LockedChatsIconWidget(),
        actions: [
          if (!ref.watch(searchEnabledProvider))
            IconButton(
              onPressed: startSearch,
              icon: const Icon(Icons.search),
            ),
          if (ref.watch(searchEnabledProvider))
            IconButton(
              onPressed: endSearch,
              icon: const Icon(Icons.close),
            ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: CircleAvatar(
              backgroundColor: accentColor,
              child: IconButton(
                icon: const Icon(Icons.person, color: primaryColor),
                onPressed: () {
                  Navigator.pushNamed(context, ProfileScreen.routeName);
                },
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: tabBarController,
          indicatorColor: tabColor,
          indicatorWeight: size.width * 0.008,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: size.width * 0.005,
              color: accentColor,
            ),
            insets: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          ),
          labelColor: accentColor,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              text: 'CHATS',
            ),
            Tab(
              text: 'DFP',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabBarController,
        children: const [
          RoundedBody(
            child: ContactsList(),
          ),
          RoundedBody(
            child: DeepfakePreventionScreen(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (tabBarController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SelectContactsScreen()),
            );
          } else {
            ref.read(authControllerProvider).getUserData().then((value) {
              if (value!.lockChatPassword == "") {
                return showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Add Password'),
                    content: StatefulBuilder(
                      builder: (context, newSetState) {
                        return Form(
                          key: key,
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
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    title: const Text('Unlock Protected Pictures'),
                    content: StatefulBuilder(
                      builder: (context, newSetState) {
                        return Form(
                          key: key,
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
                          if (key.currentState!.validate()) {
                            if (currentPasswordController.text.trim() ==
                                value.lockChatPassword) {
                              currentPasswordController.text = "";
                              passVisibility = true;
                              Navigator.of(context).pop();
                              Navigator.pushNamed(
                                  context, DeepfakeDataScreen.routeName);
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
          }
        },
        backgroundColor: primaryColor,
        child: Icon(
          tabBarController.index == 0 ? Icons.comment : Icons.privacy_tip,
          color: Colors.white,
        ),
      ),
    );
  }
}
