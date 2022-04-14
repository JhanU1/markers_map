import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers_map/ui/pages/map_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'News App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
        home: MapPage());
  }
}
