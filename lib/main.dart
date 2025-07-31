import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_app_flutter/providers/invoice_provider.dart';
import 'package:sales_app_flutter/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          cardColor: Colors.white,
          appBarTheme: AppBarTheme(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        home: DashboardScreen(),
      ),
    );
  }
}