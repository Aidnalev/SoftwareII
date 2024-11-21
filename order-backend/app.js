const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.json());

mongoose.connect('mongodb+srv://aidnalev:1GSvtjCrEMvX5xmJ@softwareii.cjlvo.mongodb.net/tienda?retryWrites=true&w=majority&appName=SoftwareII', {
}).then(() => {
    console.log('Connected to MongoDB Atlas');
}).catch((err) => {
    console.error('MongoDB connection error:', err);
});

const CounterSchema = new mongoose.Schema({
    _id: String,
    sequence_value: Number
});

const Counter = mongoose.model('Counter', CounterSchema);

const PriceSchema = new mongoose.Schema({
    _id: String,
    hamburguesa: String,
    perro: String
});

const Price = mongoose.model('Price', PriceSchema, 'prices');


async function getNextSequenceValue(sequenceName) {
    const counter = await Counter.findByIdAndUpdate(
        sequenceName,
        { $inc: { sequence_value: 1 } },
        { new: true, upsert: true }
    );
    return counter.sequence_value;
}

const ItemOrderedSchema = new mongoose.Schema({
    itemId: String,
    productName: String,
    quantity: Number,
    price: Number,
    customizations: { type: Map, of: Boolean }
});

const ModificationSchema = new mongoose.Schema({
    productId: String,
    fieldChanged: String,
    previousValue: String,
    newValue: String
});

const OrderSchema = new mongoose.Schema({
    orderId: String,
    orderNumber: Number,
    orderTime: Date,
    itemsOrdered: [ItemOrderedSchema],
    totalPrice: Number
});

const Order = mongoose.model('Order', OrderSchema, 'ordenes');

app.post('/api/tienda', async (req, res) => {
    const orderData = req.body;
    console.log(typeof req.body.customizations);
    try {
        const nextOrderId = await getNextSequenceValue('orderId');
        orderData.orderId = nextOrderId.toString();
        const newOrder = new Order(orderData);
        await newOrder.save();
        res.status(201).json({ message: 'Order created successfully', order: newOrder });
    } catch (error) {
        res.status(500).json({ message: 'Error creating order', error });
    }
});

app.get('/api/tienda/orderId/:orderId', async (req, res) => {
    const { orderId } = req.params; // Obtener el orderId de los par�metros de la URL

    try {
        const order = await Order.findOne({ orderId }); // Buscar la orden usando orderId
        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.status(200).json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving order', error });
    }
});

app.get('/api/prices', async (req, res) => {
    try {
        const prices = await Price.findById('prices'); // Busca el documento por el ID "prices"
        if (!prices) {
            return res.status(404).json({ message: 'Prices not found' });
        }
        res.status(200).json(prices);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving prices', error });
    }
});
// Obtener �rdenes por rango de fechas con validaciones y paginaci�n
app.get('/api/tienda/date-range', async (req, res) => {
    const { startDate, endDate, limit, offset } = req.query;

    // Validar que se proporcionen ambas fechas
    if (!startDate || !endDate) {
        return res.status(400).json({ message: 'Both startDate and endDate are required' });
    }

    try {
        // Convertir las fechas a objetos Date
        const start = new Date(startDate);
        const end = new Date(endDate);

        // Validar que las fechas sean v�lidas
        if (isNaN(start) || isNaN(end)) {
            return res.status(400).json({ message: 'Invalid date format' });
        }

        // Validar que la fecha de inicio no sea posterior a la fecha de fin
        if (start > end) {
            return res.status(400).json({ message: 'startDate cannot be after endDate' });
        }

        // Configurar paginaci�n
        const resultsLimit = parseInt(limit, 10) || 10; // L�mite predeterminado: 10
        const resultsOffset = parseInt(offset, 10) || 0; // Desplazamiento predeterminado: 0

        // Buscar �rdenes dentro del rango de fechas con paginaci�n
        const orders = await Order.find({
            orderTime: {
                $gte: start, // Mayor o igual que la fecha de inicio
                $lte: end    // Menor o igual que la fecha de fin
            }
        })
            .skip(resultsOffset) // Saltar registros seg�n el offset
            .limit(resultsLimit) // Limitar el n�mero de resultados
            .sort({ orderTime: 1 }); // Ordenar por fecha (ascendente)

        // Contar el total de �rdenes en el rango sin paginaci�n
        const totalOrders = await Order.countDocuments({
            orderTime: {
                $gte: start,
                $lte: end
            }
        });

        // Enviar la respuesta con los resultados y la informaci�n de paginaci�n
        res.status(200).json({
            totalOrders,
            displayedOrders: orders.length,
            limit: resultsLimit,
            offset: resultsOffset,
            orders
        });
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving orders by date range', error });
    }
});

// Escuchar en el puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
