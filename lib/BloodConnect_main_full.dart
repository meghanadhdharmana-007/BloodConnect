import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BloodConnectApp());
}

class BloodConnectApp extends StatelessWidget {
  const BloodConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFB71C1C);
    const lightRed = Color(0xFFFFEBEE);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BloodConnect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryRed, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 50),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryRed,
            minimumSize: const Size(0, 50),
            side: const BorderSide(color: primaryRed, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryRed;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return lightRed;
            return null;
          }),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}



// ==================== UI HELPERS ====================

String _formatDate(dynamic value) {
  if (value is Timestamp) {
    final date = value.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
  return '-';
}

String _formatDateTime(dynamic value) {
  if (value is Timestamp) {
    final date = value.toDate();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }
  return '-';
}

Color _statusColor(String status) {
  switch (status) {
    case 'Completed':
      return Colors.green;
    case 'Cancelled':
      return Colors.grey;
    case 'Donor Found':
      return Colors.blue;
    case 'Open':
      return Colors.orange.shade800;
    default:
      return const Color(0xFFB71C1C);
  }
}

Widget _statusChip(String status) {
  final color = _statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _bloodChip(String bloodGroup) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFB71C1C),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      bloodGroup,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
  );
}

Widget _emptyState({
  required IconData icon,
  required String title,
  required String message,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 42,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _profileAvatar({
  required String? imageData,
  required double radius,
  Color background = Colors.white,
  Color iconColor = Colors.grey,
}) {
  if (imageData != null && imageData.contains(',')) {
    try {
      return CircleAvatar(
        radius: radius,
        backgroundColor: background,
        backgroundImage: MemoryImage(
          base64Decode(imageData.split(',').last),
        ),
      );
    } catch (_) {}
  }

  return CircleAvatar(
    radius: radius,
    backgroundColor: background,
    child: Icon(
      Icons.person,
      size: radius * 1.15,
      color: iconColor,
    ),
  );
}

// ==================== WELCOME SCREEN ====================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEBEE),
              Color(0xFFF8F9FB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bloodtype,
                    size: 68,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'BloodConnect',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'College Blood Donation & Emergency Network',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Color(0xFFB71C1C),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Donate blood. Find help. Save lives.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'A simple way for college students to connect during blood emergencies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ==================== LOGIN SCREEN ====================


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.reload();
      final user = FirebaseAuth.instance.currentUser!;

      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email before logging in.'),
          ),
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first, then tap Forgot Password.'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not send reset email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    size: 48,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Log in to continue helping your college community.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : login,
                    icon: isLoading
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      isLoading ? 'Logging in...' : 'Login',
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Create New Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<DocumentSnapshot<Map<String, dynamic>>> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: color.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bloodtype, size: 28, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'BloodConnect',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => openPage(const ProfileScreen()),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000 ? 3 : 2;
          const spacing = 16.0;
          final contentWidth =
              constraints.maxWidth > 1100 ? 1100.0 : constraints.maxWidth;
          final cardWidth =
              (contentWidth - (spacing * (columns - 1))) / columns;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: profileFuture,
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final name = data?['fullName'] ?? 'BloodConnect Member';
                        final bloodGroup = data?['bloodGroup'] ?? '-';
                        final image = data?['profileImage'] as String?;
                        final donorAvailable =
                            data?['donorAvailable'] == true;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFB71C1C),
                                Color(0xFFE53935),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.20),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _profileAvatar(
                                imageData: image,
                                radius: 34,
                                background: Colors.white,
                                iconColor: const Color(0xFFB71C1C),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.78),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.16),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Blood: $bloodGroup',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.16),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            donorAvailable
                                                ? 'Donor Available'
                                                : 'Donor Off',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Everything you need in one place',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.person,
                            title: 'My Profile',
                            subtitle: 'Photo, details & availability',
                            color: const Color(0xFF1565C0),
                            onTap: () => openPage(const ProfileScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.history,
                            title: 'Donation History',
                            subtitle: 'View your donations',
                            color: const Color(0xFF6A1B9A),
                            onTap: () =>
                                openPage(const DonationHistoryScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.bloodtype,
                            title: 'Request Blood',
                            subtitle: 'Create a blood request',
                            color: const Color(0xFFB71C1C),
                            onTap: () => openPage(const BloodRequestScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.list_alt,
                            title: 'Blood Requests',
                            subtitle: 'View available requests',
                            color: const Color(0xFFEF6C00),
                            onTap: () =>
                                openPage(const BloodRequestsScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.assignment,
                            title: 'My Requests',
                            subtitle: 'Track your requests',
                            color: const Color(0xFF00838F),
                            onTap: () =>
                                openPage(const MyBloodRequestsScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.volunteer_activism,
                            title: 'Find Requests',
                            subtitle: 'Help someone with your blood group',
                            color: const Color(0xFF2E7D32),
                            onTap: () async {
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();
                              final bloodGroup =
                                  userDoc.data()?['bloodGroup'];

                              if (bloodGroup == null || !context.mounted) return;

                              openPage(
                                DonorBloodRequestsScreen(
                                  bloodGroup: bloodGroup,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: actionCard(
                            icon: Icons.map,
                            title: 'Location Map',
                            subtitle: 'Open the map',
                            color: const Color(0xFF3949AB),
                            onTap: () => openPage(const MapScreen()),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('notifications')
                                .where('userId', isEqualTo: user.uid)
                                .where('read', isEqualTo: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final unread =
                                  snapshot.data?.docs.length ?? 0;

                              return actionCard(
                                icon: Icons.notifications,
                                title: 'Notifications',
                                subtitle: unread == 0
                                    ? 'You are all caught up'
                                    : '$unread unread notification(s)',
                                color: const Color(0xFFC2185B),
                                badge: unread == 0 ? null : '$unread',
                                onTap: () =>
                                    openPage(const NotificationsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: profileFuture,
                      builder: (context, snapshot) {
                        final isAdmin =
                            snapshot.data?.data()?['isAdmin'] == true;

                        if (!isAdmin) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Administration',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: actionCard(
                                icon: Icons.admin_panel_settings,
                                title: 'Admin Dashboard',
                                subtitle:
                                    'Manage users, requests, emergencies and donors',
                                color: const Color(0xFF37474F),
                                onTap: () =>
                                    openPage(const AdminDashboardScreen()),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}






class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends State<ProfileScreen> {
  bool donorAvailable = false;
  String? profileImage;
  bool isLoading = true;

  final ImagePicker imagePicker = ImagePicker();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final document = await getUserProfile();
      if (!mounted) return;

      final data = document.data();

      setState(() {
        donorAvailable = data?['donorAvailable'] == true;
        profileImage = data?['profileImage'] as String?;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> chooseProfilePhoto() async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 600,
        maxHeight: 600,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('Could not read this image.');
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: 400,
        height: 400,
      );

      final compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 60,
      );

      final imageData =
          'data:image/jpeg;base64,${base64Encode(compressedBytes)}';

      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImage': imageData});

      if (!mounted) return;

      setState(() => profileImage = imageData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update photo: $e')),
      );
    }
  }

  Future<void> removeProfilePhoto() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImage': FieldValue.delete()});

      if (!mounted) return;

      setState(() => profileImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove photo: $e')),
      );
    }
  }

  Future<void> editProfile(Map<String, dynamic> data) async {
    final nameController =
        TextEditingController(text: data['fullName'] ?? '');
    final phoneController =
        TextEditingController(text: data['phone'] ?? '');
    final locationController =
        TextEditingController(text: data['location'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'City / Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      nameController.dispose();
      phoneController.dispose();
      locationController.dispose();
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
      });

      nameController.dispose();
      phoneController.dispose();
      locationController.dispose();

      if (!mounted) return;

      await loadProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      nameController.dispose();
      phoneController.dispose();
      locationController.dispose();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    }
  }

  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.photo_library),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    chooseProfilePhoto();
                  },
                ),
                if (profileImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.delete),
                    ),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      removeProfilePhoto();
                    },
                  ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.close),
                  ),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final document = await getUserProfile();
              if (!mounted || !document.exists) return;
              await editProfile(document.data() ?? {});
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return _emptyState(
              icon: Icons.person_off,
              title: 'Profile not found',
              message: 'We could not load your profile details.',
            );
          }

          final data = snapshot.data!.data()!;
          donorAvailable = data['donorAvailable'] == true;
          profileImage = data['profileImage'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB71C1C),
                            Color(0xFFE53935),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.18),
                            blurRadius: 22,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: ClipOval(
                                  child: profileImage != null
                                      ? Image.memory(
                                          base64Decode(
                                            profileImage!.split(',').last,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: showPhotoOptions,
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Color(0xFFB71C1C),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data['fullName'] ?? 'User',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data['email'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Blood Group: ${data['bloodGroup'] ?? '-'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  donorAvailable
                                      ? '● Available Donor'
                                      : '● Not Available',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap the camera icon to add, change or remove your photo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Personal Details',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => editProfile(data),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _ProfileInfoRow(
                              icon: Icons.person,
                              title: 'Full Name',
                              value: data['fullName'] ?? '-',
                            ),
                            const Divider(height: 26),
                            _ProfileInfoRow(
                              icon: Icons.badge,
                              title: 'College ID',
                              value: data['collegeId'] ?? '-',
                            ),
                            const Divider(height: 26),
                            _ProfileInfoRow(
                              icon: Icons.email,
                              title: 'Email',
                              value: data['email'] ?? '-',
                            ),
                            const Divider(height: 26),
                            _ProfileInfoRow(
                              icon: Icons.phone,
                              title: 'Phone',
                              value: data['phone'] ?? '-',
                            ),
                            const Divider(height: 26),
                            _ProfileInfoRow(
                              icon: Icons.bloodtype,
                              title: 'Blood Group',
                              value: data['bloodGroup'] ?? '-',
                              valueColor: const Color(0xFFB71C1C),
                            ),
                            const Divider(height: 26),
                            _ProfileInfoRow(
                              icon: Icons.location_on,
                              title: 'Location',
                              value: data['location'] ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('donations')
                          .snapshots(),
                      builder: (context, donationSnapshot) {
                        final count = donationSnapshot.data?.docs.length ?? 0;

                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.volunteer_activism,
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Donation History',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Your recorded blood donations',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    Card(
                      margin: EdgeInsets.zero,
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        secondary: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: donorAvailable
                                ? Colors.green.withOpacity(0.10)
                                : Colors.grey.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.volunteer_activism,
                            color: donorAvailable ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: const Text(
                          'Donor Availability',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          donorAvailable
                              ? 'You are available to donate'
                              : 'You are currently unavailable',
                        ),
                        value: donorAvailable,
                        onChanged: (value) async {
                          setState(() => donorAvailable = value);

                          final userId =
                              FirebaseAuth.instance.currentUser!.uid;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({'donorAvailable': value});
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: showPhotoOptions,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          profileImage == null
                              ? 'Add Profile Photo'
                              : 'Change Profile Photo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



// PROFILE INFORMATION ROW

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C)
                .withOpacity(0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB71C1C),
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('donations')
            .orderBy('donationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load donations: ${snapshot.error}'),
              ),
            );
          }

          final donations = snapshot.data?.docs ?? [];
          DateTime? lastDonationDate;

          if (donations.isNotEmpty) {
            final latest =
                donations.first.data() as Map<String, dynamic>;
            final value = latest['donationDate'];
            if (value is Timestamp) {
              lastDonationDate = value.toDate();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7B1FA2),
                            Color(0xFFAB47BC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.history,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Donation Journey',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Keep a simple record of every donation.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _DonationSummaryCard(
                            title: 'Donations',
                            value: '${donations.length}',
                            icon: Icons.favorite,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DonationSummaryCard(
                            title: 'Last Donation',
                            value: lastDonationDate == null
                                ? '-'
                                : '${lastDonationDate.day}/${lastDonationDate.month}/${lastDonationDate.year}',
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Before donating again, confirm your eligibility with a qualified healthcare professional.',
                              style: TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Donation Records',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (donations.isEmpty)
                      _emptyState(
                        icon: Icons.bloodtype_outlined,
                        title: 'No donations recorded',
                        message:
                            'When you donate blood, use the button below to keep your history updated.',
                      )
                    else
                      ...donations.map((doc) {
                        final donation =
                            doc.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.bloodtype,
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donation['hospital'] ?? 'Hospital',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        donation['location'] ?? 'Location',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Donation date: ${_formatDate(donation['donationDate'])}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DonationFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Record New Donation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DonationSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DonationSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
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
}
class DonationFormScreen extends StatelessWidget {
  const DonationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
      ),
      body: const Center(
        child: Text(
          'Donation history is not available right now.',
        ),
      ),
    );
  }
}
class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final hospitalController = TextEditingController();
  final locationController = TextEditingController();

  String? selectedBloodGroup;
  bool isEmergency = false;
  bool isSaving = false;

  final bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    hospitalController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> createRequest() async {
    if (selectedBloodGroup == null ||
        hospitalController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all details.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final requestRef =
          await FirebaseFirestore.instance.collection('bloodRequests').add({
        'userId': user.uid,
        'bloodGroup': selectedBloodGroup,
        'hospital': hospitalController.text.trim(),
        'location': locationController.text.trim(),
        'status': 'Open',
        'isEmergency': isEmergency,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (isEmergency) {
        final donors = await FirebaseFirestore.instance
            .collection('users')
            .where('bloodGroup', isEqualTo: selectedBloodGroup)
            .where('donorAvailable', isEqualTo: true)
            .get();

        for (final donor in donors.docs) {
          if (donor.id == user.uid) continue;

          await FirebaseFirestore.instance
              .collection('notifications')
              .add({
            'userId': donor.id,
            'title': 'Emergency Blood Request',
            'message':
                'An emergency ${selectedBloodGroup!} blood request was created at ${hospitalController.text.trim()}.',
            'requestId': requestRef.id,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEmergency
                ? 'Emergency request created and matching donors notified!'
                : 'Blood request created successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create request: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB71C1C),
                        Color(0xFFE53935),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.bloodtype,
                        color: Colors.white,
                        size: 42,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Blood?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Create a request so matching donors can help.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Required Blood Group',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  items: bloodGroups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedBloodGroup = value);
                  },
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital / Blood Bank',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'City / Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 14),

                Card(
                  margin: EdgeInsets.zero,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    secondary: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    title: const Text(
                      'Emergency Request',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Notify available matching donors immediately.',
                    ),
                    value: isEmergency,
                    onChanged: (value) {
                      setState(() => isEmergency = value);
                    },
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : createRequest,
                    icon: isSaving
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      isSaving
                          ? 'Creating Request...'
                          : isEmergency
                              ? 'Create Emergency Request'
                              : 'Create Blood Request',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BloodRequestsScreen extends StatelessWidget {
  const BloodRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load requests: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return _emptyState(
              icon: Icons.bloodtype_outlined,
              title: 'No blood requests yet',
              message: 'New blood requests will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final request = doc.data() as Map<String, dynamic>;
              final bloodGroup = request['bloodGroup'] ?? '-';
              final status = request['status'] ?? 'Open';
              final emergency = request['isEmergency'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _bloodChip(bloodGroup),
                          const SizedBox(width: 8),
                          _statusChip(status),
                          const Spacer(),
                          if (emergency)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 15,
                                    color: Color(0xFFB71C1C),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Emergency',
                                    style: TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        request['hospital'] ?? 'Hospital',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              request['location'] ?? 'Location',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Created: ${_formatDateTime(request['createdAt'])}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MyBloodRequestsScreen extends StatelessWidget {
  const MyBloodRequestsScreen({super.key});

  Future<void> updateRequestStatus(
    BuildContext context,
    String requestId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestId)
          .update({'status': status});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'Completed'
                ? 'Blood request marked as completed!'
                : 'Blood request cancelled!',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blood Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load your requests: ${snapshot.error}'),
            );
          }

          final requests = [...(snapshot.data?.docs ?? [])];

          requests.sort((a, b) {
            final adata = a.data() as Map<String, dynamic>;
            final bdata = b.data() as Map<String, dynamic>;
            final at = adata['createdAt'];
            final bt = bdata['createdAt'];

            if (at is Timestamp && bt is Timestamp) {
              return bt.compareTo(at);
            }
            return 0;
          });

          if (requests.isEmpty) {
            return _emptyState(
              icon: Icons.assignment_outlined,
              title: 'No requests created',
              message:
                  'Your blood requests will appear here after you create one.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final request = doc.data() as Map<String, dynamic>;
              final bloodGroup = request['bloodGroup'] ?? '-';
              final location = request['location'] ?? '-';
              final status = request['status'] ?? 'Open';
              final emergency = request['isEmergency'] == true;
              final active =
                  status == 'Open' || status == 'Donor Found';

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _bloodChip(bloodGroup),
                          const SizedBox(width: 8),
                          _statusChip(status),
                          const Spacer(),
                          if (emergency)
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFB71C1C),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        request['hospital'] ?? 'Hospital',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Location: $location',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Created: ${_formatDateTime(request['createdAt'])}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (active)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DonorMatchingScreen(
                                      bloodGroup: bloodGroup,
                                      requestLocation: location,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people_alt, size: 18),
                              label: const Text('Find Donors'),
                            ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DonorResponsesScreen(
                                    requestId: doc.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.volunteer_activism, size: 18),
                            label: const Text('Responses'),
                          ),
                          if (active)
                            ElevatedButton.icon(
                              onPressed: () => updateRequestStatus(
                                context,
                                doc.id,
                                'Completed',
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Complete'),
                            ),
                          if (active)
                            TextButton.icon(
                              onPressed: () => updateRequestStatus(
                                context,
                                doc.id,
                                'Cancelled',
                              ),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Cancel'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DonorMatchingScreen extends StatefulWidget {
  final String bloodGroup;
  final String requestLocation;

  const DonorMatchingScreen({
    super.key,
    required this.bloodGroup,
    required this.requestLocation,
  });

  @override
  State<DonorMatchingScreen> createState() => _DonorMatchingScreenState();
}

class _DonorMatchingScreenState extends State<DonorMatchingScreen> {
  bool sameLocationOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Donors'),
        actions: [
          Row(
            children: [
              const Text(
                'Same location',
                style: TextStyle(fontSize: 12),
              ),
              Switch(
                value: sameLocationOnly,
                onChanged: (value) {
                  setState(() => sameLocationOnly = value);
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('bloodGroup', isEqualTo: widget.bloodGroup)
            .where('donorAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Could not load donors: ${snapshot.error}'));
          }

          final donors = snapshot.data?.docs ?? [];

          final filteredDonors = sameLocationOnly
              ? donors.where((doc) {
                  final donor = doc.data() as Map<String, dynamic>;
                  return donor['location'] == widget.requestLocation;
                }).toList()
              : donors;

          if (filteredDonors.isEmpty) {
            return _emptyState(
              icon: Icons.person_search,
              title: 'No matching donors',
              message: sameLocationOnly
                  ? 'No ${widget.bloodGroup} donors are available in this location.'
                  : 'No available ${widget.bloodGroup} donors were found.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: filteredDonors.length,
            itemBuilder: (context, index) {
              final donorDoc = filteredDonors[index];
              final donor = donorDoc.data() as Map<String, dynamic>;
              final sameLocation =
                  donor['location'] == widget.requestLocation;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _profileAvatar(
                        imageData: donor['profileImage'] as String?,
                        radius: 30,
                        background: const Color(0xFFFFEBEE),
                        iconColor: const Color(0xFFB71C1C),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    donor['fullName'] ?? 'Donor',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _bloodChip(
                                  donor['bloodGroup'] ?? widget.bloodGroup,
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              donor['location'] ?? 'Location not available',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  sameLocation
                                      ? Icons.location_on
                                      : Icons.location_searching,
                                  size: 16,
                                  color: sameLocation
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sameLocation
                                      ? 'Same location as request'
                                      : 'Different location',
                                  style: TextStyle(
                                    color: sameLocation
                                        ? Colors.green
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DonorResponsesScreen extends StatelessWidget {
  final String requestId;

  const DonorResponsesScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Responses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donorResponses')
            .where('requestId', isEqualTo: requestId)
            .where('response', isEqualTo: 'I Can Donate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Could not load responses: ${snapshot.error}'));
          }

          final responses = snapshot.data?.docs ?? [];

          if (responses.isEmpty) {
            return _emptyState(
              icon: Icons.volunteer_activism_outlined,
              title: 'No donor responses yet',
              message:
                  'When a matching donor volunteers, their response will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response =
                  responses[index].data() as Map<String, dynamic>;

              final donorName = response['donorName'] ?? 'Donor';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _profileAvatar(
                            imageData:
                                response['donorProfileImage'] as String?,
                            radius: 28,
                            background: const Color(0xFFE8F5E9),
                            iconColor: Colors.green,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              donorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _bloodChip(
                            response['donorBloodGroup'] ?? '-',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ResponseInfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Donor Location',
                        value: response['donorLocation'] ?? '-',
                      ),
                      _ResponseInfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Hospital',
                        value: response['hospital'] ?? '-',
                      ),
                      _ResponseInfoRow(
                        icon: Icons.place_outlined,
                        label: 'Request Location',
                        value: response['requestLocation'] ?? '-',
                      ),
                      _ResponseInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Donor ID',
                        value: response['donorId'] ?? '-',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ResponseInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResponseInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class DonorBloodRequestsScreen extends StatelessWidget {
  final String bloodGroup;

  const DonorBloodRequestsScreen({
    super.key,
    required this.bloodGroup,
  });

  Future<void> respondToRequest(
    BuildContext context,
    QueryDocumentSnapshot requestDoc,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      final request =
          requestDoc.data() as Map<String, dynamic>;

      final existing = await FirebaseFirestore.instance
          .collection('donorResponses')
          .where('requestId', isEqualTo: requestDoc.id)
          .get();

      final alreadyResponded = existing.docs.any((doc) {
        final data = doc.data();
        return data['donorId'] == user.uid &&
            data['response'] == 'I Can Donate';
      });

      if (alreadyResponded) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already responded to this request.'),
          ),
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance.collection('donorResponses').add({
        'requestId': requestDoc.id,
        'requesterId': request['userId'],
        'requestBloodGroup': request['bloodGroup'],
        'hospital': request['hospital'],
        'requestLocation': request['location'],
        'donorId': user.uid,
        'donorName': userData['fullName'] ?? 'Donor',
        'donorBloodGroup': userData['bloodGroup'] ?? '',
        'donorLocation': userData['location'] ?? '',
        'donorProfileImage': userData['profileImage'],
        'response': 'I Can Donate',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': request['userId'],
        'title': 'Donor Found',
        'message':
            '${userData['fullName'] ?? 'A donor'} can donate for your ${request['bloodGroup'] ?? ''} blood request.',
        'requestId': requestDoc.id,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestDoc.id)
          .update({'status': 'Donor Found'});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your donation response was sent successfully!'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save response: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$bloodGroup Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('bloodGroup', isEqualTo: bloodGroup)
            .where('status', isEqualTo: 'Open')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Could not load requests: ${snapshot.error}'));
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return _emptyState(
              icon: Icons.volunteer_activism_outlined,
              title: 'No matching requests',
              message:
                  'There are no open $bloodGroup blood requests right now.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestDoc = requests[index];
              final request =
                  requestDoc.data() as Map<String, dynamic>;
              final emergency = request['isEmergency'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _bloodChip(
                            request['bloodGroup'] ?? bloodGroup,
                          ),
                          if (emergency) ...[
                            const SizedBox(width: 8),
                            const Text(
                              'EMERGENCY',
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        request['hospital'] ?? 'Hospital',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Location: ${request['location'] ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Created: ${_formatDateTime(request['createdAt'])}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              respondToRequest(context, requestDoc),
                          icon: const Icon(Icons.volunteer_activism),
                          label: const Text('I Can Donate'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget statCard({
    required String title,
    required String collection,
    String? field,
    dynamic value,
    required IconData icon,
    required Color color,
  }) {
    Stream<QuerySnapshot> stream;

    if (field != null) {
      stream = FirebaseFirestore.instance
          .collection(collection)
          .where(field, isEqualTo: value)
          .snapshots();
    } else {
      stream = FirebaseFirestore.instance
          .collection(collection)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget adminAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget page,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openPage(context, page),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Emergency Requests',
            onPressed: () =>
                openPage(context, const AdminEmergencyScreen()),
            icon: const Icon(Icons.warning_amber_rounded),
          ),
          IconButton(
            tooltip: 'Donor Responses',
            onPressed: () =>
                openPage(context, const AdminDonorResponsesScreen()),
            icon: const Icon(Icons.volunteer_activism),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF263238),
                        Color(0xFF455A64),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 29,
                        backgroundColor: Colors.white12,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BloodConnect Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Monitor users, requests, donors and emergencies.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Live Overview',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 800 ? 2 : 1;
                    const gap = 12.0;
                    final width =
                        (constraints.maxWidth - (gap * (columns - 1))) /
                            columns;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Total Users',
                            collection: 'users',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Available Donors',
                            collection: 'users',
                            field: 'donorAvailable',
                            value: true,
                            icon: Icons.volunteer_activism,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Total Requests',
                            collection: 'bloodRequests',
                            icon: Icons.bloodtype,
                            color: const Color(0xFFB71C1C),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Open Requests',
                            collection: 'bloodRequests',
                            field: 'status',
                            value: 'Open',
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Donor Found',
                            collection: 'bloodRequests',
                            field: 'status',
                            value: 'Donor Found',
                            icon: Icons.favorite,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Completed',
                            collection: 'bloodRequests',
                            field: 'status',
                            value: 'Completed',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Cancelled',
                            collection: 'bloodRequests',
                            field: 'status',
                            value: 'Cancelled',
                            icon: Icons.cancel,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: statCard(
                            title: 'Donor Responses',
                            collection: 'donorResponses',
                            icon: Icons.volunteer_activism,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 26),

                const Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 800 ? 2 : 1;
                    const gap = 12.0;
                    final width =
                        (constraints.maxWidth - (gap * (columns - 1))) /
                            columns;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: adminAction(
                            context: context,
                            icon: Icons.people,
                            title: 'Manage Users',
                            subtitle: 'Verify, filter and manage profiles',
                            color: Colors.blue,
                            page: const AdminUsersScreen(),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: adminAction(
                            context: context,
                            icon: Icons.bloodtype,
                            title: 'Blood Requests',
                            subtitle: 'Review and update request status',
                            color: const Color(0xFFB71C1C),
                            page: const AdminBloodRequestsScreen(),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: adminAction(
                            context: context,
                            icon: Icons.warning_amber_rounded,
                            title: 'Emergency Requests',
                            subtitle: 'Review urgent requests',
                            color: Colors.orange,
                            page: const AdminEmergencyScreen(),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: adminAction(
                            context: context,
                            icon: Icons.volunteer_activism,
                            title: 'Donor Responses',
                            subtitle: 'See who can donate',
                            color: Colors.green,
                            page: const AdminDonorResponsesScreen(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminBloodRequestsScreen extends StatefulWidget {
  const AdminBloodRequestsScreen({super.key});

  @override
  State<AdminBloodRequestsScreen> createState() =>
      _AdminBloodRequestsScreenState();
}

class _AdminBloodRequestsScreenState
    extends State<AdminBloodRequestsScreen> {
  String selectedStatus = 'All';

  final statuses = const [
    'All',
    'Open',
    'Donor Found',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load requests: ${snapshot.error}'),
            );
          }

          final allRequests = snapshot.data?.docs ?? [];

          final requests = selectedStatus == 'All'
              ? allRequests
              : allRequests.where((doc) {
                  final request =
                      doc.data() as Map<String, dynamic>;
                  return request['status'] == selectedStatus;
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    prefixIcon: Icon(Icons.filter_alt),
                  ),
                  items: statuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
              ),
              Expanded(
                child: requests.isEmpty
                    ? _emptyState(
                        icon: Icons.bloodtype_outlined,
                        title: 'No requests found',
                        message:
                            'No blood requests match the selected filter.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final doc = requests[index];
                          final request =
                              doc.data() as Map<String, dynamic>;
                          final status = request['status'] ?? 'Open';
                          final emergency =
                              request['isEmergency'] == true;

                          return FutureBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(request['userId'])
                                .get(),
                            builder: (context, userSnapshot) {
                              final userData = userSnapshot.data?.data();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _bloodChip(
                                            request['bloodGroup'] ?? '-',
                                          ),
                                          const SizedBox(width: 8),
                                          _statusChip(status),
                                          if (emergency) ...[
                                            const Spacer(),
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Color(0xFFB71C1C),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 13),
                                      Text(
                                        request['hospital'] ?? 'Hospital',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Requester: ${userData?['fullName'] ?? 'Unknown User'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Location: ${request['location'] ?? '-'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Created: ${_formatDateTime(request['createdAt'])}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 13),
                                      DropdownButtonFormField<String>(
                                        value: status,
                                        decoration: const InputDecoration(
                                          labelText: 'Update Status',
                                          prefixIcon: Icon(Icons.sync),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Open',
                                            child: Text('Open'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Donor Found',
                                            child: Text('Donor Found'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Completed',
                                            child: Text('Completed'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Cancelled',
                                            child: Text('Cancelled'),
                                          ),
                                        ],
                                        onChanged: (newStatus) async {
                                          if (newStatus == null) return;

                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('bloodRequests')
                                                .doc(doc.id)
                                                .update({
                                              'status': newStatus,
                                            });

                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Request updated to $newStatus.',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not update request: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String selectedBloodGroup = 'All';

  final bloodGroups = const [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load users: ${snapshot.error}'),
            );
          }

          final allUsers = snapshot.data?.docs ?? [];

          final users = selectedBloodGroup == 'All'
              ? allUsers
              : allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['bloodGroup'] == selectedBloodGroup;
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Blood Group',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  items: bloodGroups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedBloodGroup = value);
                    }
                  },
                ),
              ),
              Expanded(
                child: users.isEmpty
                    ? _emptyState(
                        icon: Icons.people_outline,
                        title: 'No users found',
                        message:
                            'No users match the selected blood group.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final doc = users[index];
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final isVerified = data['verified'] == true;
                          final donorAvailable =
                              data['donorAvailable'] == true;
                          final isAdmin = data['isAdmin'] == true;
                          final isCurrent = doc.id == currentUid;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _profileAvatar(
                                        imageData:
                                            data['profileImage'] as String?,
                                        radius: 29,
                                        background:
                                            const Color(0xFFFFEBEE),
                                        iconColor:
                                            const Color(0xFFB71C1C),
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data['fullName'] ??
                                                        'No Name',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                if (isAdmin)
                                                  const Icon(
                                                    Icons.admin_panel_settings,
                                                    size: 18,
                                                    color: Colors.blueGrey,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              data['email'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${data['phone'] ?? '-'} • ${data['location'] ?? '-'}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 9),
                                            Wrap(
                                              spacing: 7,
                                              runSpacing: 7,
                                              children: [
                                                _bloodChip(
                                                  data['bloodGroup'] ?? '-',
                                                ),
                                                _statusChip(
                                                  donorAvailable
                                                      ? 'Donor Available'
                                                      : 'Donor Off',
                                                ),
                                                if (isVerified)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 9,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withOpacity(0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Text(
                                                      'Verified',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Verified User',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: isVerified,
                                        onChanged: (value) async {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(doc.id)
                                              .update({
                                            'verified': value,
                                          });
                                        },
                                      ),
                                      if (!isCurrent)
                                        IconButton(
                                          tooltip: 'Delete profile',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Delete User Profile?',
                                                  ),
                                                  content: Text(
                                                    'Delete the Firestore profile for ${data['fullName'] ?? 'this user'}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                        false,
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                        true,
                                                      ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm != true) return;

                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(doc.id)
                                                .delete();

                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'User profile deleted.',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminEmergencyScreen extends StatelessWidget {
  const AdminEmergencyScreen({super.key});

  Future<void> clearEmergency(
    BuildContext context,
    String requestId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(requestId)
          .update({'status': 'Cancelled'});

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency request cleared.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not clear request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('status', isEqualTo: 'Open')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Could not load emergencies: ${snapshot.error}'));
          }

          final requests = (snapshot.data?.docs ?? []).where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isEmergency'] == true;
          }).toList();

          if (requests.isEmpty) {
            return _emptyState(
              icon: Icons.warning_amber_rounded,
              title: 'No active emergencies',
              message:
                  'Emergency requests created by users will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final request = doc.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(request['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFB71C1C),
                                size: 28,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  '${request['bloodGroup'] ?? '-'} Emergency',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              _statusChip(
                                request['status'] ?? 'Open',
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'Requester: ${userData?['fullName'] ?? 'Unknown User'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hospital: ${request['hospital'] ?? '-'}',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Location: ${request['location'] ?? '-'}',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Created: ${_formatDateTime(request['createdAt'])}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  clearEmergency(context, doc.id),
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Emergency'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AdminDonorResponsesScreen extends StatelessWidget {
  const AdminDonorResponsesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Responses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donorResponses')
            .where('response', isEqualTo: 'I Can Donate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load responses: ${snapshot.error}'),
            );
          }

          final responses = snapshot.data?.docs ?? [];

          if (responses.isEmpty) {
            return _emptyState(
              icon: Icons.volunteer_activism_outlined,
              title: 'No donor responses',
              message:
                  'Responses from donors will appear here when they volunteer.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response =
                  responses[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileAvatar(
                        imageData:
                            response['donorProfileImage'] as String?,
                        radius: 28,
                        background: const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    response['donorName'] ?? 'Donor',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _bloodChip(
                                  response['donorBloodGroup'] ?? '-',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Donor Location: ${response['donorLocation'] ?? '-'}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Hospital: ${response['hospital'] ?? '-'}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Request Location: ${response['requestLocation'] ?? '-'}',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Responded: ${_formatDateTime(response['createdAt'])}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> markAllRead(
    List<QueryDocumentSnapshot> notifications,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in notifications) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['read'] != true) {
        batch.update(
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(doc.id),
          {'read': true},
        );
      }
    }

    await batch.commit();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final unread = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['read'] != true;
              }).length;

              if (unread == 0) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () => markAllRead(docs),
                icon: const Icon(
                  Icons.done_all,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Read all',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load notifications: ${snapshot.error}',
              ),
            );
          }

          final notifications = [...(snapshot.data?.docs ?? [])];

          notifications.sort((a, b) {
            final adata = a.data() as Map<String, dynamic>;
            final bdata = b.data() as Map<String, dynamic>;
            final at = adata['createdAt'];
            final bt = bdata['createdAt'];

            if (at is Timestamp && bt is Timestamp) {
              return bt.compareTo(at);
            }
            return 0;
          });

          if (notifications.isEmpty) {
            return _emptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message:
                  'Important donor and blood-request updates will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final notification =
                  doc.data() as Map<String, dynamic>;
              final unread = notification['read'] != true;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: unread ? const Color(0xFFFFF7F7) : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(doc.id)
                        .update({'read': true});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: unread
                                ? const Color(0xFFFFEBEE)
                                : Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            unread
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: unread
                                ? const Color(0xFFB71C1C)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification['title'] ??
                                          'Notification',
                                      style: TextStyle(
                                        fontWeight: unread
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (unread)
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFB71C1C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification['message'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                _formatDateTime(notification['createdAt']),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BloodConnect Map'),
      ),
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(16.5062, 80.6480),
              zoom: 12,
            ),
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Use the map to explore locations around the BloodConnect network.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
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
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created. Please verify your email before logging in.',
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email already has an account. Please log in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (at least 6 characters)',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
