import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? usuario;
  bool isGerente = false;
  bool isLoading = true;
  String name = "";

  AuthRepository() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      if (user != null) {
        _carregarPerfilUsuario(user.uid);
      } else {
        isGerente = false;
        notifyListeners();
      }
    });
  }

  Future<void> _carregarPerfilUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        isGerente = doc.get('isGerente') ?? false;
        name = doc.get('nome') ?? "Usuário";
        isLoading = false;
      }
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar perfil: $e");
    }
  }

  Future<void> cadastrar(
    String nome,
    String email,
    String senha,
    bool gerente,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (credential.user != null) {
        await _db.collection('usuarios').doc(credential.user!.uid).set({
          'nome': nome,
          'email': email,
          'isGerente': gerente,
          'dataCadastro': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("Erro ao cadastrar: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } catch (e) {
      throw Exception("Erro ao fazer login. Verifique suas credenciais.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
