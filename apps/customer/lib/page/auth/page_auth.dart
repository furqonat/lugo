import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/page/auth/controller_auth.dart';
import 'package:lugo_customer/shared/widget/button.dart';
import 'package:lugo_customer/shared/widget/input.dart';
import 'package:validatorless/validatorless.dart';

class PageAuth extends GetView<ControllerAuth> {
  const PageAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Selamat Datang',
                    style: GoogleFonts.readexPro(
                      fontSize: 30.0,
                      color: const Color(0xFF3978EF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: const Image(
                    width: 300.0,
                    height: 200.0,
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/2023-07-23.jpg')),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                  labelColor: const Color(0xFF14181B),
                  indicatorColor: const Color(0xFF4B39EF),
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 20,
                  ),
                  padding: const EdgeInsets.all(10),
                  unselectedLabelStyle: GoogleFonts.outfit(
                    fontSize: 20,
                    color: const Color(0xFF95A1AC),
                  ),
                  controller: controller.tabController,
                  tabs: const [
                    Tab(
                      text: 'Masuk',
                    ),
                    Tab(
                      text: 'Daftar',
                    ),
                  ]),
            ),
            Obx(
              () => SliverToBoxAdapter(
                child: SizedBox(
                  width: Get.width,
                  height: Get.height * 0.6,
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      Form(
                        key: controller.formSignIn,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Input(
                                controller: controller.edtEmail,
                                labelText: 'Email',
                                validator: Validatorless.multiple([
                                  Validatorless.email('Email tidak valid'),
                                  Validatorless.required(
                                    'Email harus diisi',
                                  ),
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                              child: Input(
                                controller: controller.edtPassword,
                                obscureText: controller.showPass.value,
                                keyboardType: TextInputType.visiblePassword,
                                labelText: 'Password',
                                suffixIcon: GestureDetector(
                                  onTap: () => controller.showPass.value
                                      ? controller.showPass(false)
                                      : controller.showPass(true),
                                  child: Icon(
                                      controller.showPass.value
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: const Color(0xFF95A1AC)),
                                ),
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                    'Password tidak boleh kosong',
                                  ),
                                  Validatorless.min(
                                    6,
                                    'Password tidak boleh kurang dari 6',
                                  ),
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Button(
                                onPressed: () {
                                  final okForm = controller
                                      .formSignIn.currentState!
                                      .validate();
                                  final isLoading =
                                      controller.loadingSignIn.value;
                                  if (okForm && !isLoading) {
                                    controller.handlSignIn();
                                  }
                                },
                                child: controller.loadingSignIn.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Masuk",
                                        style: GoogleFonts.readexPro(
                                            fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Lupa Password",
                                style: GoogleFonts.readexPro(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF14181B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Form(
                        key: controller.formSignUp,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Input(
                                controller: controller.edtEmailDaftar,
                                labelText: "Email",
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                      'Email tidak boleh kosong'),
                                  Validatorless.email('Email tidak sesuai')
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                              child: Input(
                                obscureText: controller.showPass.value,
                                controller: controller.edtPasswordDaftar,
                                labelText: 'Passowrd',
                                suffixIcon: GestureDetector(
                                  onTap: () => controller.showPass.value
                                      ? controller.showPass(false)
                                      : controller.showPass(true),
                                  child: Icon(
                                      controller.showPass.value
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: const Color(0xFF95A1AC)),
                                ),
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                      'Password tidak boleh kosong'),
                                  Validatorless.min(
                                      6, 'Password tidak boleh kurang dari 6'),
                                ]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Button(
                                onPressed: () {
                                  final okForm = controller
                                      .formSignUp.currentState!
                                      .validate();
                                  final isLoading =
                                      controller.loadingSignUp.value;
                                  if (okForm && !isLoading) {
                                    controller.handleSignUp();
                                  }
                                },
                                child: controller.loadingSignUp.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Daftar",
                                        style: GoogleFonts.readexPro(
                                            fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
