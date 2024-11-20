import 'package:bases_soft_2/ingredient.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: QuantityPage()));
}

class QuantityPage extends StatefulWidget {
  @override
  _QuantityPageState createState() => _QuantityPageState();
}

class _QuantityPageState extends State<QuantityPage> {
  int burgerCount = 0;
  int hotdogCount = 0;

  void goToAllIngredientsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientsSelectionPage(
          totalBurgers: burgerCount,
          totalHotdogs: hotdogCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cantidades'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFoodSelector(
              label: 'Hamburguesas',
              count: burgerCount,
              icon: Icons.fastfood,
              onAdd: () {
                setState(() {
                  burgerCount++;
                });
              },
              onRemove: () {
                if (burgerCount > 0) {
                  setState(() {
                    burgerCount--;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            buildFoodSelector(
              label: 'Perros',
              count: hotdogCount,
              icon: Icons.lunch_dining,
              onAdd: () {
                setState(() {
                  hotdogCount++;
                });
              },
              onRemove: () {
                if (hotdogCount > 0) {
                  setState(() {
                    hotdogCount--;
                  });
                }
              },
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: (burgerCount > 0 || hotdogCount > 0)
                  ? goToAllIngredientsPage
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continuar con Ingredientes',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFoodSelector({
    required String label,
    required int count,
    required IconData icon,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: count > 0 ? onRemove : null,
              icon:
                  const Icon(Icons.remove_circle, color: Colors.red, size: 40),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Icon(icon, size: 80, color: Colors.orange),
                const SizedBox(height: 10),
                Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
