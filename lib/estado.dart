// ignore_for_file: unnecessary_getters_setters

import 'package:coffeestore/autenticador.dart';
import 'package:flutter/material.dart';

enum Situacao { mostrandoCafes, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoCafes;
  Situacao get situacao => _situacao;
  // set situacao(Situacao situacao) {
  //   _situacao = situacao;
  // }

  late int _idCafe;
  int get idCafe => _idCafe;
  // set idCafe(int idCafe) {
  //   _idCafe = idCafe;
  // }

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
  }

  void mostrarCafes() {
    _situacao = Situacao.mostrandoCafes;

    notifyListeners();
  }

  void mostrarDetalhes(int idCafe) {
    _situacao = Situacao.mostrandoDetalhes;
    _idCafe = idCafe;

    notifyListeners();
  }

  void onLogin(Usuario usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void onLogout() {
    _usuario = null;

    notifyListeners();
  }

  // bool temUsuarioLogado() {
  //   return _usuario != null;
  // }
}

late EstadoApp estadoApp;
