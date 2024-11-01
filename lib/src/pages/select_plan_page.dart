import 'package:flutter/material.dart';
import 'package:lemon/src/dbHelper/PlanDBHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmacion_page.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({super.key});

  @override
  _SelectPlanPageState createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  final PlanDBHelper _plandbHelper = PlanDBHelper();
  final TextEditingController _userIdController = TextEditingController();
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    var plans = await _plandbHelper.getPlans();
    setState(() {
      _plans = plans;
    });
  }

  Future<void> _associatePlanToUser(int planId) async {
    final userId = int.tryParse(_userIdController.text);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese un ID de usuario válido')),
      );
      return;
    }

    await _plandbHelper.associatePlanToUser(userId, planId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abono asociado exitosamente al usuario')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Plan'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'ID del Usuario'),
              keyboardType: TextInputType.number,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  var plan = _plans[index];
                  return _buildPlanCard(
                    context,
                    plan['name'],
                    plan['class_quantity'],
                    plan['price'],
                    plan['id'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, int classQuantity, double price, int planId) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.teal[50],
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          await _associatePlanToUser(planId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmPurchasePage(
                planId: planId,
                abono: title,
                price: price,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.teal, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Plan: $title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$classQuantity clases disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                  ),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.teal[700],
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
