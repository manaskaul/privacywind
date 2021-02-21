import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';
import 'package:privacywind/permission_manager/permission_list_model.dart';

class PermissionList extends StatefulWidget {
  @override
  _PermissionListState createState() => _PermissionListState();
}

class _PermissionListState extends State<PermissionList>
    with WidgetsBindingObserver {
  String packageName;
  ApplicationWithIcon selectedApp;

  List<String> permissionName;
  List<String> permissionStatus;
  List<AndroidPermissions> allPermission = List();
  bool hasPermissions = false;

  static const platform =
      const MethodChannel("com.example.test_permissions_app/permissions");

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    packageName = ModalRoute.of(context).settings.arguments;
    getAppDetails(packageName);
    getPermissions(packageName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      getPermissions(packageName);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, Icon> permissionIcons = {
    //   "Camera": Icon(
    //     Icons.camera_alt_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "Contacts": Icon(
    //     Icons.contacts_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "Location": Icon(
    //     Icons.location_on_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "Microphone": Icon(
    //     Icons.mic_none_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "Phone": Icon(
    //     Icons.local_phone_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "SMS": Icon(
    //     Icons.sms_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    //   "Storage": Icon(
    //     Icons.folder_open_outlined,
    //     color: Theme.of(context).iconTheme.color,
    //   )
    // };

    return Scaffold(
      appBar: AppBar(
        title: Text("Permission Manager"),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  selectedApp == null
                      ? Container(
                          width: 100.0,
                          height: 100.0,
                          padding: EdgeInsets.all(15.0),
                        )
                      : Container(
                          padding: EdgeInsets.all(15.0),
                          child: CircleAvatar(
                            backgroundImage: MemoryImage((selectedApp).icon),
                            radius: 60.0,
                          ),
                        ),
                  selectedApp == null
                      ? Container(
                          child: Text(
                            "App Name",
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                          child: Text(
                            selectedApp.appName,
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                  selectedApp == null
                      ? Container()
                      : Container(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Text(selectedApp.versionName),
                        ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Divider(thickness: 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Container(
          child: hasPermissions && allPermission.length != 0
              ? ListView.builder(
                  itemCount: allPermission.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(allPermission[index].permissionType),
                      leading: PermissionIconData(context: context)
                          .getPermissionIcon(
                              allPermission[index].permissionType),
                      trailing: Switch(
                        value: allPermission[index].isActive,
                        onChanged: (value) async {
                          try {
                            await platform.invokeMethod(
                                "openAppInfo", packageName);
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                      ),
                    );
                  },
                )
              : Center(child: Text("This app requires no permission")),
        ),
      ),
    );
  }

  getAppDetails(String packageName) async {
    await DeviceApps.getApp(packageName).then((value) {
      ApplicationWithIcon applicationWithIcon = value as ApplicationWithIcon;
      selectedApp = applicationWithIcon;
    });
    setState(() {});
  }

  Future<void> getPermissions(String packageName) async {
    dynamic val;
    try {
      val = await platform.invokeMethod("getAppPermission", packageName);

      allPermission.clear();

      List<dynamic> pList = val["permission_list"];
      List<dynamic> pCode = val["permission_code"];

      // for (int i = 0; i < pList.length; i++) {
      //   debugPrint("${pList[i]} : ${pCode[i]}");
      // }

      if (pList.isEmpty) {
        hasPermissions = false;
      } else {
        int camVal = checkCameraPermission(pList);
        int conVal = checkContactPermission(pList);
        int locVal = checkLocationPermission(pList);
        int micVal = checkMicrophonePermission(pList);
        int phnVal = checkPhonePermission(pList);
        int smsVal = checkSmsPermission(pList);
        int stgVal = checkStoragePermission(pList);

        // debugPrint("$camVal $conVal $locVal $micVal $phnVal $smsVal $stgVal");

        if (camVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Camera",
            isActive: isPermissionActive(pCode, camVal),
          ));
        }

        if (conVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Contacts",
            isActive: isPermissionActive(pCode, conVal),
          ));
        }

        if (locVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Location",
            isActive: isPermissionActive(pCode, locVal),
          ));
        }

        if (micVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Microphone",
            isActive: isPermissionActive(pCode, micVal),
          ));
        }

        if (phnVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Phone",
            isActive: isPermissionActive(pCode, phnVal),
          ));
        }

        if (smsVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "SMS",
            isActive: isPermissionActive(pCode, smsVal),
          ));
        }

        if (stgVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Storage",
            isActive: isPermissionActive(pCode, stgVal),
          ));
        }

        setState(() {
          hasPermissions = true;
        });

        // for (AndroidPermissions aps in allPermission) {
        //   debugPrint("${aps.permissionType} : ${aps.isActive}");
        // }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  checkCameraPermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.CAMERA") {
        return i;
      }
    }
    return -1;
  }

  checkContactPermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.READ_CONTACTS" ||
          pList[i] == "android.permission.GET_ACCOUNTS") {
        return i;
      }
    }
    return -1;
  }

  checkLocationPermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.ACCESS_COARSE_LOCATION" ||
          pList[i] == "android.permission.ACCESS_FINE_LOCATION" ||
          pList[i] == "android.permission.ACCESS_BACKGROUND_LOCATION") {
        return i;
      }
    }
    return -1;
  }

  checkMicrophonePermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.RECORD_AUDIO" ||
          pList[i] == "android.permission.CAPTURE_AUDIO_OUTPUT") {
        return i;
      }
    }
    return -1;
  }

  checkPhonePermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.READ_PHONE_STATE" ||
          pList[i] == "android.permission.READ_PHONE_NUMBERS") {
        return i;
      }
    }
    return -1;
  }

  checkSmsPermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.SEND_SMS" ||
          pList[i] == "android.permission.RECEIVE_SMS") {
        return i;
      }
    }
    return -1;
  }

  checkStoragePermission(List<dynamic> pList) {
    for (int i = 0; i < pList.length; i++) {
      if (pList[i] == "android.permission.WRITE_EXTERNAL_STORAGE" ||
          pList[i] == "android.permission.READ_EXTERNAL_STORAGE") {
        return i;
      }
    }
    return -1;
  }

  isPermissionActive(List<dynamic> pCode, int index) {
    if (pCode[index] == "1") {
      return false;
    } else if (pCode[index] == "3") {
      return true;
    }
  }
}
