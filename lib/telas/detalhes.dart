import 'dart:convert';

import 'package:coffeestore/estado.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:toast/toast.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

enum _EstadoCafe { naoVerificado, temCafe, semCafe }

class _DetalhesState extends State<Detalhes> {
  late dynamic _feedEstatico;
  late dynamic _comentariosEstaticos;

  _EstadoCafe _temCafe = _EstadoCafe.naoVerificado;
  late dynamic _cafe;

  List<dynamic> _comentarios = [];
  bool _carregandoComentarios = false;
  bool _temComentarios = false;

  late TextEditingController _controladorNovoComentario;

  late PageController _controladorSlides;
  late int _slideSelecionado;

  bool _curtiu = false;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _lerFeedEstatico();
    _iniciarSlides();

    _controladorNovoComentario = TextEditingController();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerFeedEstatico() async {
    String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    conteudoJson =
        await rootBundle.loadString("lib/recursos/json/comentarios.json");
    _comentariosEstaticos = await json.decode(conteudoJson);

    _carregarCafe();
    _carregarComentarios();
  }

  void _carregarCafe() {
    setState(() {
      _cafe = _feedEstatico['cafes']
          .firstWhere((cafe) => cafe["_id"] == estadoApp.idCafe);

      _temCafe = _cafe != null
          ? _EstadoCafe.temCafe
          : _EstadoCafe.semCafe;
    });
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    var maisComentarios = [];
    _comentariosEstaticos["comentarios"].where((item) {
      return item["feed"] == estadoApp.idCafe;
    }).forEach((item) {
      maisComentarios.add(item);
    });

    setState(() {
      _carregandoComentarios = false;
      _comentarios = maisComentarios;

      _temComentarios = _comentarios.isNotEmpty;
    });
  }

