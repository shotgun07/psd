import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js';
import { Client, Databases } from 'appwrite';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

const client = new Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('your-project-id');

const databases = new Databases(client);

function Analytics() {
    const [data, setData] = useState({
        labels: [],
        datasets: []
    });

    useEffect(() => {
        const fetchAnalytics = async () => {
            try {
                const orders = await databases.listDocuments('main_db', 'orders');
                // Simple analytics: orders per day
                const orderCounts = {};
                orders.documents.forEach(order => {
                    const date = new Date(order.$createdAt).toDateString();
                    orderCounts[date] = (orderCounts[date] || 0) + 1;
                });
                const labels = Object.keys(orderCounts);
                const counts = Object.values(orderCounts);

                setData({
                    labels,
                    datasets: [{
                        label: 'Orders per Day',
                        data: counts,
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1
                    }]
                });
            } catch (error) {
                console.error('Error fetching analytics:', error);
            }
        };
        fetchAnalytics();
    }, []);

    return (
        <div>
            <h2>Analytics</h2>
            <Line data={data} />
        </div>
    );
}

export default Analytics;