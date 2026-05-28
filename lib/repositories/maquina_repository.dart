import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maquina.dart';
import '../models/registro_vibracao.dart';

class MaquinaRepository extends ChangeNotifier {
  final Map<String, Maquina> _maquinas = {};
  final List<RegistroVibracao> _historicoAlertas = [];

  List<Maquina> get maquinas => _maquinas.values.toList();
  List<RegistroVibracao> get historicoAlertas => _historicoAlertas;

  final String urlSuaApiWs =
      dotenv.env['WEBSOCKET_URL'] ?? 'ws://localhost:3000';

  final FirebaseFirestore db = FirebaseFirestore.instance;

  MaquinaRepository() {
    _inicializarSistema();
  }

  Future<void> _inicializarSistema() async {
    await _carregarMaquinasDoFirebase();
    _conectarNaApi();
  }

  Future<void> _carregarMaquinasDoFirebase() async {
    try {
      print("Buscando máquinas no Firebase...");
      final snapshot = await db.collection('maquinas').get();

      for (var doc in snapshot.docs) {
        final dados = doc.data();

        _maquinas[doc.id] = Maquina(
          id: doc.id,
          nome: dados['nome'] ?? 'Máquina Desconhecida',
          setor: dados['setor'] ?? 'Sem Setor',
          vibracaoAtual: 0.0,
        );
      }
      notifyListeners();
      print("Máquinas carregadas com sucesso!");
    } catch (e) {
      print("Erro ao buscar máquinas no Firebase: $e");
    }
  }

  void _conectarNaApi() {
    try {
      print("Conectando ao WebSocket em: $urlSuaApiWs...");
      final channel = WebSocketChannel.connect(Uri.parse(urlSuaApiWs));

      channel.stream.listen(
        (mensagem) {
          final dadosDaApi = jsonDecode(mensagem);

          final String id = dadosDaApi['id_maquina'].toString();
          final double valor = (dadosDaApi['vibracao'] as num).toDouble();
          final bool isEmergencia = dadosDaApi['emergencia'] ?? false;

          if (_maquinas.containsKey(id)) {
            _maquinas[id]!.vibracaoAtual = valor;

            if (isEmergencia) {
              _historicoAlertas.insert(
                0,
                RegistroVibracao(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  idMaquina: id,
                  dataHora: DateTime.now(),
                  valorVibracao: valor,
                ),
              );
              if (_historicoAlertas.length > 50) _historicoAlertas.removeLast();
            }
            notifyListeners();
          }
        },
        onError: (erro) => print(" Erro no WebSocket: $erro"),
        onDone: () => print("WebSocket fechado."),
      );
    } catch (e) {
      print("Erro fatal no WebSocket: $e");
    }
  }

  Future<void> adicionarMaquina(Maquina maquina) async {
    try {
      await db.collection('maquinas').doc(maquina.id).set({
        'nome': maquina.nome,
        'setor': maquina.setor,
        'status': maquina.status,
      });

      _maquinas[maquina.id] = maquina;
      notifyListeners();

      print("Máquina cadastrada na nuvem e no App!");
    } catch (e) {
      print("Erro ao salvar máquina no Firebase: $e");
    }
  }

  // 4. REMOVER MÁQUINA
  Future<void> removerMaquina(String id) async {
    try {
      await db.collection('maquinas').doc(id).delete();
      _maquinas.remove(id);
      notifyListeners();
    } catch (e) {
      print("Erro ao deletar máquina: $e");
    }
  }

  // 5. Atualizar Máquina
  Future<void> alterarIdENomeDaMaquina({
    required String idAntigo,
    required String idNovo,
    required String novoNome,
    required String novoSetor,
  }) async {
    try {
      if (idAntigo == idNovo) {
        await db.collection('maquinas').doc(idAntigo).update({
          'nome': novoNome,
          'setor': novoSetor,
        });

        if (_maquinas.containsKey(idAntigo)) {
          _maquinas[idAntigo]!.nome = novoNome;
          _maquinas[idAntigo]!.setor = novoSetor;
        }
      } else {
        DocumentSnapshot docVelho = await db
            .collection('maquinas')
            .doc(idAntigo)
            .get();

        if (docVelho.exists) {
          Map<String, dynamic> dadosAtuais =
              docVelho.data() as Map<String, dynamic>;

          dadosAtuais['nome'] = novoNome;
          dadosAtuais['setor'] = novoSetor;
          dadosAtuais['id'] = idNovo;

          await db.collection('maquinas').doc(idNovo).set(dadosAtuais);
          await db.collection('maquinas').doc(idAntigo).delete();

          if (_maquinas.containsKey(idAntigo)) {
            double vibracaoTemporaria = _maquinas[idAntigo]!.vibracaoAtual;

            _maquinas.remove(idAntigo);

            _maquinas[idNovo] = Maquina(
              id: idNovo,
              nome: novoNome,
              setor: novoSetor,
              vibracaoAtual: vibracaoTemporaria,
            );
          }
        }
      }
    } catch (e) {
      throw Exception("Erro ao processar alteração: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<List<RegistroVibracao>> buscarHistoricoFiltrado(
    DateTime inicio,
    DateTime fim,
  ) async {
    try {
      DateTime fimAjustado = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

      print("Buscando histórico de $inicio até $fimAjustado...");

      final snapshot = await db
          .collection('telemetria')
          .where(
            'data_hora',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
          )
          .where(
            'data_hora',
            isLessThanOrEqualTo: Timestamp.fromDate(fimAjustado),
          )
          .orderBy('data_hora', descending: true)
          .limit(300)
          .get();

      List<RegistroVibracao> resultados = snapshot.docs
          .map((doc) {
            final dados = doc.data();
            return RegistroVibracao(
              id: doc.id,
              idMaquina: dados['id_maquina'].toString(),
              dataHora: (dados['data_hora'] as Timestamp).toDate(),
              valorVibracao: (dados['vibracao'] as num).toDouble(),
            );
          })
          .where((registro) => registro.valorVibracao > 0)
          .toList();

      print("Encontrados ${resultados.length} registros no período.");
      return resultados;
    } catch (e) {
      print("Erro ao buscar histórico filtrado: $e");
      return [];
    }
  }
}
