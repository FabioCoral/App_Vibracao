class Maquina {
  String id;
  String nome;
  String setor;
  double vibracaoAtual;

  Maquina({
    required this.id,
    required this.nome,
    required this.setor,
    this.vibracaoAtual = 0.0,
  });

  String get status {
    if (vibracaoAtual >= 8) return 'perigo';
    if (vibracaoAtual >= 5) return 'alerta';
    return 'ok';
  }
}
