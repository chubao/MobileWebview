
import 'package:shared_preferences/shared_preferences.dart';

class ShareData {
  Future<Users> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Users users = Users();
    try {
      users.userid =  prefs.getString('userid')!;
      users.deviceid =  prefs.getString('deviceid')!;
      users.email =  prefs.getString('email')!;
      users.moible =  prefs.getString('moible')!;
    } catch (e) {
    }
    return users;
  }

  void setData(users) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userid', users.userid);
    await prefs.setString('deviceid', users.deviceid);
    await prefs.setString('email', users.email);
    await prefs.setString('moible', users.moible);
  }
}

class Users {
  String? userid;
  String? deviceid;
  String? moible;
  String? email;
  Users();
}