import 'package:flutter/material.dart';
// Home page( All role use together )
import 'package:finalproject/home.dart';
import 'package:finalproject/login.dart';
import 'package:finalproject/signup.dart';

// student
import 'package:finalproject/student/student_browseAsset.dart';
import 'package:finalproject/student/student_history.dart';
import 'package:finalproject/student/student_profile.dart';
import 'package:finalproject/student/student_checkRequest.dart';

// Lender
import 'package:finalproject/lender/lender_browseAsset.dart';
import 'package:finalproject/lender/lender_dashboard.dart';
import 'package:finalproject/lender/lender_checkRequest.dart';
import 'package:finalproject/lender/lender_history.dart';
import 'package:finalproject/lender/lender_profile.dart';

// Staff
import 'package:finalproject/staff/staff_browseAsset.dart';
import 'package:finalproject/staff/staff_dashboard.dart';
import 'package:finalproject/staff/staff_return.dart';
import 'package:finalproject/staff/staff_history.dart';
import 'package:finalproject/staff/staff_profile.dart';

void main() =>  runApp(
  MaterialApp(
    // home: const HomePage() ,
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => const  HomePage(),
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUpPage(),
      
      // Student
      '/student_BrowseAsset': (context) => const BookAsset(),
      '/student_Request': (context) =>  RequestStat(),
      '/student_History': (context) => const StudentHistory(),
      '/student_Profile': (context) => const ProfileScreen(),

      // Lender
      '/lender_BrowseAsset':(context) => const BookAssetLender(),
      '/lender_Dashboard':(context) => const LenderDashboard(),
      '/lender_Request':(context) => const LenderCheckRequest(),
      '/lender_History':(context) => const LenderHistory(),
      '/lender_Profile':(context) => const LenderProfile(),

      // Staff
      '/staff_BrowseAsset':(context) => HomePageStaff(),
      '/staff_Dashboard':(context) => const StaffDashboard(),
      '/staff_Return': (context) =>  const StaffReturn(),
      '/staff_History':(context) => const StaffHistory(),
      '/staff_Profile':(context) => const StaffProfile(),

    },
    initialRoute: '/',
));



