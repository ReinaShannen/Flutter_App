import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

Future<void> _checkSession() async {
  await Future.delayed(const Duration(seconds: 2)); // for animation

  final authVM = Provider.of<AuthViewModel>(context, listen: false);
  bool isLoggedIn = await authVM.isLoggedIn();
  print('🚀 isLoggedIn from splash: $isLoggedIn');

  if (!mounted) return;

  if (isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  } else {
    Navigator.pushReplacementNamed(context, '/home');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background2.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Lottie Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/Study.json',
              fit: BoxFit.contain,
            ),
          ),

          // 🔹 Foreground content
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Profile Manager',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Cause',
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: Color.fromRGBO(126, 15, 230, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // Navigate after delay
//     Timer(const Duration(seconds: 10), () {
//       Navigator.pushReplacementNamed(context, '/home');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 🔹 Background Image (same as HomeScreen)
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/background2.jpeg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           // 🔹 Lottie Animation
//           Positioned.fill(
//             child: Lottie.asset(
//               'assets/lottie/Study.json',
//               fit: BoxFit.contain,
//             ),
//           ),

//           // 🔹 Foreground content
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 40),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Text(
//                       'Profile Manager',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontFamily: 'Cause',
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     CircularProgressIndicator(
//                       color: Color.fromRGBO(126, 15, 230, 1),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
