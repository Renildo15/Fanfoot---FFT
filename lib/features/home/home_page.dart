import 'package:flutter/material.dart';
import 'package:fanfoot/scripts/populate_countries.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await syncCountries();
      print("Países sincronizados!");
    } catch (e) {
      print("Erro ao sincronizar países: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FANFOOT',
                  style: TextStyle(color: Colors.white, fontSize: 128),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text("Novo jogo"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.folder_open),
                  label: Text("Carregar jogo"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/editor');
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Editor"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
