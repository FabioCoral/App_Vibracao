import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatar a data e hora
import '../repositories/maquina_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MaquinaRepository>();
    final historico = repo.historicoAlertas;
    final maquinas = repo.maquinas;

    String getNomeMaquina(String idMaquina) {
      try {
        return maquinas.firstWhere((m) => m.id == idMaquina).nome;
      } catch (e) {
        return "Máquina Removida";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard de Análises"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Histórico de Desvios de Vibração",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.indigo.withValues(alpha: 0.1),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Data/Hora",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Máquina",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Vibração",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Gravidade",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: historico.map((alerta) {
                    final isCritico = alerta.valorVibracao > 8;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            DateFormat('dd/MM HH:mm').format(alerta.dataHora),
                          ),
                        ),
                        DataCell(Text(getNomeMaquina(alerta.idMaquina))),
                        DataCell(
                          Text(
                            "${alerta.valorVibracao} mm/s²",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isCritico
                                  ? Colors.red[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCritico ? "CRÍTICA" : "ALERTA",
                              style: TextStyle(
                                color: isCritico
                                    ? Colors.red[900]
                                    : Colors.orange[900],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
