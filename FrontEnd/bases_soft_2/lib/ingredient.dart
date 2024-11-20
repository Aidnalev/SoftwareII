import 'package:bases_soft_2/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientsSelectionPage extends StatefulWidget {
  final int totalBurgers;
  final int totalHotdogs;

  IngredientsSelectionPage(
      {required this.totalBurgers, required this.totalHotdogs});

  @override
  IngredientsSelectionPageState createState() =>
      IngredientsSelectionPageState();
}

class IngredientsSelectionPageState extends State<IngredientsSelectionPage> {
  Map<String, bool> defaultBurgerIngredients = {
    'Pan': true,
    'Queso': true,
    'Carne': true,
    'Lechuga': true,
    'Tomate': true,
    'Papas Fritas': true,
  };

  Map<String, bool> defaultHotdogIngredients = {
    'Pan': true,
    'Salchicha': true,
    'Mostaza': true,
    'Ketchup': true,
    'Cebolla': true,
  };

  int selectedBurger = 1;
  int selectedHotdog = 1;

  Map<int, Map<String, bool>> burgerSelection = {};
  Map<int, Map<String, bool>> hotdogSelection = {};

  Map<String, bool> currentBurgerIngredients = {};
  Map<String, bool> currentHotdogIngredients = {};

  int currentOrderNumber = 1;

  late int precioHamburguesa;
  late int precioPerro;

