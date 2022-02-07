import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  dynamic _token = null;
  late String _userId;

  bool get isAuth {
    return token != null;
  }

  dynamic get token {
    return _token;
  }

  Future<void> authenticate(
      String? email, String? password, String authSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$authSegment?key=AIzaSyCkyBtOqgCwlDut9oxi7GRbW0j6tK1Opb4');
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true},
        ),
      );
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw Exception(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      // _expiryDate = DateTime.now().add(
      //   Duration(
      //     seconds: int.parse(
      //       resData['expiresIn'],
      //     ),
      //   ),
      // );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signin(String? email, String? password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signup(String? email, String? password) async {
    return authenticate(email, password, 'signUp');
  }
}
