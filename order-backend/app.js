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
    changesMade: Boolean,
    modifications: [ModificationSchema]
});

const Order = mongoose.model('Order', OrderSchema, 'ordenes');

app.post('/api/tienda', async (req, res) => {
    const orderData = req.body;
    console.log(typeof req.body.customizations);
    try {
        const newOrder = new Order(orderData);
        await newOrder.save();
        res.status(201).json({ message: 'Order created successfully', order: newOrder });
    } catch (error) {
        res.status(500).json({ message: 'Error creating order', error });
    }
});

app.get('/api/tienda/orderId/:orderId', async (req, res) => {
    const { orderId } = req.params; // Obtener el orderId de los parámetros de la URL

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

// Escuchar en el puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
