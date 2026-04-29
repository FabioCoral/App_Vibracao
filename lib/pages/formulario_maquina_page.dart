import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maquina.dart';
import '../repositories/maquina_repository.dart';

class FormularioMaquinaPage extends StatefulWidget {
  const FormularioMaquinaPage({super.key});

  @override
  State<FormularioMaquinaPage> createState() => _FormularioMaquinaPageState();
}

class _FormularioMaquinaPageState extends State<FormularioMaquinaPage> {
  final _formKey = GlobalKey<FormState>();
  final _macController = TextEditingController();
  final _nomeController = TextEditingController();
  final _setorController = TextEditingController();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novaMaquina = Maquina(
        id: _macController.text.trim(),
        nome: _nomeController.text.trim(),
        setor: _setorController.text.trim(),
      );

      await context.read<MaquinaRepository>().adicionarMaquina(novaMaquina);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Máquina cadastrada com sucesso!"),
            backgroundColor: Colors.teal,
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
        title: const Text("Nova Máquina"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  "Cadastro de Equipamento",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Text(
                  "Insira os dados para iniciar o monitoramento.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 4,
                  shadowColor: Colors.indigo.withValues(alpha: 0.2),
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
                            labelText: "Endereço MAC (ID único do Sensor)",
                            hintText: "Ex: AA:BB:CC:DD:EE:FF",
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
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Informe o Endereço MAC"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: "Nome da Máquina (Ex: Motor 01)",
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
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Informe o nome"
                              : null,
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
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Informe o setor"
                              : null,
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
                      "SALVAR MÁQUINA",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
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
