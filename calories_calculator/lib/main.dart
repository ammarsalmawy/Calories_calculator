


import 'package:flutter/material.dart';
import 'ShowAll.dart';
import 'searchMeal.dart';
import 'home.dart';
import 'loading.dart';
void main() =>
    runApp(MaterialApp(

      initialRoute: '/home',

      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/search': (context) => SearchMeal(),
        '/showall': (context) => ShowAll(),

      },

    ));
