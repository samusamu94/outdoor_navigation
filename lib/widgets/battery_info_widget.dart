import 'package:flutter/material.dart';
import 'package:outdoor_navigation/models/route_model.dart';

class BatteryInfoWidget extends StatelessWidget {
  final BatteryInfo batteryInfo;

  const BatteryInfoWidget({super.key, required this.batteryInfo});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Messaggio principale
            Text(batteryInfo.message),
            const SizedBox(height: 16),
            
            // Indicatore grafico del consumo di batteria
            const Text('Consumo batteria'),
            const SizedBox(height: 8),
            _buildBatteryIndicator(context),
            const SizedBox(height: 16),
            
            // Dettagli in formato tabellare
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                _buildTableRow('Consumo totale', '${batteryInfo.consumptionWh} Wh'),
                _buildTableRow('Ricariche necessarie', batteryInfo.rechargesNeeded.toString()),
                _buildTableRow('Autonomia con carica completa', '${batteryInfo.estimatedRangePerCharge} km'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBatteryIndicator(BuildContext context) {
    // Calcoliamo quante ricariche complete sono necessarie
    final rechargesNeeded = batteryInfo.rechargesNeeded;
    
    // Colore in base al numero di ricariche
    Color batteryColor;
    if (rechargesNeeded <= 1) {
      batteryColor = Colors.green;
    } else if (rechargesNeeded <= 3) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: 1.0 / rechargesNeeded, // Percentuale di batteria utilizzata
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.battery_charging_full, color: batteryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  rechargesNeeded <= 1 
                      ? '${(100 / rechargesNeeded).round()}% di una carica'
                      : '$rechargesNeeded ricariche complete',
                  style: TextStyle(
                    color: batteryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${batteryInfo.consumptionWh} Wh',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
  
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}