  Widget _exibirMensagemCafeInexistente() {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text("Coffee Store"))
                  ]),
                  GestureDetector(
                      onTap: () {
                        estadoApp.mostrarCafes();
                      },
                      child: const Icon(Icons.arrow_back))
                ])),
        body: const SizedBox.expand(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error, size: 32, color: Colors.red),
          Text("café inexistente :(",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red)),
          Text("selecione outro café na tela anterior",
              style: TextStyle(fontSize: 14))
        ])));
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error, size: 32, color: Colors.red),
      Text("não existem comentários",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red))
    ]));
  }

  Widget _exibirComentarios() {
    return Expanded(
        child: FlatList(
      data: _comentarios,
      loading: _carregandoComentarios,
      buildItem: (item, index) {
        String dataFormatada = DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(item["datetime"]));
        bool usuarioLogadoComentou = estadoApp.usuario != null &&
            estadoApp.usuario!.email == item["user"]["email"];

        return Dismissible(
          key: Key(item["_id"].toString()),
          direction: usuarioLogadoComentou
              ? DismissDirection.endToStart
              : DismissDirection.none,
          background: Container(
              alignment: Alignment.centerRight,
              child: const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.delete, color: Colors.red))),
          child: Card(
              color: usuarioLogadoComentou ? Colors.green[100] : Colors.white,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(item["content"],
                            style: const TextStyle(fontSize: 12)))),
                Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.only(right: 10.0, left: 6.0),
                            child: Text(
                              dataFormatada,
                              style: const TextStyle(fontSize: 12),
                            )),
                        Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              item["user"]["name"],
                              style: const TextStyle(fontSize: 12),
                            )),
                      ],
                    )),
              ])),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              final comentario = item;
              setState(() {
                _comentarios.removeAt(index);
              });

              showDialog(
                  context: context,
                  builder: (BuildContext contexto) {
                    return AlertDialog(
                      title: const Text("Deseja apagar o comentário?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _comentarios.insert(index, comentario);
                              });

                              Navigator.of(contexto).pop();
                            },
                            child: const Text("NÃO")),
                        TextButton(
                            onPressed: () {
                              setState(() {});

                              Navigator.of(contexto).pop();
                            },
                            child: const Text("SIM"))
                      ],
                    );
                  });
            }
          },
        );
      },
    ));
  }

  void _adicionarComentario() {
    String conteudo = _controladorNovoComentario.text.trim();
    if (conteudo.isNotEmpty) {
      final comentario = {
        "content": conteudo,
        "user": {
          "name": estadoApp.usuario!.nome,
          "email": estadoApp.usuario!.email,
        },
        "datetime": DateTime.now().toString(),
        "feed": estadoApp.idCafe
      };

      setState(() {
        _comentarios.insert(0, comentario);
      });

      _controladorNovoComentario.clear();
    } else {
      Toast.show("Digite um comentário",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  Widget _exibirCafe() {

    String avatarPath = "lib/recursos/imagens/${_cafe["company"]["avatar"]}";
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Row(children: [
            Image.asset(avatarPath, width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _cafe["company"]["name"],
                  style: const TextStyle(fontSize: 15),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              estadoApp.mostrarCafes();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(children: [
              PageView.builder(
                itemCount: 3,
                controller: _controladorSlides,
                onPageChanged: (slide) {
                  setState(() {
                    _slideSelecionado = slide;
                  });
                },
                itemBuilder: (context, pagePosition) {
                  return Image.asset(
                    "lib/recursos/imagens/${_cafe["coffee"]["blobs"][pagePosition]["file"].toString()}",
                    fit: BoxFit.cover,
                  );
                },
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Column(children: [
                    usuarioLogado
                        ? IconButton(
                            onPressed: () {
                              if (_curtiu) {
                                setState(() {
                                  _cafe['likes'] = _cafe['likes'] - 1;

                                  _curtiu = false;
                                });
                              } else {
                                setState(() {
                                  _cafe['likes'] = _cafe['likes'] + 1;

                                  _curtiu = true;
                                });

                                Toast.show("Obrigado pela avaliação",
                                    duration: Toast.lengthLong,
                                    gravity: Toast.bottom);
                              }
                            },
                            icon: Icon(_curtiu
                                ? Icons.favorite
                                : Icons.favorite_border),
                            color: Colors.red,
                            iconSize: 26)
                        : const SizedBox.shrink(),
                    IconButton(
                        onPressed: () {
                          final texto =
                              '${_cafe["coffee"]["name"]} por R\$ ${_cafe["coffee"]["price"].toString()} disponível na Coffee Store.\n\n\nBaixe o Coffee Store App na PlayStore!';

                          FlutterShare.share(
                              title: "Coffee Store", text: texto);
                        },
                        icon: const Icon(Icons.share),
                        color: Colors.blue,
                        iconSize: 26)
                  ]))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PageViewDotIndicator(
              currentItem: _slideSelecionado,
              count: 3,
              unselectedColor: Colors.black26,
              selectedColor: Colors.blue,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _cafe["coffee"]["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(_cafe["coffee"]["description"],
                        style: const TextStyle(fontSize: 12))),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                    child: Row(children: [
                      Text(
                        "R\$ ${_cafe["coffee"]["price"].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                Text(
                                  _cafe["likes"].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ]))
                    ]))
              ],
            ),
          ),
          const Center(
              child: Text(
            "Comentários",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )),
          usuarioLogado
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                      controller: _controladorNovoComentario,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 0.0),
                          ),
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 14),
                          hintText: 'Digite aqui seu comentário...',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _adicionarComentario();
                              },
                              child: const Icon(Icons.send,
                                  color: Colors.black87)))))
              : const SizedBox.shrink(),
          _temComentarios
              ? _exibirComentarios()
              : _exibirMensagemComentariosInexistentes()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget detalhes = const SizedBox.shrink();

    if (_temCafe == _EstadoCafe.naoVerificado) {
      detalhes = const SizedBox.shrink();
    } else if (_temCafe == _EstadoCafe.temCafe) {
      detalhes = _exibirCafe();
    } else {
      detalhes = _exibirMensagemCafeInexistente();
    }

    return detalhes;
  }
}
