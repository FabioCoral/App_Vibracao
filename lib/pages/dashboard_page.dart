import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../repositories/maquina_repository.dart';
import '../models/registro_vibracao.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTimeRange? _periodoSelecionado;
  List<RegistroVibracao> _historicoFiltrado = [];
  bool _isCarregandoNuvem = false;

  Future<void> _abrirFiltroDeData() async {
    final DateTimeRange? selecionado = await showDateRangePicker(
      context: context,
      initialDateRange: _periodoSelecionado,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              onSurface: Colors.indigo,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionado != null) {
      setState(() {
        _periodoSelecionado = selecionado;
        _isCarregandoNuvem = true;
      });

      final repo = context.read<MaquinaRepository>();
      final dadosDaNuvem = await repo.buscarHistoricoFiltrado(
        selecionado.start,
        selecionado.end,
      );

      setState(() {
        _historicoFiltrado = dadosDaNuvem;
        _isCarregandoNuvem = false;
      });
    }
  }

  void _limparFiltro() {
    setState(() {
      _periodoSelecionado = null;
      _historicoFiltrado = [];
    });
  }

  // FUNÇÃO MÁGICA: Agrupa por minuto e evita repetição visual na tabela
  List<RegistroVibracao> _removerRepeticoesPorMinuto(
    List<RegistroVibracao> listaOriginal,
  ) {
    final Map<String, RegistroVibracao> mapaAgrupado = {};

    for (var registro in listaOriginal) {
      // Cria uma chave única baseada apenas no "dd/MM HH:mm" (ignorando segundos e milissegundos)
      String chaveMinuto = DateFormat('dd/MM HH:mm').format(registro.dataHora);

      if (!mapaAgrupado.containsKey(chaveMinuto)) {
        mapaAgrupado[chaveMinuto] = registro;
      } else {
        // Se já existe um registro nesse mesmo minuto, mantém o que tiver a maior vibração (pico)
        if (registro.valorVibracao > mapaAgrupado[chaveMinuto]!.valorVibracao) {
          mapaAgrupado[chaveMinuto] = registro;
        }
      }
    }

    // Retorna a lista limpa e mantém a ordenação correta
    return mapaAgrupado.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MaquinaRepository>();
    final maquinas = repo.maquinas;

    // 1. Define qual fonte de dados usar
    final listaBruta = _periodoSelecionado != null
        ? _historicoFiltrado
        : repo.historicoAlertas;

    // 2. Aplica o filtro para mostrar apenas uma linha por hora/minuto
    final listaParaExibir = _removerRepeticoesPorMinuto(listaBruta);

    String getNomeMaquina(String idMaquina) {
      try {
        return maquinas.firstWhere((m) => m.id == idMaquina).nome;
      } catch (e) {
        return "Máquina ID: $idMaquina";
      }
    }

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Dashboard de Análises"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_periodoSelecionado != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: "Limpar Filtro",
              onPressed: _limparFiltro,
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filtrar por Data",
            onPressed: _abrirFiltroDeData,
          ),
        ],
      ),
      body: _isCarregandoNuvem
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _periodoSelecionado == null
                        ? "Últimos Alertas (Sessão Atual)"
                        : "Histórico: ${DateFormat('dd/MM').format(_periodoSelecionado!.start)} até ${DateFormat('dd/MM').format(_periodoSelecionado!.end)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (listaParaExibir.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "Nenhum alerta registrado neste período.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.indigo.withValues(alpha: 0.1),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Horário",
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
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: listaParaExibir.map((alerta) {
                            final double vib = alerta.valorVibracao;

                            String textoTag = "SISTEMA";
                            Color corFundo = Colors.blue[100]!;
                            Color corTexto = Colors.blue[900]!;

                            if (vib >= 50.0) {
                              textoTag = "PERIGO";
                              corFundo = Colors.red[100]!;
                              corTexto = Colors.red[900]!;
                            } else if (vib > 0) {
                              textoTag = "ALERTA";
                              corFundo = Colors.orange[100]!;
                              corTexto = Colors.orange[900]!;
                            }

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    // ⚠️ EXIBE APENAS HORA E MINUTO NA TELA
                                    DateFormat(
                                      'dd/MM HH:mm',
                                    ).format(alerta.dataHora),
                                  ),
                                ),
                                DataCell(
                                  Text(getNomeMaquina(alerta.idMaquina)),
                                ),
                                DataCell(
                                  Text(
                                    "${vib.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: corFundo,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      textoTag,
                                      style: TextStyle(
                                        color: corTexto,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
