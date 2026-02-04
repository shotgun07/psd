import React, { useState } from 'react';
import { Container, TextField, Button, Typography, Card, CardContent } from '@mui/material';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { Client, Databases } from 'appwrite';

const client = new Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('your-project-id');

const databases = new Databases(client);

function TrackOrder() {
    const [orderId, setOrderId] = useState('');
    const [order, setOrder] = useState(null);

    const trackOrder = async () => {
        try {
            const response = await databases.getDocument('main_db', 'orders', orderId);
            setOrder(response);
        } catch (error) {
            console.error('Error tracking order:', error);
        }
    };

    return (
        <Container maxWidth="md" style={{ marginTop: '20px' }}>
            <Typography variant="h4" align="center" gutterBottom>
                تتبع طلبك
            </Typography>
            <TextField
                label="رقم الطلب"
                value={orderId}
                onChange={(e) => setOrderId(e.target.value)}
                fullWidth
                margin="normal"
            />
            <Button variant="contained" onClick={trackOrder} fullWidth>
                تتبع
            </Button>
            {order && (
                <Card style={{ marginTop: '20px' }}>
                    <CardContent>
                        <Typography>حالة الطلب: {order.status}</Typography>
                        {order.driver_lat && (
                            <MapContainer center={[order.driver_lat, order.driver_lng]} zoom={15} style={{ height: '300px', width: '100%', marginTop: '10px' }}>
                                <TileLayer
                                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                />
                                <Marker position={[order.driver_lat, order.driver_lng]}>
                                    <Popup>موقع السائق</Popup>
                                </Marker>
                            </MapContainer>
                        )}
                    </CardContent>
                </Card>
            )}
        </Container>
    );
}

export default TrackOrder;