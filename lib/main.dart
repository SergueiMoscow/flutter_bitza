import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_s3_app/screens/consumption_screen.dart';
import 'package:flutter_s3_app/screens/contracts_screen.dart';
import 'package:flutter_s3_app/screens/electric_meter_screen.dart';
import 'package:flutter_s3_app/screens/expenses_screen.dart';
import 'package:flutter_s3_app/screens/main_screen.dart';
import 'package:flutter_s3_app/screens/profile_screen.dart';
import 'package:flutter_s3_app/screens/summary_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Загрузка переменных окружения
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Bitza',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: InitializerWidget(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/payments': (context) => SummaryScreen(),
          '/main': (context) => MainScreen(),
          '/profile': (context) => ProfileScreen(),
          '/electric_meter': (context) => ElectricMeterScreen(),
          '/electric_consumption': (context) => ConsumptionScreen(),
          '/expenses': (context) => ExpensesScreen(),
          '/contracts': (context) => ContractsScreen(),
        },
      ),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({super.key});

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Загружаем токен и проверяем его валидность
    await Provider.of<AuthProvider>(context, listen: false).loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          // Проверяем состояние аутентификации
          return Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                return SummaryScreen();
                // return SummaryScreen();
              } else {
                return LoginScreen();
              }
            },
          );
        }
      },
    );
  }
}
