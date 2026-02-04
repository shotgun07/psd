import React from 'react';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';
import { Link } from 'react-router-dom';

function Navbar() {
    return (
        <AppBar position="static">
            <Toolbar>
                <Typography variant="h6" style={{ flexGrow: 1 }}>
                    OBLNS
                </Typography>
                <Button color="inherit" component={Link} to="/">الرئيسية</Button>
                <Button color="inherit" component={Link} to="/track">تتبع الطلب</Button>
            </Toolbar>
        </AppBar>
    );
}

export default Navbar;