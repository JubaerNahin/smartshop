import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'S M A R T S H O P     A I',
          style: GoogleFonts.lato(fontSize: width * 0.06),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primarycolor,
        // foregroundColor: AppColors.buttoncolors,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            SizedBox.expand(
              // child: Image.asset(
              //   'assets/images/welcome_screen.jpg',
              //   fit: BoxFit.cover,
              // ),
              child: Container(color: AppColors.primarycolor),
            ),

            // Overlay content
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.03,
                          ),
                          textStyle: TextStyle(fontSize: width * 0.045),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.buttoncolors,
                        ),
                        onPressed: () => Get.offNamed('/signin'),
                        child: const Text('Sign In'),
                      ),
                      SizedBox(height: height * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.03,
                          ),
                          textStyle: TextStyle(fontSize: width * 0.045),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.buttoncolors,
                        ),
                        onPressed: () => Get.offNamed('/signup'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
