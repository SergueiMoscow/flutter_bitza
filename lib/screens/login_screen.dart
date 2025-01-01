import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';
import '../api/auth_api.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: FlutterLogin(
        title: 'Ваше Приложение',
        userType: LoginUserType.name,
        userValidator: (value) {
          if (value == null || value.isEmpty) {
            return 'Пожалуйста, введите имя пользователя';
          }
          return null;
        },
        passwordValidator: (value) {
          if (value == null || value.isEmpty) {
            return 'Пожалуйста, введите пароль';
          }
          return null;
        },
        onLogin: (loginData) async {
          final authService = AuthApiService();
          try {
            // Очищаем старые ошибки
            authProvider.clearError();

            final success = await authService.login(
              username: loginData.name,
              password: loginData.password,
            );

            if (success.isNotEmpty) {
              // Успешный вход, переход на главный экран
              Navigator.of(context).pushReplacementNamed('/main');
              return null;
            } else {
              // Некорректные учетные данные
              return 'Неверное имя пользователя или пароль';
            }
          } catch (e) {
            // Возврат ошибки для отображения в интерфейсе
            return 'Ошибка: ${e.toString()}';
          }
        },
        onSignup: (signupData) async {
          // Реализуйте логику регистрации, если требуется
          return 'Регистрация не поддерживается';
        },
        onRecoverPassword: (name) async {
          // Логика восстановления пароля
          return 'Функция восстановления пароля пока не реализована';
        },
        messages: LoginMessages(
          userHint: 'Имя пользователя',
          passwordHint: 'Пароль',
          loginButton: 'Войти',
          signupButton: 'Регистрация',
          forgotPasswordButton: 'Забыли пароль?',
          recoverPasswordButton: 'Восстановить пароль',
          recoverPasswordIntro: 'Восстановление пароля',
          recoverPasswordDescription:
          'Введите ваше имя пользователя для восстановления пароля.',
          recoverPasswordSuccess:
          'Проверьте вашу почту для дальнейших инструкций.',
        ),
        onSubmitAnimationCompleted: () {
          // Дополнительная логика после анимации завершения входа, если необходимо
        },
        theme: LoginTheme(
          primaryColor: Colors.blue,
          accentColor: Colors.blueAccent,
          errorColor: Colors.deepOrange,
          titleStyle: const TextStyle(
            color: Colors.blue,
            fontFamily: 'Quicksand',
            letterSpacing: 4,
          ),
        ),
        footer: '© 2023 Ваше Приложение',
      ),
      // Отображение ошибки, если она есть
      bottomNavigationBar: authProvider.errorMessage != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          authProvider.errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : null,
    );
  }
}