<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:5173',
        'http://127.0.0.1:5173',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost',
        'http://127.0.0.1',
        'capacitor://localhost',
        'http://localhost:8080',
        'http://localhost:8100',
        'http://localhost:19006'
    ],
    'allowed_origins_patterns' => [
        '#^http://192\.168\.#', // Local network IPs
        '#^http://172\.#',      // Docker networks
        '#^http://10\.#'        // VPN/internal networks
    ],
    'allowed_headers' => [
        'Content-Type',
        'X-Auth-Token',
        'Origin',
        'Authorization',
        'Accept',
        'X-Requested-With'
    ],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];