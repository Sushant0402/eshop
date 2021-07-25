import 'dart:math';

import 'package:eshop/exception/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eshop/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff20bf55).withOpacity(0.5),
                  Color(0xff01baef).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 300,
                    margin: EdgeInsets.only(bottom: 60.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    // transform: Matrix4.rotationZ(-8 * pi / 180)
                    //   ..translate(-10.0),
                    // ..translate(-10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xff36096d).withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Shopper',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title!.color,
                          fontSize: 35,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  //the SingleTickerProviderStateMixin is used by AnimationController specifically vsync and what this does is that it adds some methods that helps
  //vsync to check if the widget is visible to user so it should animated that.
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  late AnimationController
      _controller; //this is class which helps us to control animation
  late Animation<Offset>
      _slideTransition; //Animation is a generic class in flutter and help us to animate things
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    //here vsync help us to animate a widget only if it is visible on the screen it improves performance
    //vsync take a pointer - to which widget it should watch
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    ); //setting up controller

    //Tween class is a generic class in flutter and knows how to animate between two values.
    _slideTransition = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    //Tween class itself does not create animation we have to wrap it within a animation object that can be done by .animate() method
    //and .animate method takes a parent that tells it how to animate.

    // _heightAnimation.addListener(() {setState(() {});});
    //here adding listener to heightAnimation and everytime height Changes we set the state so we can see the changes.

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  void _showAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Ok"))
              ],
            ));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .signIn(_authData["email"]!, _authData["password"]!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData["email"]!, _authData["password"]!);
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication Failed";
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = "This email address is already in use.";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email.";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "This is too weak password.";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not found the user with that emial.";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid password.";
      }
      _showAlert(errorMessage);
    } catch (error) {
      const errorMessage =
          "Could not authenticate you. Please try again later.";
      _showAlert(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward(); //starting animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse(); //reversing animation
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        //animatedContainer by itself set animation we just have to give it a animation object and duration
        //we can also use animationBuilder widget, and that can be used over any widget not only container
        // height: _authMode == AuthMode.Signup ? 320 : 260,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        // height: _heightAnimation.value.height,
        constraints:
        BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    //the max height and min height or height will depend on which mode is currently selected.
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120: 0,
                  ),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideTransition,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button!.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
