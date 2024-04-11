
import 'package:flutter/material.dart';
import 'package:kazgeowarningmobile/components/my_button.dart';
import 'package:kazgeowarningmobile/components/my_textfield.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:kazgeowarningmobile/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  Future<void> signIn(BuildContext context) async {
    // Создайте экземпляр LoginDTO с данными из контроллеров
    var loginData = {
      'email': usernameController.text,
      'password': passwordController.text,
    };

    // Преобразуйте данные в формат JSON
    var jsonData = jsonEncode(loginData);

    try {
      // Отправьте POST-запрос на ваш бэкэнд
      var response = await http.post(
        Uri.parse('http://192.168.0.63:8011/internal/api/public/user/v1/login'),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      // Проверьте успешность запроса
      if (response.statusCode == 200) {
        // Если успешно, получите данные из ответа
        var responseData = jsonDecode(response.body);
        var token = responseData['token'];
        var email = responseData['email'];

        // Сохраняем токен в SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('email', email);
        // Выведите ответ на экран
        print(responseData);
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()));
        // Добавьте здесь код для перехода на следующий экран или выполнения действий после успешного входа
      } else {
        // Если запрос неудачен, выведите сообщение об ошибке
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Если произошла ошибка, выведите ее в консоль
      print('Error during login: $e');
    }
  }


   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // Первый контейнер
            Container(
  height: 240,
  color: Color(0xFF141C0C),
  padding: const EdgeInsets.only(left: 28),
  child: const Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
 Image(image: AssetImage('assets/images/Avatar.png')),
 SizedBox(width: 16),
          Text(
            'KazGeoWarning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          ],),
         
          SizedBox(height: 20),
          
          Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please sign in to your account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          
        ],
      )
    ],
  ),
),

            // Второй контейнер
            Expanded(
              child: SingleChildScrollView(
              child: Container(
                color: Colors.white, // Серый цвет фона
                padding: EdgeInsets.only(left: 16, top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MyTextField(
                    controller: usernameController,
                    obscureText: false,
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 20),
                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    obscureText: true,
                    labelText: 'Password',
                  ),
                  const SizedBox(height: 80),
                  MyButton(
               onTap: () => signIn(context), 
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text(
                  'Not registered yet? Sign up.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
                ),
              ),
              ),
            ),
        
          ],
        ),
      ),
    );
  }
}