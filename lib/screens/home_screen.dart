import 'package:flutter/material.dart';
import 'package:lg_final_app/connections/ssh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SSH ssh = SSH();

  // Exact Liquid Galaxy Brand Colors
  final Color lgBlue = const Color(0xFF0B4F8C);
  final Color lgOrange = const Color(0xFFF27C22);
  final Color lgGreen = const Color(0xFF37973B);
  final Color lgPurple = const Color(0xFF7B3F93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG CONTROLLER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Spacer(),
            // ROW 1: Chandigarh (Blue) & Pyramids (Orange)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _buildBigButton("FLY TO\nCHANDIGARH", lgBlue, Icons.flight_takeoff, () => ssh.flyToChandigarh()),
                  const SizedBox(width: 15),
                  _buildBigButton("PYRAMIDS\n(Egypt)", lgOrange, Icons.change_history, () => ssh.sendPyramids()),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // ROW 2: Footballs (Green) & Logo (Purple)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _buildBigButton("FOOTBALLS\n(Spain)", lgGreen, Icons.sports_soccer, () => ssh.sendFootballs()),
                  const SizedBox(width: 15),
                  _buildBigButton("SHOW\nLOGO", lgPurple, Icons.image, () => ssh.showLogo()),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // ROW 3: Clean KML & Clean Logo (Grey/Action buttons)
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _buildActionBtn("CLEAN KML", Colors.blueGrey, Icons.cleaning_services, () => ssh.clearKMLMain()),
                  const SizedBox(width: 15),
                  _buildActionBtn("CLEAN LOGO", Colors.blueGrey, Icons.visibility_off, () => ssh.clearLogo()),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(String title, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 55, color: Colors.white),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String title, Color color, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? color.withOpacity(0.3) : color.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}