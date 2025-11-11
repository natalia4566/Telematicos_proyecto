#!/bin/bash
set -e

echo "🚀 Instalando Nginx y Node.js..."
sudo apt update -y
sudo apt install -y nginx nodejs npm

# Configurar Nginx como proxy TCP (lecturas y escrituras)
sudo tee /etc/nginx/nginx.conf > /dev/null <<'EOF'
worker_processes auto;
events { worker_connections 1024; }

stream {
    upstream mysql_reads {
        least_conn;
        server 192.168.56.11:3306;
        server 192.168.56.12:3306;
    }

    upstream mysql_writes {
        server 192.168.56.10:3306;
    }

    server {
        listen 3307;
        proxy_pass mysql_reads;
    }

    server {
        listen 3308;
        proxy_pass mysql_writes;
    }
}
EOF

sudo systemctl restart nginx

echo "⚡ Configurando mini app web..."
mkdir -p ~/mini-tienda-web
cd ~/mini-tienda-web

cat <<'EOF' > app.js
const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const PORT = 8080;

app.use(express.json());

const dbRead = mysql.createPool({
  host: '192.168.56.20',
  port: 3307,
  user: 'app',
  password: 'apppass',
  database: 'mini_tienda'
});

const dbWrite = mysql.createPool({
  host: '192.168.56.20',
  port: 3308,
  user: 'app',
  password: 'apppass',
  database: 'mini_tienda'
});

// Endpoint: listar productos
app.get('/productos', async (req, res) => {
  const [rows] = await dbRead.query('SELECT * FROM productos');
  res.json(rows);
});

// Endpoint: agregar producto
app.post('/productos', async (req, res) => {
  const { nombre, precio } = req.body;
  await dbWrite.query('INSERT INTO productos (nombre, precio) VALUES (?, ?)', [nombre, precio]);
  res.json({ mensaje: 'Producto agregado con éxito' });
});

app.listen(PORT, () => console.log(`🛍️ MiniTienda Web corriendo en puerto ${PORT}`));
EOF

npm install express mysql2
nohup node app.js > app.log 2>&1 &
echo "✅ Web app lista en http://192.168.56.20:8080"
