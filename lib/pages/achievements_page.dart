import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/achievement.dart';

/// Página de Conquistas e Gamificação (Auto-gerenciada)
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late Box<Achievement> _box;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _box = Hive.box<Achievement>('achievements');
    
    // Se não houver conquistas, criar as padrão
    if (_box.isEmpty) {
      final defaults = AchievementTemplates.getDefaults();
      for (final achievement in defaults) {
        await _box.put(achievement.id, achievement);
      }
    }
    
    setState(() {
      _achievements = _box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.isUnlocked).toList();
    final locked = _achievements.where((a) => !a.isUnlocked).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquistas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(unlocked.length, _achievements.length),
            const SizedBox(height: 24),
            
            if (unlocked.isNotEmpty) ...[
              const Text('🏆 Desbloqueadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...unlocked.map((a) => _buildAchievementCard(a, true)),
              const SizedBox(height: 24),
            ],
            
            const Text('🎯 Em Progresso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (locked.isEmpty)
              _buildEmptyState()
            else
              ...locked.map((a) => _buildAchievementCard(a, false)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.grey[850],
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Parabéns! Todas as conquistas desbloqueadas!', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int unlockedCount, int total) {
    final percentage = total > 0 ? (unlockedCount / total) : 0.0;
    
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$unlockedCount',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                Text(
                  ' / $total',
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
              ],
            ),
            const Text('conquistas desbloqueadas', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[700],
                color: Colors.amber,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      color: isUnlocked ? Colors.amber.withValues(alpha: 0.15) : Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.amber.withValues(alpha: 0.3) : Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.amber : Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: const TextStyle(fontSize: 12)),
            if (!isUnlocked) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: Colors.grey[700],
                  color: Colors.blue,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(achievement.progress * 100).toInt()}% completo',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.amber)
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
}

/// Widget de Mini Conquista (para mostrar notificação)
class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;

  const AchievementUnlockedDialog({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade800, Colors.orange.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'CONQUISTA DESBLOQUEADA!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(achievement.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.amber.shade800,
              ),
              child: const Text('INCRÍVEL!'),
            ),
          ],
        ),
      ),
    );
  }
}