  @override
  void initState() {
    super.initState();
    fetchPrices();
    currentBurgerIngredients = Map.from(defaultBurgerIngredients);
    currentHotdogIngredients = Map.from(defaultHotdogIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ingredientes'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.totalBurgers > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Modificar Hamburguesa N°:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<int>(
                            value: selectedBurger,
                            items: List.generate(widget.totalBurgers, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('Hamburguesa ${index + 1}'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                saveCurrentBurgerState();
                                selectedBurger = value!;
                                loadBurgerState(selectedBurger);
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          buildIngredientSelector(
                              'Hamburguesa', currentBurgerIngredients),
                        ],
                      ),
                    if (widget.totalHotdogs > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Modificar Perro N°:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<int>(
                            value: selectedHotdog,
                            items: List.generate(widget.totalHotdogs, (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('Perro ${index + 1}'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                saveCurrentHotdogState();
                                selectedHotdog = value!;
                                loadHotdogState(selectedHotdog);
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          buildIngredientSelector(
                              'Perro', currentHotdogIngredients),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                saveSelection();
              },
              child: const Text('Guardar y Ver Resumen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIngredientSelector(
      String foodType, Map<String, bool> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.keys.map((String key) {
        return CheckboxListTile(
          title: Text(key),
          value: ingredients[key],
          onChanged: (bool? value) {
            setState(() {
              ingredients[key] = value ?? true;
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> fetchPrices() async {
    final url = Uri.parse('http://52.207.149.212:3000/api/prices');

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        precioHamburguesa = int.parse(data['hamburguesa']);
        precioPerro = int.parse(data['perro']);

        print("Precio de Hamburguesa: $precioHamburguesa");
        print("Precio de Perro: $precioPerro");
      } else {
        print("Error al obtener precios: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  void saveCurrentBurgerState() {
    burgerSelection[selectedBurger] = Map.from(currentBurgerIngredients);
  }

  void loadBurgerState(int burgerNumber) {
    if (burgerSelection[burgerNumber] != null) {
      currentBurgerIngredients = Map.from(burgerSelection[burgerNumber]!);
    } else {
      currentBurgerIngredients = Map.from(defaultBurgerIngredients);
    }
  }

  void saveCurrentHotdogState() {
    hotdogSelection[selectedHotdog] = Map.from(currentHotdogIngredients);
  }

  void loadHotdogState(int hotdogNumber) {
    if (hotdogSelection[hotdogNumber] != null) {
      currentHotdogIngredients = Map.from(hotdogSelection[hotdogNumber]!);
    } else {
      currentHotdogIngredients = Map.from(defaultHotdogIngredients);
    }
  }

  int calcularTotal(int cantidad, int precio) {
    return cantidad * precio;
  }

  void saveSelection() {
    saveCurrentBurgerState();
    saveCurrentHotdogState();

    // Mapa para agrupar configuraciones similares
    Map<String, Map<String, dynamic>> groupedItems = {};

    // Función para generar una descripción única de los ingredientes
    String generateDescription(Map<String, bool> customizations) {
      return customizations.entries
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .join(', ');
    }

    // Procesar hamburguesas
    for (int i = 1; i <= widget.totalBurgers; i++) {
      if (burgerSelection[i] == null) {
        burgerSelection[i] = Map.from(defaultBurgerIngredients);
      }

      String description = generateDescription(burgerSelection[i]!);
      String key = "Hamburguesa:$description";

      if (groupedItems.containsKey(key)) {
        groupedItems[key]!['quantity'] += 1;
      } else {
        groupedItems[key] = {
          "productName": "Hamburguesa",
          "customizations": Map.from(burgerSelection[i]!),
          "quantity": 1,
        };
      }
    }

    // Procesar perros calientes
    for (int i = 1; i <= widget.totalHotdogs; i++) {
      if (hotdogSelection[i] == null) {
        hotdogSelection[i] = Map.from(defaultHotdogIngredients);
      }

      String description = generateDescription(hotdogSelection[i]!);
      String key = "Perro:$description";

      if (groupedItems.containsKey(key)) {
        groupedItems[key]!['quantity'] += 1;
      } else {
        groupedItems[key] = {
          "productName": "Perro Caliente",
          "customizations": Map.from(hotdogSelection[i]!),
          "quantity": 1,
        };
      }
    }

    // Convertir el mapa en una lista para el JSON
    List<Map<String, dynamic>> itemsOrdered = groupedItems.values.toList();

    final Map<String, dynamic> orderSummary = {
      "orderNumber": currentOrderNumber,
      "orderTime":
          DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now()).toString(),
      "itemsOrdered": itemsOrdered,
      "totalPrice": (widget.totalBurgers * precioHamburguesa) +
          (widget.totalHotdogs * precioPerro),
    };

    setState(() {
      currentOrderNumber++;
    });

    print(orderSummary); // JSON corregido
    _sendOrderSummary(orderSummary);
    _seleccionRecibo();
  }

  Future<void> _sendOrderSummary(Map<String, dynamic> orderSummary) async {
    final url = Uri.parse('http://52.207.149.212:3000/api/tienda');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderSummary),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Order summary sent successfully!");
      } else {
        print(
            "Failed to send order summary. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending order summary: $e");
    }
  }

  void _seleccionRecibo() {
    // Asegurar que se guarden los estados actuales de hamburguesas y perros calientes
    saveCurrentBurgerState();
    saveCurrentHotdogState();

    // Mapa temporal para acumular configuraciones de hamburguesas y perros calientes
    Map<String, int> burgerSummary = {};
    Map<String, int> hotdogSummary = {};

    // Función para formatear la lista de ingredientes eliminados
    String formatRemovedIngredients(List<String> removedIngredients) {
      if (removedIngredients.isEmpty) {
        return 'con todo';
      } else if (removedIngredients.length == 1) {
        return 'sin ${removedIngredients[0]}';
      } else {
        String lastIngredient = removedIngredients.last;
        return 'sin ${removedIngredients.sublist(0, removedIngredients.length - 1).join(", ")} y $lastIngredient';
      }
    }

    // Procesar hamburguesas individualmente
    for (int i = 1; i <= widget.totalBurgers; i++) {
      if (burgerSelection[i] == null) {
        burgerSelection[i] = Map.from(defaultBurgerIngredients);
      }

      List<String> removedIngredients = burgerSelection[i]!
          .entries
          .where((entry) => entry.value == false)
          .map((entry) => entry.key)
          .toList();

      String description = formatRemovedIngredients(removedIngredients);

      // Acumular las hamburguesas con la misma descripción
      if (burgerSummary.containsKey(description)) {
        burgerSummary[description] = burgerSummary[description]! + 1;
      } else {
        burgerSummary[description] = 1;
      }
    }

    // Procesar perros calientes individualmente
    for (int i = 1; i <= widget.totalHotdogs; i++) {
      if (hotdogSelection[i] == null) {
        hotdogSelection[i] = Map.from(defaultHotdogIngredients);
      }

      List<String> removedIngredients = hotdogSelection[i]!
          .entries
          .where((entry) => entry.value == false)
          .map((entry) => entry.key)
          .toList();

      String description = formatRemovedIngredients(removedIngredients);

      // Acumular los perros calientes con la misma descripción
      if (hotdogSummary.containsKey(description)) {
        hotdogSummary[description] = hotdogSummary[description]! + 1;
      } else {
        hotdogSummary[description] = 1;
      }
    }

    // Generar JSON de salida
    Map<String, dynamic> detalles = {
      'burgers': [],
      'hotdogs': [],
    };

    // Agregar hamburguesas al JSON
    burgerSummary.forEach((description, count) {
      detalles['burgers'].add({
        'quantity': count,
        'description': description,
      });
    });

    // Agregar perros calientes al JSON
    hotdogSummary.forEach((description, count) {
      detalles['hotdogs'].add({
        'quantity': count,
        'description': description,
      });
    });

    print(
        detalles); // Aquí puedes enviar el JSON a tu backend o manejarlo según necesites

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          orderSummary: detalles,
          precioHamburguesa: precioHamburguesa,
          precioPerro: precioPerro,
        ),
      ),
    );
  }
}
