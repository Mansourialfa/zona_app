import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
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
    
    // Demander les permissions au lancement
    requestPermissions();

    // Configuration spécifique pour Android
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050505))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) { setState(() { isLoading = true; }); },
          onPageFinished: (String url) { setState(() { isLoading = false; }); },
          onNavigationRequest: (NavigationRequest request) {
            // Autoriser les liens externes utiles
            if (request.url.startsWith('tel:') || 
                request.url.startsWith('mailto:') || 
                request.url.startsWith('whatsapp:') ||
                request.url.startsWith('https://www.google.com/maps/')) {
              return NavigationDecision.navigate; 
            }
            if (request.url.contains('zona.ma')) return NavigationDecision.navigate;
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://zona.ma'));

    // Autoriser la page web ZONA à utiliser les capteurs du téléphone
    if (controller.platform is AndroidWebViewController) {
      final myAndroidController = (controller.platform as AndroidWebViewController);
      
      // Accorde automatiquement l'accès Caméra/Micro quand la WebView le demande
      myAndroidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) {
          request.grant();
        },
      );
      
      // Accorde le GPS automatiquement
      myAndroidController.setGeolocationPermissionsShowPrompt(
        (String origin) async {
          return const GeolocationPermissionsResponse(allow: true, retain: true);
        }
      );
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.notification,
    ].request();
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
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
          ],
        ),
      ),
    );
  }
}