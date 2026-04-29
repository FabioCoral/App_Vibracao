import 'package:app_vibracao/pages/atualizar_maquina_page.dart';
import 'package:app_vibracao/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maquina.dart';
import '../repositories/maquina_repository.dart';

// ignore: must_be_immutable
class DetalhesMaquinaPage extends StatelessWidget {
  Maquina maquinaSelecionada;

  DetalhesMaquinaPage({super.key, required this.maquinaSelecionada});

  Color _obterCorPorValor(double valor) {
    if (valor > 8) return Colors.redAccent;
    if (valor > 5) return Colors.orange;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final maquinaRepo = context.watch<MaquinaRepository>();
    final auth = context.watch<AuthRepository>();
    final isGerente = auth.isGerente;

    final maquinaAtualizada = maquinaRepo.maquinas.firstWhere(
      (m) => m.id == maquinaSelecionada.id,
      orElse: () => maquinaSelecionada,
    );

    final double vibracao = maquinaAtualizada.vibracaoAtual;
    final Color corFundo = _obterCorPorValor(vibracao);

    return Scaffold(
      appBar: AppBar(
        title: Text(maquinaAtualizada.nome),
        backgroundColor: corFundo.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        actions: [
          if (isGerente)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (String result) {
                if (result == 'atualizar') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AtualizarMaquinaPage(
                        maquinaSelecionada: maquinaSelecionada,
                      ),
                    ),
                  );
                }
                if (result == 'apagar') {
                  context.read<MaquinaRepository>().removerMaquina(
                    maquinaAtualizada.id,
                  );
                  Navigator.pop(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'atualizar',
                  child: Text("Atualizar"),
                ),
                const PopupMenuItem<String>(
                  value: 'apagar',
                  child: Text("Apagar"),
                ),
              ],
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [corFundo.withValues(alpha: 0.2), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Monitoramento em tempo Real',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: corFundo, width: 8),
              ),
              child: Column(
                children: [
                  Text(
                    vibracao.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: corFundo,
                    ),
                  ),
                  const Text('mm/s²', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.info, color: corFundo),
                  title: const Text("Status do Sistema"),
                  subtitle: Text(
                    maquinaAtualizada.status.toUpperCase(),
                    style: TextStyle(
                      color: corFundo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
