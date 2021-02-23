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
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    packageName = ModalRoute.of(context).settings.arguments;
    getAppDetails(packageName);
    getPermissions(packageName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getPermissions(packageName);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

      for (int i = 0; i < pList.length; i++) {
        debugPrint("${pList[i]} : ${pCode[i]}");
      }

      /*

      permissionsList = ["Camera", "Contacts", ....]
      permissionValues = [camVal, conVal, ....] => [-1, -1, 0, 0, 0, 1, 1]

      for permissionValues =>

       */

      // TODO : Refactor code to with efficient algorithm to get permission list details

      if (pList.isNotEmpty) {
        int camVal = checkCameraPermission(pList, pCode);
        int conVal = checkContactPermission(pList, pCode);
        int locVal = checkLocationPermission(pList, pCode);
        int micVal = checkMicrophonePermission(pList, pCode);
        int phnVal = checkPhonePermission(pList, pCode);
        int smsVal = checkSmsPermission(pList, pCode);
        int stgVal = checkStoragePermission(pList, pCode);

        // debugPrint("$camVal $conVal $locVal $micVal $phnVal $smsVal $stgVal");

        if (camVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Camera",
            isActive: camVal == 1,
          ));
        }

        if (conVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Contacts",
            isActive: conVal == 1,
          ));
        }

        if (locVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Location",
            isActive: locVal == 1,
          ));
        }

        if (micVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Microphone",
            isActive: micVal == 1,
          ));
        }

        if (phnVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Phone",
            isActive: phnVal == 1,
          ));
        }

        if (smsVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "SMS",
            isActive: smsVal == 1,
          ));
        }

        if (stgVal != -1) {
          allPermission.add(AndroidPermissions(
            permissionType: "Storage",
            isActive: stgVal == 1,
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

  // 1 => Permission Denied
  // 3 => Permission Allowed

  checkCameraPermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.CAMERA":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkContactPermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.READ_CONTACTS":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.GET_ACCOUNTS":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkLocationPermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.ACCESS_COARSE_LOCATION":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.ACCESS_FINE_LOCATION":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.ACCESS_BACKGROUND_LOCATION":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkMicrophonePermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.RECORD_AUDIO":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.CAPTURE_AUDIO_OUTPUT":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkPhonePermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.READ_PHONE_STATE":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.READ_PHONE_NUMBERS":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkSmsPermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.SEND_SMS":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.RECEIVE_SMS":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }

  checkStoragePermission(List<dynamic> pList, List<dynamic> pCode) {
    bool isPermAvailable = false;
    for (int i = 0; i < pList.length; i++) {
      switch (pList[i]) {
        case "android.permission.WRITE_EXTERNAL_STORAGE":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
        case "android.permission.READ_EXTERNAL_STORAGE":
          {
            isPermAvailable = true;
            if (pCode[i] == "3") {
              return 1;
            }
            break;
          }
      }
    }
    return isPermAvailable ? 0 : -1;
  }
}
