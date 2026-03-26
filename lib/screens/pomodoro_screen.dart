import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class PomodoroScreen extends StatefulWidget {
  final Task task;
  const PomodoroScreen({super.key, required this.task});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int focusDurationSeconds = 25 * 60;
  int _remainingSeconds = focusDurationSeconds;
  Timer? _timer;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          _completeSession();
        }
      });
    }
  }

  Future<void> _completeSession() async {
    setState(() => _isRunning = false);
    
    final provider = context.read<TaskProvider>();
    final updatedTask = widget.task.copyWith(focusMinutes: widget.task.focusMinutes + 25);
    await provider.updateTask(updatedTask);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Session Complete!'),
          content: Text('Awesome job! You just focused for 25 minutes on "${widget.task.title}".'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to list
              },
              child: const Text('Continue'),
            )
          ],
        )
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = 1.0 - (_remainingSeconds / focusDurationSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Session'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.task.title, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Current Focus: ${widget.task.focusMinutes} mins total', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 60),
            
            // Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.indigo,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  heroTag: 'play_pause',
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? Colors.orange : Colors.indigo,
                  child: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'stop',
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.stop_rounded, color: Colors.black54),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
