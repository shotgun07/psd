import React, { useEffect, useState } from 'react';
import { Card, CardContent, Typography, Grid } from '@mui/material';
import { Client, Databases } from 'appwrite';

const client = new Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Replace with your endpoint
    .setProject('your-project-id'); // Replace with your project ID

const databases = new Databases(client);

function Dashboard() {
    const [stats, setStats] = useState({ orders: 0, drivers: 0, revenue: 0 });

    useEffect(() => {
        // Fetch stats from Appwrite
        const fetchStats = async () => {
            try {
                const orders = await databases.listDocuments('main_db', 'orders');
                const drivers = await databases.listDocuments('main_db', 'geohash_index', [
                    { key: 'entity_type', value: 'driver' }
                ]);
                // Calculate revenue from transactions
                const transactions = await databases.listDocuments('main_db', 'transactions');
                const revenue = transactions.documents.reduce((sum, t) => sum + t.amount, 0);

                setStats({
                    orders: orders.total,
                    drivers: drivers.total,
                    revenue: revenue
                });
            } catch (error) {
                console.error('Error fetching stats:', error);
            }
        };
        fetchStats();
    }, []);

    return (
        <div>
            <Typography variant="h4" gutterBottom>
                Dashboard
            </Typography>
            <Grid container spacing={3}>
                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography color="textSecondary" gutterBottom>
                                Total Orders
                            </Typography>
                            <Typography variant="h5">
                                {stats.orders}
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography color="textSecondary" gutterBottom>
                                Active Drivers
                            </Typography>
                            <Typography variant="h5">
                                {stats.drivers}
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} md={4}>
                    <Card>
                        <CardContent>
                            <Typography color="textSecondary" gutterBottom>
                                Total Revenue
                            </Typography>
                            <Typography variant="h5">
                                ${stats.revenue}
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>
        </div>
    );
}

export default Dashboard;