import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rest_api_login/providers/auth.dart';
import 'package:rest_api_login/screens/home_Screen.dart';
import 'package:rest_api_login/screens/signup_screen.dart';
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isRemember = false;
  TextEditingController _UsernameController = TextEditingController();
  TextEditingController _PassController = TextEditingController();

  @override
  void initState() {
    _loadUserEmailPassword();
    super.initState();
  }

  Map<String, String> _authData = {'email': '', 'password': ''};

  Future _submit() async {
    if (!_formKey.currentState.validate()) {
      //invalid
      return;
    }
    _formKey.currentState.save();
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(_authData['email'], _authData['password']);

      _handleRemeberme(_isRemember);
    } on HttpException catch (e) {
      var errorMessage = e.message;
      _showerrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Please try again later: ' + error.toString();
      _showerrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.65,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(360),
                        bottomRight: Radius.circular(360)),
                    color: Colors.orange[500]),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Welcome to FakeInsight",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Checkin theo cách của bạn :)",
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Tên đăng nhập",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            TextFormField(
                              controller: _UsernameController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Vui lòng nhập Tên đăng nhập';
                                }
                              },
                              onSaved: (value) {
                                _authData['email'] = value;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Mật khẩu",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            TextFormField(
                              controller: _PassController,
                              obscureText: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.white,
                                  )),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Vui lòng nhập Mật khẩu';
                                }
                              },
                              onSaved: (value) {
                                _authData['password'] = value;
                              },
                            ),
                            CheckboxListTile(
                              //secondary: const Icon(Icons.remember_me, color: Colors.white,),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('Ghi nhớ thông tin đăng nhập', style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                              ),
                              //subtitle: Text('sub demo mode'),
                              value: this._isRemember,
                              checkboxShape: CircleBorder(),
                              onChanged: (bool value) {
                                setState(() {
                                  this._isRemember = value;
                                });
                              },
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 40),
                              width: 140,
                              child: ElevatedButton(
                                  onPressed: () {
                                    _submit();
                                  },
                                  child: Text(
                                    'Đăng nhập',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                    new BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            )/*,
                            Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => SignUpScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 90),
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            )*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showerrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Lỗi',
          style: TextStyle(color: Colors.blue),
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _handleRemeberme(bool value) {
    print("Handle Rember Me");
    //_isRemember = value;
    if (value){
      SharedPreferences.getInstance().then(
            (prefs) {
          prefs.setBool("remember_me", value);
          prefs.setString('email', _authData['email']);
          prefs.setString('password', _authData['password']);
        },
      );
      setState(() {
        _isRemember = value;
      });
    }
    else {
      SharedPreferences.getInstance().then(
            (prefs) {
          prefs.setBool("remember_me", value);
          prefs.setString('email', '');
          prefs.setString('password', '');
        },
      );
      setState(() {
        _isRemember = value;
      });
    }

  }

  void _loadUserEmailPassword() async {
    print("Load Email");
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;

      print(_remeberMe);
      print(_email);
      print(_password);
      if (_remeberMe) {
        setState(() {
          _isRemember = true;
          _UsernameController.text = _email ?? "";
          _PassController.text = _password ?? "";
        });
        //_emailController.text = _email ?? "";
        //_passwordController.text = _password ?? "";
      }
    } catch (e) {
      print(e);
    }
  }
}
