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
    if (valor > 80) return Colors.redAccent;
    if (valor > 50) return Colors.orange;
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
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Confirmar Exclusão",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          "Você tem certeza que deseja apagar a máquina '${maquinaAtualizada.nome}'?\n\nEsta ação removerá o equipamento do monitoramento e não poderá ser desfeita.",
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.read<MaquinaRepository>().removerMaquina(
                                maquinaAtualizada.id,
                              );
                              Navigator.pop(dialogContext);
                              Navigator.pop(context);
                            },
                            child: const Text("Apagar Máquina"),
                          ),
                        ],
                      );
                    },
                  );
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
