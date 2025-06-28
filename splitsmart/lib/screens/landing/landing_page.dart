import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF001f3f), Color(0xFFFFFFFF)],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SplitSmart',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Color(0xFF001f3f),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                      ),
                      if (isDesktop)
                        Row(
                          children: [
                            _NavButton(
                              label: 'Login',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            _NavButton(
                              label: 'Register',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to SplitSmart',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Color(0xFF001f3f),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Effortlessly manage and split expenses with friends, family, or roommates. Get started now!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Color(0xFF001f3f).withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          if (!isDesktop)
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    },
                                    child: const Text('Login'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                                      );
                                    },
                                    child: const Text('Register'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavButton({required this.label, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovering ? Colors.white : Color(0xFF001f3f),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering ? Color(0xFF3D5A80) : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
            child: Text(
              widget.label,
              style: TextStyle(
                color: _hovering ? Color(0xFF001f3f) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 