import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maquina.dart';
import '../repositories/maquina_repository.dart';

class AtualizarMaquinaPage extends StatefulWidget {
  final Maquina maquinaSelecionada;

  const AtualizarMaquinaPage({super.key, required this.maquinaSelecionada});

  @override
  State<AtualizarMaquinaPage> createState() => _AtualizarMaquinaPageState();
}

class _AtualizarMaquinaPageState extends State<AtualizarMaquinaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _macController;
  late TextEditingController _nomeController;
  late TextEditingController _setorController;

  @override
  void initState() {
    super.initState();

    _macController = TextEditingController(text: widget.maquinaSelecionada.id);
    _nomeController = TextEditingController(
      text: widget.maquinaSelecionada.nome,
    );
    _setorController = TextEditingController(
      text: widget.maquinaSelecionada.setor,
    );
  }

  @override
  void dispose() {
    _macController.dispose();
    _nomeController.dispose();
    _setorController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<MaquinaRepository>().alterarIdENomeDaMaquina(
          idAntigo: widget.maquinaSelecionada.id,
          idNovo: _macController.text.trim(),
          novoNome: _nomeController.text.trim(),
          novoSetor: _setorController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context); // Fecha a tela
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Máquina atualizada com sucesso!"),
              backgroundColor: Colors.teal,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar a máquina."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Atualizar Máquina"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.precision_manufacturing,
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Atualização",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Text(
                  "Insira os novos dados da ${widget.maquinaSelecionada.nome}.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _macController,
                          decoration: InputDecoration(
                            labelText: "Endereço MAC (ID único)",
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(
                              Icons.memory,
                              color: Colors.indigo,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Informe o Endereço MAC" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: "Nome da Máquina",
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(
                              Icons.settings_remote,
                              color: Colors.indigo,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Informe o nome" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _setorController,
                          decoration: InputDecoration(
                            labelText: "Setor / Localização",
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.indigo,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Informe o setor" : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      "SALVAR ALTERAÇÕES",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
