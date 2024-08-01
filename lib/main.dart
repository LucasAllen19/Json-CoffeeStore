import 'package:coffeestore/estado.dart';
import 'package:coffeestore/telas/detalhes.dart';
import 'package:coffeestore/telas/cafes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
 

  runApp(const CoffeeStore());
}

class CoffeeStore extends StatelessWidget {
  const CoffeeStore({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => EstadoApp(),
        child: MaterialApp(
          title: "Coffee Store",
          theme: ThemeData(
              colorScheme: const ColorScheme.light(), useMaterial3: true),
          home: const Tela(),
        ));
  }
}

class Tela extends StatefulWidget {
  const Tela({super.key});

  @override
  State<Tela> createState() => _TelaState();
}

class _TelaState extends State<Tela> {
  void _exibirComoRetrato() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _exibirComoRetrato();

    estadoApp = context.watch<EstadoApp>();

    Widget tela = const SizedBox.shrink();
    if (estadoApp.situacao == Situacao.mostrandoCafes){
      tela = const Cafes();
    } else if (estadoApp.situacao == Situacao.mostrandoDetalhes) {
      tela = const Detalhes();
    }

    return tela;
  }
}
