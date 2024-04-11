
import 'package:flutter/material.dart';
import 'package:kazgeowarningmobile/components/my_button.dart';
import 'package:kazgeowarningmobile/components/my_textfield.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kazgeowarningmobile/pages/login_page.dart';
import 'package:kazgeowarningmobile/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
    final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
    final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
PageController _pageController = PageController(initialPage: 0);

// Функция для перехода к следующей странице
void goToNextPage() {
  _pageController.nextPage(
    duration: Duration(milliseconds: 500),
    curve: Curves.ease,
  );
}
  // sign user in method
  void signIn(BuildContext context) async {
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
            'Create New Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please fill in the information',
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
  child: PageView(
    controller: _pageController,
    children: [
      // Первая страница
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 16, top: 40, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MyTextField(
                controller: usernameController,
                obscureText: false,
                labelText: 'Username',
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: firstNameController,
                obscureText: false,
                labelText: 'First Name',
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: lastNameController,
                obscureText: false,
                labelText: 'Last Name',
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: phoneNumberController,
                obscureText: true,
                labelText: 'Phone Number',
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  goToNextPage();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  margin: EdgeInsets.only(left: 23, right: 20),
                  decoration: BoxDecoration(
                    color:Color(0xFF141C0C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "NEXT STEP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Already registered? Log in.',
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
      // Вторая страница
      SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 16, top: 40, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              MyTextField(
                controller: emailController,
                obscureText: false,
                labelText: 'Email',
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: passwordController,
                obscureText: true,
                labelText: 'Password',
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  goToNextPage();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  margin: EdgeInsets.only(left: 23, right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF141C0C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "NEXT STEP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Already registered? Log in.',
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

 SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 16, top: 40, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Image(image: AssetImage('assets/images/success.png')),
              const SizedBox(height: 20),

              Text(
                  'Verify your email address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please verify your email address in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 110, 85, 85),
                    fontSize: 18,
                  ),
                ),
                Text(
                  '24 - 48 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 110, 85, 85),
                    fontSize: 18,
                  ),
                ),


              
              const SizedBox(height: 80),
              GestureDetector(
                onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  margin: EdgeInsets.only(left: 23, right: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF141C0C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "LOG IN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Обработчик события нажатия, например, навигация на другую страницу
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Already registered? Log in.',
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
    ],
  ),
),
    ],
  ),
),
    );
  }
  void ff(){

  }
}