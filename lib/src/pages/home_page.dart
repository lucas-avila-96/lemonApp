import 'package:flutter/material.dart';
import 'package:lemon/src/dbHelper/dbHelperSuscripciones.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../BaseDBHelper.dart';
import '../dbHelper/dbHelperUsuario.dart';
import '../widgets/SectionTitle.dart';
import '../widgets/recomendacions_carousel.dart';
import '../widgets/reserva_card.dart';
import '../widgets/mis_clases_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final UsuarioDBHelper _dbHelperUsuario = UsuarioDBHelper();
  final SubscriptionDBHelper _dbHelperSuscription = SubscriptionDBHelper();

  Map<String, dynamic>? suscripciones;
  int _clasesTotales = 0;
  int _clasesRestantes = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubscriptionData();
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<String> getUserName() async {
    int? userId = await getUserId();

    if (userId == null) {
      throw Exception('ID de usuario no disponible');
    }

    var user = await _dbHelperUsuario.getUserById(userId);

    if (user != null && user.containsKey('first_name')) {
      return user['first_name'] as String;
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  Future<void> loadSubscriptionData() async {
    setState(() => isLoading = true);
    int? userId = await getUserId();
    if (userId == null) return;

    var subscription = await _dbHelperSuscription.getActiveSubscription(userId);
    if (subscription != null) {
      setState(() {
        suscripciones = subscription;
        _clasesTotales = subscription['total_classes'] ?? 0;
        _clasesRestantes = subscription['remaining_classes'] ?? 0;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Cargando...');
            } else if (snapshot.hasError) {
              return const Text('Error al cargar');
            } else if (snapshot.hasData) {
              return Text('¡Hola, ${snapshot.data}!');
            } else {
              return const Text('Usuario no encontrado');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'userProfile');
              },
              child: const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MisClasesCard(
                      suscripciones: suscripciones,
                      clasesTotales: _clasesTotales,
                      clasesRestantes: _clasesRestantes,
                    ),
              const SizedBox(height: 16),
              const SectionTitle(title: 'Programa tus próximos entrenamientos'),
              const ReservaCard(),
              const SizedBox(height: 16),
              const SectionTitle(title: 'Recomendaciones'),
              const SizedBox(height: 16),
              const RecomendacionesCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}
