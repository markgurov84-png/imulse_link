import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late ApiService _api;
  
  String _currentScreen = 'login';
  
  String _tempEmail = '';
  String _tempUsername = '';
  String _tempPassword = '';
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
  }

  Future<void> _sendCode() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showError('Пароль должен быть минимум 6 символов');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _api.sendCode(
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
      );
      
      if (response['success'] == true) {
        _tempEmail = _emailController.text;
        _tempUsername = _usernameController.text;
        _tempPassword = _passwordController.text;
        
        setState(() {
          _currentScreen = 'verify';
          _isLoading = false;
        });
        
        _showSuccess('Код отправлен на почту!');
      } else {
        _showError(response['message'] ?? 'Ошибка');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Ошибка: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showError('Введите 6-значный код');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _api.verifyCode(_tempEmail, _codeController.text);
      
      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        
        _api.initSocket(user.id);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              username: user.username,
              email: user.email,
              userId: user.id,
              avatar: user.avatar,
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Неверный код');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Ошибка: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _api.login(_emailController.text, _passwordController.text);
      
      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        
        _api.initSocket(user.id);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              username: user.username,
              email: user.email,
              userId: user.id,
              avatar: user.avatar,
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Ошибка входа');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Ошибка: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
  
  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _currentScreen == 'login'
              ? _buildLoginForm()
              : _currentScreen == 'register'
                  ? _buildRegisterForm()
                  : _buildVerifyForm(),
        ),
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return _buildCard(
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 30),
          const Text('ImulseLink', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
          const SizedBox(height: 8),
          const Text('Войди в свой аккаунт', style: TextStyle(fontSize: 16, color: Color(0xFF5A6E82))),
          const SizedBox(height: 40),
          _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined),
          const SizedBox(height: 20),
          _buildTextField(controller: _passwordController, label: 'Пароль', icon: Icons.lock_outline, obscure: true),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF007AFF))
              : _buildBlueButton(text: 'Войти', onPressed: _login),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() { _currentScreen = 'register'; _clearFields(); }),
            child: const Text('Нет аккаунта? Зарегистрируйся', style: TextStyle(color: Color(0xFF007AFF))),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegisterForm() {
    return _buildCard(
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          const Text('Создать аккаунт', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
          const SizedBox(height: 8),
          const Text('Присоединяйся к ImulseLink', style: TextStyle(fontSize: 16, color: Color(0xFF5A6E82))),
          const SizedBox(height: 30),
          _buildTextField(controller: _usernameController, label: 'Username', icon: Icons.person_outline, hint: 'уникальное имя'),
          const SizedBox(height: 16),
          _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, hint: 'example@mail.com'),
          const SizedBox(height: 16),
          _buildTextField(controller: _passwordController, label: 'Пароль', icon: Icons.lock_outline, obscure: true, hint: 'минимум 6 символов'),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF007AFF))
              : _buildBlueButton(text: 'Получить код', onPressed: _sendCode),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() { _currentScreen = 'login'; _clearFields(); }),
            child: const Text('Уже есть аккаунт? Войти', style: TextStyle(color: Color(0xFF007AFF))),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVerifyForm() {
    return _buildCard(
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          const Text('Подтверждение', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
          const SizedBox(height: 8),
          const Text('Введите код из письма', style: TextStyle(fontSize: 16, color: Color(0xFF5A6E82))),
          const SizedBox(height: 8),
          Text(_tempEmail, style: const TextStyle(fontSize: 14, color: Color(0xFF007AFF))),
          const SizedBox(height: 30),
          _buildTextField(
            controller: _codeController,
            label: '6-значный код',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            hint: '000000',
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF007AFF))
              : _buildBlueButton(text: 'Подтвердить', onPressed: _verifyCode),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _sendCode,
            child: const Text('Отправить код ещё раз', style: TextStyle(color: Color(0xFF007AFF))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentScreen = 'register';
                _clearFields();
              });
            },
            child: const Text('Назад', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
  
  void _clearFields() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _codeController.clear();
    _tempEmail = '';
    _tempUsername = '';
    _tempPassword = '';
  }
  
  Widget _buildCard({required Widget child}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF1A2C3E).withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Padding(padding: const EdgeInsets.all(32), child: child),
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
      child: const Icon(Icons.chat_bubble_outline, size: 42, color: Colors.white),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A6E82))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF1A2C3E)),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF8A9BB0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2)),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBlueButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}