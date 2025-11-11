Mini Tienda 🛒

Proyecto de ejemplo de tienda de productos con Node.js, MySQL y Nginx.
Incluye un CRUD de productos (crear, leer, actualizar y eliminar) y replicación de base de datos para pruebas de balanceo de lectura.

La web permite:
- Ver todos los productos guardados.
- Crear nuevos productos.
- Editar productos existentes.
- Eliminar productos.
- Interactuar con la base de datos a través de un servidor Node.js.
- Balanceo de lectura mediante Nginx entre réplicas MySQL.

Estructura del proyecto:
Proyecto/
  scripts/
    setup-master.sh      # Script de instalación y configuración de MySQL Primario
    setup-replica.sh     # Script de instalación y configuración de MySQL Réplica
    setup-nginx.sh       # Script de instalación y configuración de Nginx
  server.js               # Servidor Node.js con CRUD de productos
  package.json            # Dependencias de Node.js
  README.md               # Este archivo

Requisitos:
- Vagrant
- VirtualBox
- Node.js (>= 20)
- MySQL 8
- Navegador web
- curl para pruebas desde CLI (opcional)

Configuración y ejecución:

1. Levantar las máquinas virtuales:
Dentro del directorio del proyecto, ejecutar:
vagrant up

Esto hará:
- Instalar y configurar MySQL Primario (db-primary) y dos réplicas (db-replica1 y db-replica2) con replicación GTID.
- Instalar y configurar Nginx como load balancer (lb-nginx).

2. Conexión al servidor Node.js:
vagrant ssh lb-nginx
cd /var/www/app
npm install
node server.js

El servidor Node.js correrá en el puerto 3000 y se conectará automáticamente a la base de datos MySQL Primario.

3. Configuración de Nginx:
- Nginx balancea las lecturas entre las réplicas en el puerto 3307.
- Las escrituras se realizan al Primario en el puerto 3308.
- Para ver la configuración: /etc/nginx/nginx.conf o los archivos en /etc/nginx/conf.d/.

Endpoints del CRUD:

Método  Ruta               Descripción
GET     /productos         Listar todos los productos
POST    /productos         Crear un producto
PUT     /productos/:id     Editar un producto
DELETE  /productos/:id     Eliminar un producto

Ejemplo con curl:

# Listar productos
curl http://localhost:3000/productos

# Crear producto
curl -X POST http://localhost:3000/productos -H "Content-Type: application/json" -d '{"nombre":"Kiwi","categoria":"Frutas","precio":3000,"stock":50}'

# Editar producto
curl -X PUT http://localhost:3000/productos/1 -H "Content-Type: application/json" -d '{"nombre":"Manzana Verde","categoria":"Frutas","precio":2600,"stock":120}'

# Eliminar producto
curl -X DELETE http://localhost:3000/productos/1

Verificación de replicación MySQL:
Desde las réplicas:
sudo mysql -u root
SHOW REPLICA STATUS\G

- Replica_IO_Running y Replica_SQL_Running deben ser Yes.
- Los cambios realizados en la base de datos del primario se reflejarán en las réplicas.

Pruebas de balanceo en Nginx:

for i in {1..10}; do
  mysql -u app -papppass -h 192.168.56.20 -P 3307 -e "SELECT @@hostname;"
done

- Esto consulta repetidamente a Nginx, que balanceará las lecturas entre las réplicas.

Comandos útiles:
- Reiniciar servidor Node.js: node server.js
- Reiniciar Nginx: sudo systemctl restart nginx
- Verificar Nginx: sudo nginx -t
- Acceso MySQL Primario: mysql -u app -p -h 192.168.56.10
- Acceso MySQL Réplica: mysql -u repl -p -h 192.168.56.11

Notas:
- Instalar dependencias de Node.js antes de ejecutar el servidor: npm install
- Para mantener la réplica funcionando correctamente, el usuario repl debe tener permisos de replicación y MySQL GTID debe estar habilitado.
- La web apunta al Primario para escrituras, y las réplicas reciben los cambios automáticamente para balanceo de lectura.
