import React, { useEffect, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper } from '@mui/material';
import { Client, Databases } from 'appwrite';

const client = new Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('your-project-id');

const databases = new Databases(client);

function Drivers() {
    const [drivers, setDrivers] = useState([]);

    useEffect(() => {
        const fetchDrivers = async () => {
            try {
                const response = await databases.listDocuments('main_db', 'geohash_index', [
                    { key: 'entity_type', value: 'driver' }
                ]);
                setDrivers(response.documents);
            } catch (error) {
                console.error('Error fetching drivers:', error);
            }
        };
        fetchDrivers();
    }, []);

    return (
        <div>
            <h2>Driver Monitoring</h2>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>ID</TableCell>
                            <TableCell>Name</TableCell>
                            <TableCell>Rating</TableCell>
                            <TableCell>Status</TableCell>
                            <TableCell>Location</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {drivers.map((driver) => (
                            <TableRow key={driver.$id}>
                                <TableCell>{driver.entity_id}</TableCell>
                                <TableCell>{driver.name}</TableCell>
                                <TableCell>{driver.rating}</TableCell>
                                <TableCell>{driver.status}</TableCell>
                                <TableCell>{driver.lat}, {driver.lng}</TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    );
}

export default Drivers;