
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Calculadora MSP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _vlsmBaseController = TextEditingController();
  final TextEditingController _vlsmHostsController = TextEditingController();
  List<Map<String, String>> _vlsmResults = [];
  String _vlsmError = '';

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _maskController = TextEditingController();
  String _network = '';
  String _broadcast = '';
  String _mask = '';
  String _hosts = '';
  String _error = '';
  bool _ipValid = true;
  bool _maskValid = true;

  void _clearVLSMFields() {
    setState(() {
      _vlsmBaseController.clear();
      _vlsmHostsController.clear();
      _vlsmResults = [];
      _vlsmError = '';
    });
  }

  void _calculateVLSM() {
    setState(() {
      _vlsmError = '';
      _vlsmResults = [];
      final base = _vlsmBaseController.text.trim();
      final hostsInput = _vlsmHostsController.text.trim();
      if (!_validateIp(base.split('/')[0])) {
        _vlsmError = 'IP base inválida (ej: 192.168.1.0/24)';
        return;
      }
      final prefix = base.contains('/') ? int.tryParse(base.split('/')[1]) : null;
      if (prefix == null || prefix < 1 || prefix > 30) {
        _vlsmError = 'Prefijo inválido (ej: 192.168.1.0/24)';
        return;
      }
      final hostsList = hostsInput.split(',').map((e) => int.tryParse(e.trim())).where((e) => e != null && e > 0).cast<int>().toList();
      if (hostsList.isEmpty) {
        _vlsmError = 'Ingresa la cantidad de hosts por subred, separados por coma (ej: 50,20,10)';
        return;
      }
      hostsList.sort((a, b) => b.compareTo(a)); // Mayor a menor
      int baseInt = _toInt(base.split('/')[0].split('.').map(int.parse).toList());
      int currentPrefix = prefix;
      int maxHosts = (1 << (32 - prefix)) - 2;
      int used = 0;
      for (final h in hostsList) {
        int neededBits = 32 - ((h + 2 - 1).bitLength);
        int subnetHosts = (1 << (32 - neededBits)) - 2;
        if (subnetHosts < h) neededBits--;
        if (neededBits < prefix) {
          _vlsmError = 'No hay suficiente espacio para $h hosts.';
          return;
        }
        int mask = 0xFFFFFFFF << (32 - neededBits);
        int net = baseInt + used;
        int bcast = net | (~mask & 0xFFFFFFFF);
        String gateway = _fromInt(net + 1);
        String firstValid = _fromInt(net + 1);
        String lastValid = _fromInt(bcast - 1);
        String rango = firstValid == lastValid ? firstValid : '$firstValid - $lastValid';
        _vlsmResults.add({
          'Red': _fromInt(net),
          'Máscara': _fromInt(mask),
          'Gateway': gateway,
          'Rango': rango,
          'Broadcast': _fromInt(bcast),
        });
        used += (1 << (32 - neededBits));
        if (used > (1 << (32 - prefix))) break;
      }
    });
  }

  void _clearFields() {
    setState(() {
      _ipController.clear();
      _maskController.clear();
      _network = '';
      _broadcast = '';
      _mask = '';
      _hosts = '';
      _error = '';
      _ipValid = true;
      _maskValid = true;
    });
  }

  void _calculateNetwork() {
    setState(() {
      _error = '';
      final ip = _ipController.text.trim();
      final mask = _maskController.text.trim();
      _ipValid = _validateIp(ip);
      _maskValid = _validateIp(mask);
      if (!_ipValid || !_maskValid) {
        _error = 'Por favor ingresa una IP y máscara válidas (ej: 192.168.1.1, 255.255.255.0)';
        _network = '';
        _broadcast = '';
        _mask = '';
        _hosts = '';
        return;
      }
      try {
        final ipParts = ip.split('.').map(int.parse).toList();
        final maskParts = mask.split('.').map(int.parse).toList();
        final ipInt = _toInt(ipParts);
        final maskInt = _toInt(maskParts);
        final networkInt = ipInt & maskInt;
        final broadcastInt = networkInt | (~maskInt & 0xFFFFFFFF);
        final hosts = maskInt == 0xFFFFFFFF ? 1 : (0xFFFFFFFF - maskInt - 1);
        _network = _fromInt(networkInt);
        _broadcast = _fromInt(broadcastInt);
        _mask = mask;
        _hosts = hosts > 0 ? hosts.toString() : '0';
      } catch (e) {
        _error = 'Datos inválidos';
        _network = '';
        _broadcast = '';
        _mask = '';
        _hosts = '';
      }
    });
  }

  bool _validateIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  int _toInt(List<int> parts) {
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  String _fromInt(int val) {
    return '${(val >> 24) & 0xFF}.${(val >> 16) & 0xFF}.${(val >> 8) & 0xFF}.${val & 0xFF}';
  }

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Calculadora'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.wifi, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 12),
                const Text(
                  'Calculadora de Subredes',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _ipController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Dirección IP del cliente',
                    border: const OutlineInputBorder(),
                    errorText: _ipValid ? null : 'IP inválida',
                    prefixIcon: const Icon(Icons.lan),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _ipValid = _validateIp(v.trim());
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _maskController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Máscara de subred',
                    hintText: 'Ejemplo: 255.255.255.0',
                    border: const OutlineInputBorder(),
                    errorText: _maskValid ? null : 'Máscara inválida',
                    prefixIcon: const Icon(Icons.shield),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _maskValid = _validateIp(v.trim());
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _calculateNetwork,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calcular'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearFields,
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                if (_network.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.deepPurple),
                              SizedBox(width: 8),
                              Text('Resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          Text('Dirección de red:  $_network', style: const TextStyle(fontSize: 16)),
                          Text('Broadcast:         $_broadcast', style: const TextStyle(fontSize: 16)),
                          Text('Máscara:           $_mask', style: const TextStyle(fontSize: 16)),
                          Text('Hosts disponibles:  $_hosts', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                // Sección VLSM
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Subneteo/VLSM entre routers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Tooltip(
                          message: 'Ejemplo: 192.168.1.0/24',
                          child: TextField(
                            controller: _vlsmBaseController,
                            decoration: const InputDecoration(
                              labelText: 'Red base',
                              hintText: 'Ejemplo: 192.168.1.0/24',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.router),
                              helperText: 'Introduce la red base y el prefijo CIDR',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message: 'Ejemplo: 50,20,10',
                          child: TextField(
                            controller: _vlsmHostsController,
                            decoration: const InputDecoration(
                              labelText: 'Hosts requeridos por subred',
                              hintText: 'Ejemplo: 50,20,10',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.format_list_numbered),
                              helperText: 'Separa los valores con coma',
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _calculateVLSM,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calcular VLSM'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _clearVLSMFields,
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpiar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        if (_vlsmError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_vlsmError, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        if (_vlsmResults.isNotEmpty)
                          Column(
                            children: [
                              const Divider(),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Red')),
                                    DataColumn(label: Text('Máscara')),
                                    DataColumn(label: Text('Gateway')),
                                    DataColumn(label: Text('Rango de Direcciones Válidas')),
                                    DataColumn(label: Text('Broadcast')),
                                  ],
                                  rows: _vlsmResults.map((r) => DataRow(cells: [
                                    DataCell(SelectableText(r['Red']!)),
                                    DataCell(SelectableText(r['Máscara']!)),
                                    DataCell(SelectableText(r['Gateway']!)),
                                    DataCell(SelectableText(r['Rango']!)),
                                    DataCell(SelectableText(r['Broadcast']!)),
                                  ])).toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final text = _vlsmResults.map((r) =>
                                    'Red: ${r['Red']}, Máscara: ${r['Máscara']}, Gateway: ${r['Gateway']}, Rango: ${r['Rango']}, Broadcast: ${r['Broadcast']}').join('\n');
                                  Clipboard.setData(ClipboardData(text: text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Resultados copiados al portapapeles')),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copiar resultados'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Desarrollado por Andersson Ambuludi © 2025',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
