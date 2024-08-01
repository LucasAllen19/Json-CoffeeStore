import 'dart:convert';

import 'package:coffeestore/autenticador.dart';
import 'package:coffeestore/componentes/cafecard.dart';
import 'package:coffeestore/estado.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

const int tamanhoPagina = 5;

class Cafes extends StatefulWidget {
  const Cafes({super.key});

  @override
  State<StatefulWidget> createState() => _CafesState(); 
}

class _CafesState extends State<Cafes> {
  late dynamic _feedEstatico;
  List<dynamic> _cafes = [];

  int _proximaPagina = 1;
  bool _carregando = false;

  late TextEditingController _controladorFiltragem;
  String _filtro = "";

  @override
  void initState() {
    ToastContext().init(context);

    _controladorFiltragem = TextEditingController();
    _lerFeedEstatico();

    super.initState();
  }

  

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    _carregarCafes();
  }

  void _carregarCafes() {
    setState(() {
      _carregando = true;
    });

    var maisCafes = [];
    if (_filtro.isNotEmpty) {
      _feedEstatico["cafes"].where((item) {
        String nome = item["coffee"]["name"];

        return nome.toLowerCase().contains(_filtro.toLowerCase());
      }).forEach((item) {
        maisCafes.add(item);
      });
    } else {
      maisCafes = _cafes;

      final totalCafesParaCarregar = _proximaPagina * tamanhoPagina;
      if (_feedEstatico["cafes"].length >= totalCafesParaCarregar) {
        maisCafes =
            _feedEstatico["cafes"].sublist(0, totalCafesParaCarregar);
      }
    }

    setState(() {
      _cafes = maisCafes;
      _proximaPagina = _proximaPagina + 1;

      _carregando = false;
    });
  }

  Future<void> _atualizarCafes() async {
    _cafes = [];
    _proximaPagina = 1;

    _carregarCafes();
  }

  @override
  Widget build(BuildContext context) {
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 60, right: 20),
                    child: TextField(
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.top,
                      controller: _controladorFiltragem,
                      onSubmitted: (descricao) {
                        _filtro = descricao;
                        _atualizarCafes();
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search)),
                    ))),
              usuarioLogado
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        estadoApp.onLogout();
                      });

                      Toast.show("Você não está mais conectado",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    },
                    icon: const Icon(Icons.logout))
                : IconButton(
                    onPressed: () {
                      Usuario usuario =
                          Usuario("Lucas Vieira", "lucasvieira1@gmail.com");

                      setState(() {
                        estadoApp.onLogin(usuario);
                      });

                      Toast.show("Você foi conectado com sucesso",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    },
                    icon: const Icon(Icons.login))
            // Padding(
            //     padding: const EdgeInsets.only(right: 10.0),
            //     child: estadoApp.temUsuarioLogado()
            //         ? GestureDetector(
            //             onTap: () {
            //               Autenticador.logout().then((_) {
            //                 Toast.show("Você foi desconectado com sucesso",
            //                 duration: Toast.lengthLong, gravity: Toast.bottom);
            //                 setState(() {
            //                   estadoApp.onLogout();
            //                 });
            //               });
            //             },
            //             child: const Icon(
            //                 color: Colors.orange, Icons.logout, size: 30))
            //         : GestureDetector(
            //             onTap: () {
            //               Autenticador.login().then((usuario) {
            //                 Toast.show("Você foi conectado com sucesso",
            //                 duration: Toast.lengthLong, gravity: Toast.bottom);
            //                 setState(() {
            //                   estadoApp.onLogin(usuario);
            //                 });
            //               });
            //             },
            //             child: const Icon(
            //                 color: Colors.orange, Icons.person, size: 30)))
          ],
        ),
         
        body: FlatList(
            data: _cafes,
            numColumns: 2,
            loading: _carregando,
            onRefresh: () {
              _filtro = "";
              _controladorFiltragem.clear();

              return _atualizarCafes();
            },
            onEndReached: () => _carregarCafes(),
            buildItem: (item, int indice) {
              return SizedBox(height: 420, child: CafeCard(cafe: item));
            }));
  }
}
