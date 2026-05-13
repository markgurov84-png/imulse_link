import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String avatar;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.userId,
    required this.avatar,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isPremium = false;
  String _selectedLanguage = 'Русский';
  String _selectedThemeColor = 'Синий';
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  String? _avatarImagePath;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    // Загрузка сохранённых настроек
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImagePath = pickedFile.path;
      });
      // TODO: загрузить на сервер
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить пароль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Старый пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: сменить пароль
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пароль изменён')),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'ImulseLink Premium',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _buildPremiumFeature('🎨', 'Эксклюзивные темы оформления'),
            _buildPremiumFeature('💬', 'Неограниченные чаты и голосовые'),
            _buildPremiumFeature('📸', 'Загрузка фото и видео в HD качестве'),
            _buildPremiumFeature('🔗', 'Ссылки и описание в профиле'),
            _buildPremiumFeature('📊', 'Статистика постов и аналитика'),
            _buildPremiumFeature('🎁', 'Доступ к новым функциям первым'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isPremium = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Подписка оформлена!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Оформить за 299 ₽/мес',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? const Color(0xFF1A1A1A) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Настройки', style: TextStyle(color: Color(0xFF1A2C3E))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Аватар и основная информация
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF007AFF),
                          backgroundImage: _avatarImagePath != null
                              ? FileImage(File(_avatarImagePath!))
                              : null,
                          child: _avatarImagePath == null
                              ? Text(
                                  widget.avatar,
                                  style: const TextStyle(fontSize: 40, color: Colors.white),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8A9BB0)),
                  ),
                  if (_isPremium)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Настройки аккаунта
            _buildSection('Аккаунт', [
              _buildSettingsTile(
                icon: Icons.phone_android,
                title: 'Номер телефона',
                subtitle: 'Не добавлен',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Добавить номер телефона'),
                      content: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Номер телефона',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Номер сохранён')),
                            );
                          },
                          child: const Text('Сохранить'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.link,
                title: 'Привязать Google аккаунт',
                subtitle: 'Быстрый вход',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Привязка Google аккаунта')),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Сменить пароль',
                onTap: _showChangePasswordDialog,
              ),
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Редактировать профиль',
                onTap: () {},
              ),
            ]),

            // Настройки интерфейса
            _buildSection('Внешний вид', [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Тёмная тема',
                value: _isDarkTheme,
                onChanged: (val) => setState(() => _isDarkTheme = val),
              ),
              _buildDropdownTile(
                icon: Icons.color_lens,
                title: 'Цветовая схема',
                value: _selectedThemeColor,
                items: ['Синий', 'Зелёный', 'Фиолетовый', 'Розовый', 'Оранжевый'],
                onChanged: (val) => setState(() => _selectedThemeColor = val),
              ),
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Язык',
                value: _selectedLanguage,
                items: ['Русский', 'English', 'Қазақша'],
                onChanged: (val) => setState(() => _selectedLanguage = val),
              ),
            ]),

            // Уведомления
            _buildSection('Уведомления и звуки', [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push-уведомления',
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Звук сообщений',
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Виброотклик',
                value: _vibrationEnabled,
                onChanged: (val) => setState(() => _vibrationEnabled = val),
              ),
            ]),

            // Премиум
            _buildSection('ImulseLink Premium', [
              _buildSettingsTile(
                icon: Icons.star,
                title: 'Premium подписка',
                subtitle: _isPremium ? 'Активна' : 'Оформить подписку',
                trailing: _isPremium
                    ? const Icon(Icons.verified, color: Color(0xFF007AFF))
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showPremiumDialog,
              ),
              if (_isPremium) ...[
                _buildSettingsTile(
                  icon: Icons.color_lens,
                  title: 'Эксклюзивные темы',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.analytics,
                  title: 'Статистика постов',
                  onTap: () {},
                ),
              ],
            ]),

            // Дополнительно
            _buildSection('О приложении', [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'О ImulseLink',
                subtitle: 'Версия 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ImulseLink',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 ImulseLink Social Network',
                    children: [
                      const Text('Социальная сеть нового поколения. Связывайся с друзьями, делись моментами и будь в курсе событий.'),
                    ],
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'Пользовательское соглашение',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Политика конфиденциальности',
                onTap: () {},
              ),
            ]),

            // Выход
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Выйти из аккаунта'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A9BB0),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(title, style: const TextStyle(color: Color(0xFF1A2C3E))),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BB0))) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8A9BB0)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(title, style: const TextStyle(color: Color(0xFF1A2C3E))),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF007AFF),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF007AFF)),
      title: Text(title, style: const TextStyle(color: Color(0xFF1A2C3E))),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (val) => onChanged(val!),
        underline: const SizedBox(),
      ),
      onTap: () {},
    );
  }
}