import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_final_app/connections/ssh.dart'; // UPDATED
import 'package:lg_final_app/main.dart'; // UPDATED

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SSH ssh = SSH();
  bool _isConnected = false;
  bool _isLoading = false;

  final _ipController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sshPortController = TextEditingController();
  final _rigsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? 'lg';
      _passwordController.text = prefs.getString('password') ?? 'lg';
      _sshPortController.text = prefs.getString('sshPort') ?? '22';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '3';
    });
  }

  Future<void> _saveAndConnect() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('sshPort', _sshPortController.text);
    await prefs.setString('numberOfRigs', _rigsController.text);

    bool? result = await ssh.connectToLG();
    setState(() {
      _isConnected = result ?? false;
      _isLoading = false;
    });
    
    if(_isConnected) ssh.run('echo "flytoview=<LookAt><longitude>0</longitude><latitude>0</latitude><altitude>0</altitude><heading>0</heading><tilt>0</tilt><range>10000000</range><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt');
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Liquid Galaxy Controller", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Author: Anirudh Pratap Singh Yadav", style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            Text("This Emulator is made as a part of  Pre-requisite(\"Task2\") to GSOC2026 at liquid galaxy."),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // About Info Button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showAboutDialog,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isConnected ? Colors.green : Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 12, color: _isConnected ? Colors.green : Colors.red),
                  const SizedBox(width: 10),
                  Text(_isConnected ? "CONNECTED" : "DISCONNECTED", style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_ipController, 'IP Address', Icons.wifi),
            _buildTextField(_usernameController, 'Username', Icons.person),
            _buildTextField(_passwordController, 'Password', Icons.lock, obscure: true),
            _buildTextField(_sshPortController, 'SSH Port', Icons.settings_ethernet, keyboard: TextInputType.number),
            _buildTextField(_rigsController, 'No. of Rigs', Icons.monitor, keyboard: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveAndConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.cast_connected),
              label: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SAVE & CONNECT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("SYSTEM CONTROLS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))),
            // System Buttons Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSysBtn("REBOOT LG", Colors.orange[800]!, Icons.restart_alt, () => ssh.rebootLG()),
                _buildSysBtn("RELAUNCH", Colors.blue[800]!, Icons.refresh, () => ssh.relaunchLG()),
                _buildSysBtn("SHUTDOWN", Colors.red[900]!, Icons.power_settings_new, () => ssh.shutdownLG()),
                _buildSysBtn("CLEAN KML+LOGOS", Colors.purple[800]!, Icons.delete_forever, () => ssh.clearAll()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, TextInputType? keyboard}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSysBtn(String title, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      icon: Icon(icon),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}