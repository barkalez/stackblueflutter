import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../bluetooth/bluetooth_service.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothService bluetoothService;
  final String deviceAddress;

  const ControlScreen({
    super.key,
    required this.bluetoothService,
    required this.deviceAddress,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  static final Logger _logger = Logger();
  bool _isSendingCommand = false;
  double _currentPosition = 0.0;
  StreamSubscription<String>? _positionSubscription;
  String _buffer = ''; // Buffer para acumular datos hasta recibir \n

  static const int _stepsPerRevolution = 3200; // 3200 pasos por revolución
  static const double _maxSteps = 40000.0; // Límite máximo de 40000 pasos

  @override
  void initState() {
    super.initState();
    _startListeningToPosition();
  }

  void _startListeningToPosition() {
    _logger.i('Iniciando escucha de posición');
    _positionSubscription = widget.bluetoothService.receiveData().listen(
      (data) {
        _logger.i('Datos crudos recibidos: "$data"');
        _buffer += data;

        if (_buffer.contains('\n')) {
          List<String> lines = _buffer.split('\n');
          _buffer = lines.last;
          for (var line in lines.sublist(0, lines.length - 1)) {
            line = line.trim();
            if (line.isEmpty) continue;

            _logger.i('Línea procesada: "$line"');
            if (line.startsWith("POS:")) {
              final positionStr = line.replaceFirst("POS:", "").trim();
              _logger.i('Posición extraída: "$positionStr"');
              final position = double.tryParse(positionStr) ?? _currentPosition;
              if (mounted) {
                setState(() {
                  _currentPosition = position.clamp(0, _maxSteps);
                  _logger.i('Posición actualizada: $_currentPosition');
                });
              }
            } else if (line == "pos0") {
              if (mounted) {
                setState(() {
                  _currentPosition = 0;
                  _logger.i('Homing recibido, posición reiniciada a 0');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Homing completado")),
                );
              }
            } else if (line == "END") {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fin de trayecto alcanzado")),
                );
              }
            } else {
              _logger.w('Datos no reconocidos: "$line"');
            }
          }
        }
      },
      onError: (e) => _logger.e('Error al recibir posición: $e'),
      onDone: () => _logger.i('Stream de datos cerrado'),
    );
  }

  Future<void> _sendHomingCommand() async {
    setState(() => _isSendingCommand = true);
    try {
      await widget.bluetoothService.sendCommand("G28\n");
      _logger.i('Comando "G28" enviado a StackBlue');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Homing iniciado")),
        );
      }
    } catch (e) {
      _handleError('Error al enviar comando "G28": $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  Future<void> _sendOneRevolutionForward() async {
    setState(() => _isSendingCommand = true);
    try {
      double newPosition = (_currentPosition + _stepsPerRevolution).clamp(0, _maxSteps);
      final command = "G1 X${newPosition.round()} F1000\n";
      await widget.bluetoothService.sendCommand(command);
      _logger.i('1 revolución adelante: $command');
    } catch (e) {
      _handleError('Error al enviar comando de 1 revolución adelante: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  Future<void> _sendOneRevolutionBackward() async {
    setState(() => _isSendingCommand = true);
    try {
      double newPosition = (_currentPosition - _stepsPerRevolution).clamp(0, _maxSteps);
      final command = "G1 X${newPosition.round()} F1000\n";
      await widget.bluetoothService.sendCommand(command);
      _logger.i('1 revolución atrás: $command');
    } catch (e) {
      _handleError('Error al enviar comando de 1 revolución atrás: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  Future<void> _sendSliderPosition(double position) async {
    setState(() => _isSendingCommand = true);
    try {
      final command = "G1 X${position.round()} F1000\n";
      await widget.bluetoothService.sendCommand(command);
      _logger.i('Enviado comando desde slider: $command');
    } catch (e) {
      _handleError('Error al enviar posición del slider: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  void _handleError(String message) {
    _logger.e(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    widget.bluetoothService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Control Screen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Homing',
                color: Colors.green,
                onPressed: _isSendingCommand ? () {} : _sendHomingCommand,
                enabled: !_isSendingCommand,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: '1 revolución +',
                color: Colors.blue,
                onPressed: _isSendingCommand ? () {} : _sendOneRevolutionForward,
                enabled: !_isSendingCommand,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: '1 revolución -',
                color: Colors.red,
                onPressed: _isSendingCommand ? () {} : _sendOneRevolutionBackward,
                enabled: !_isSendingCommand,
              ),
              const SizedBox(height: 20),
              Text(
                'Posición: ${_currentPosition.toStringAsFixed(0)} pasos',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Slider(
                value: _currentPosition,
                min: 0,
                max: _maxSteps,
                divisions: 40000,
                label: _currentPosition.toStringAsFixed(0),
                onChanged: (value) {
                  if (mounted && !_isSendingCommand) {
                    setState(() {
                      _currentPosition = value;
                    });
                  }
                },
                onChangeEnd: (value) {
                  if (!_isSendingCommand) {
                    _sendSliderPosition(value);
                  }
                },
              ),
              if (_isSendingCommand) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}