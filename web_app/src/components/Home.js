import React from 'react';
import { Container, Typography, Button, Grid, Card, CardContent } from '@mui/material';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

function Home() {
    const position = [32.8872, 13.1913]; // Tripoli, Libya

    return (
        <Container maxWidth="lg" style={{ marginTop: '20px' }}>
            <Typography variant="h3" align="center" gutterBottom>
                OBLNS - أقوى منصة توصيل في الشرق الأوسط
            </Typography>
            <Grid container spacing={3}>
                <Grid item xs={12} md={6}>
                    <Card>
                        <CardContent>
                            <Typography variant="h5">اطلب توصيل</Typography>
                            <Typography>خدمات توصيل سريعة وموثوقة عبر المنطقة</Typography>
                            <Button variant="contained" color="primary" style={{ marginTop: '10px' }}>
                                ابدأ الآن
                            </Button>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} md={6}>
                    <MapContainer center={position} zoom={10} style={{ height: '300px', width: '100%' }}>
                        <TileLayer
                            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                        />
                        <Marker position={position}>
                            <Popup>طرابلس، ليبيا</Popup>
                        </Marker>
                    </MapContainer>
                </Grid>
            </Grid>
        </Container>
    );
}

export default Home;