import 'package:flutter/material.dart';
import 'package:qr_reader/domain/providers/api_provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreCtrl.text.trim();
    final correo = _correoCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        // try login (expects correo & password)
        final user = await ApiProvider().login(
          correo: correo,
          password: password,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome ${user.nombre}')));
      } else {
        // try register (common signature: nombre, correo, password)
        final user = await ApiProvider().register(
          nombre: nombre,
          correo: correo,
          password: password,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registered ${user.nombre}')));
      }

      // Return to previous page with success
      if (mounted) {
        // Replace login screen with home so user can't go back to auth screen
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $msg')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (!_isLogin)
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingrese nombre'
                          : null,
                    ),
                  TextFormField(
                    controller: _correoCtrl,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Ingrese correo';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingrese contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Login' : 'Register'),
                        ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? 'Crear cuenta' : 'Ya tengo cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
