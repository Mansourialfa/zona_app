import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import pour définir la couleur de la barre de statut (optionnel)
import 'package:flutter/services.dart'; 

void main() {
  // Définir la couleur de la barre de statut en haut (noir pour coller à l'UI Zona)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ZonaApp());
}

class ZonaApp extends StatelessWidget {
  const ZonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZONA.MA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700)), // ZONA Gold
        useMaterial3: true,
      ),
      home: const ZonaWebView(),
    );
  }
}

class ZonaWebView extends StatefulWidget {
  const ZonaWebView({super.key});

  @override
  State<ZonaWebView> createState() => _ZonaWebViewState();
}

class _ZonaWebViewState extends State<ZonaWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050505)) // Couleur de fond noir ZONA
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() { isLoading = true; });
          },
          onPageFinished: (String url) {
            setState(() { isLoading = false; });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Permet de gérer tous les sous-domaines (go.zona.ma, job.zona.ma, etc.)
            if (request.url.contains('zona.ma')) {
              return NavigationDecision.navigate;
            }
            // Bloque ou ouvre les liens externes dans le navigateur du téléphone
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://zona.ma')); // VOTRE URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD700), // Spinner couleur Or
                ),
              ),
          ],
        ),
      ),
    );
  }
}