import 'package:flutter/material.dart';
import 'package:study_plus/pages/createProjectPage/create_project_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CreateProjectPage() //create project page opens up
    );
  }
}
