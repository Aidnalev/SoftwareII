import 'package:bases_soft_2/quantity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para el formateo de números

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> orderSummary;
  final int precioHamburguesa;
  final int precioPerro;

  const OrderSummaryPage(
      {super.key,
      required this.orderSummary,
      required this.precioHamburguesa,
      required this.precioPerro});

  @override
  Widget build(BuildContext context) {
    // Obtener hamburguesas del JSON
    List<Map<String, dynamic>> burgerDetails = [];

    if (orderSummary['burgers'] != null) {
      burgerDetails = List<Map<String, dynamic>>.from(orderSummary['burgers']);
    }

    // Obtener perros calientes del JSON
    List<Map<String, dynamic>> hotdogDetails = [];

    if (orderSummary['hotdogs'] != null) {
      hotdogDetails = List<Map<String, dynamic>>.from(orderSummary['hotdogs']);
    }

    // Calcular el total general
    int totalGeneral = 0;

    for (var detail in burgerDetails) {
      totalGeneral += calcularTotal(detail['quantity'], precioHamburguesa);
    }

    for (var detail in hotdogDetails) {
      totalGeneral += calcularTotal(detail['quantity'], precioPerro);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            buildTableHeader(), // Cabecera de la tabla

            // Mostrar detalles de hamburguesas
            if (burgerDetails.isNotEmpty)
              for (var detail in burgerDetails)
                buildTableRow(
                  cantidad: detail['quantity'],
                  descripcion: 'Hamburguesa ${detail['description']}',
                  total: calcularTotal(detail['quantity'], precioHamburguesa),
                ),

            // Mostrar detalles de perros calientes
            if (hotdogDetails.isNotEmpty)
              for (var detail in hotdogDetails)
                buildTableRow(
                  cantidad: detail['quantity'],
                  descripcion: 'Perro Caliente ${detail['description']}',
                  total: calcularTotal(detail['quantity'], precioPerro),
                ),

            const Divider(),

            // Mostrar el total general
            buildTableRow(
              cantidad: null,
              descripcion: 'Total General',
              total: totalGeneral,
              isBold: true,
              backgroundColor: Colors.orange[100],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuantityPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                child: const Text('Finalizar pedido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar la cabecera de la tabla
  Widget buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.orange,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Cantidad',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Método para crear una fila de la tabla
  Widget buildTableRow({
    required int? cantidad, // Cambiamos a nullable (int?)
    required String descripcion,
    required int total,
    bool isBold = false,
    Color? backgroundColor,
  }) {
    final numberFormat = NumberFormat('#,##0.00'); // Formato para el total

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              cantidad != null
                  ? cantidad.toString()
                  : '', // Verifica si es null
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              descripcion,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '\$${numberFormat.format(total)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Método para calcular el total basado en la cantidad y el precio
  int calcularTotal(int cantidad, int precio) {
    return cantidad * precio;
  }
}
