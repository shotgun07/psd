import React from 'react';
import { Drawer, List, ListItem, ListItemText } from '@mui/material';
import { Link } from 'react-router-dom';

const drawerWidth = 240;

function Sidebar() {
    return (
        <Drawer
            sx={{
                width: drawerWidth,
                flexShrink: 0,
                '& .MuiDrawer-paper': {
                    width: drawerWidth,
                    boxSizing: 'border-box',
                },
            }}
            variant="permanent"
            anchor="left"
        >
            <List>
                <ListItem button component={Link} to="/">
                    <ListItemText primary="Dashboard" />
                </ListItem>
                <ListItem button component={Link} to="/orders">
                    <ListItemText primary="Orders" />
                </ListItem>
                <ListItem button component={Link} to="/drivers">
                    <ListItemText primary="Drivers" />
                </ListItem>
                <ListItem button component={Link} to="/analytics">
                    <ListItemText primary="Analytics" />
                </ListItem>
            </List>
        </Drawer>
    );
}

export default Sidebar;