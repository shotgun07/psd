import React, { useEffect, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Button } from '@mui/material';
import { Client, Databases } from 'appwrite';

const client = new Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('your-project-id');

const databases = new Databases(client);

function Orders() {
    const [orders, setOrders] = useState([]);

    useEffect(() => {
        const fetchOrders = async () => {
            try {
                const response = await databases.listDocuments('main_db', 'orders');
                setOrders(response.documents);
            } catch (error) {
                console.error('Error fetching orders:', error);
            }
        };
        fetchOrders();
    }, []);

    const updateOrderStatus = async (orderId, status) => {
        try {
            await databases.updateDocument('main_db', 'orders', orderId, { status });
            setOrders(orders.map(order => order.$id === orderId ? { ...order, status } : order));
        } catch (error) {
            console.error('Error updating order:', error);
        }
    };

    return (
        <div>
            <h2>Order Management</h2>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>ID</TableCell>
                            <TableCell>Pickup</TableCell>
                            <TableCell>Dropoff</TableCell>
                            <TableCell>Status</TableCell>
                            <TableCell>Actions</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {orders.map((order) => (
                            <TableRow key={order.$id}>
                                <TableCell>{order.$id}</TableCell>
                                <TableCell>{order.pickup_address}</TableCell>
                                <TableCell>{order.dropoff_address}</TableCell>
                                <TableCell>{order.status}</TableCell>
                                <TableCell>
                                    <Button onClick={() => updateOrderStatus(order.$id, 'assigned')}>Assign</Button>
                                    <Button onClick={() => updateOrderStatus(order.$id, 'completed')}>Complete</Button>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    );
}

export default Orders;