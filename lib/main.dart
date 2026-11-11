import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'providers/usuario_provider.dart';
import 'providers/estante_provider.dart';
import 'view/Bases/cadastro_usuario_view.dart';
import 'view/Bases/login_view.dart';
import 'view/Bases/perfil_view.dart';
import 'view/Bases/recuperar_senha_view.dart';
import 'view/Bases/sobre_view.dart';
import 'view/Extras/inicio_view.dart';
import 'view/Extras/publicar_view.dart';
import 'view/Extras/estante_view.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => EstanteProvider()),
      ],
      child: DevicePreview(
        builder: (context) => const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',

      //
      // ROTAS
      //
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginView(),
        'cadastro_usuario': (context) => const CadastroUsuarioView(),
        'perfil': (context) => const PerfilView(),
        'recuperar_senha': (context) => const RecuperarSenhaView(),
        'sobre': (context) => const SobreView(),
        'inicio': (context) => const InicioView(),
        'publicar': (context) => const PublicarView(),
        'estante': (context) => const EstanteView(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => LoginView(),
        );
      },
    );
  }
}
