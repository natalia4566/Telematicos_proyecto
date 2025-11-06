🧩 Proyecto: Infraestructura MySQL con Réplicas y Balanceador Nginx 

Este proyecto implementa un entorno distribuido con Vagrant y VirtualBox que simula una infraestructura de base de datos con replicación maestro–réplica de MySQL y un balanceador de carga Nginx.

El entorno incluye:

db-primary: Servidor MySQL principal (maestro)

db-replica1: Primera réplica de lectura

db-replica2: Segunda réplica de lectura

lb-nginx: Servidor Nginx configurado como proxy TCP (puerto 3307 para lecturas, 3308 para escrituras)

🗂️ Estructura del proyecto
Proyecto/
│
├── Vagrantfile                 
├── .gitignore                  
├── mysql-proxy-stream.conf     
├── scripts/                    
│   ├── setup-master.sh          
│   ├── setup-replica1.sh       
│   ├── setup-replica2.sh        
│   └── setup-lb.sh             
└── README.md                   

⚙️ Requisitos previos

Antes de clonar el repositorio, asegúrate de tener instalado:

VirtualBox versión 7.0 o superior

Vagrant versión 2.4 o superior

Git versión 2.0 o superior

 Instalación y puesta en marcha
1. Clonar el repositorio
git clone https://github.com/natalia4566/Servicios-telematicos---Proyecto.git
cd Proyecto-MySQL-Replica

2. Levantar las máquinas virtuales
vagrant up


Esto creará las cuatro VMs:

Máquina	IP	Rol
db-primary	192.168.56.10	Maestro
db-replica1	192.168.56.11	Réplica
db-replica2	192.168.56.12	Réplica
lb-nginx	192.168.56.20	Balanceador

⏳ La primera vez puede tardar algunos minutos mientras se descarga la caja base ubuntu/jammy64.

 Componentes y configuración
db-primary (maestro)

Instala y configura MySQL Server

Crea el usuario de replicación repl

Habilita binlogs (log_bin)

Crea la base de datos de ejemplo mini_tienda

db-replica1 / db-replica2

Se conectan al maestro mediante el usuario repl

Sincronizan automáticamente los datos del maestro

Solo permiten consultas de lectura

lb-nginx

Escucha en los puertos:

3307: Pool de lectura (réplicas)

3308: Maestro (para escrituras)

Distribuye las conexiones con estrategia least_conn

🧪 Pruebas
1. Insertar datos en el maestro
vagrant ssh db-primary
sudo mysql -e "INSERT INTO mini_tienda.productos (nombre,precio,stock) VALUES ('Bolso prueba',50000,4);"

2. Verificar la replicación
vagrant ssh db-replica1
sudo mysql -e "SELECT * FROM mini_tienda.productos;"


El nuevo registro debe aparecer también en la réplica.

3. Consultar desde el balanceador
mysql -h 192.168.56.20 -P 3307 -u app -papppass -e "SELECT * FROM mini_tienda.productos;"

💾 Apagar y reiniciar correctamente las VMs

Para apagar todas:

vagrant halt


Para volver a iniciar:

vagrant up


⚠️ Evita cerrar VirtualBox directamente.

Entrar a una máquina:

vagrant ssh db-primary


Ver logs de MySQL:

sudo tail -f /var/log/mysql/error.log


Probar conexión entre nodos:

mysql -h 192.168.56.11 -u repl -preplpass

🎓 Créditos y propósito educativo

Este entorno fue diseñado con fines educativos y de práctica en:

Servicios Telemáticos 

Replicación de bases de datos

Balanceo de carga TCP con Nginx

Autor: Natalia Cajiao Castillo, Maira Alejandra Balanta, Santiago Miranda, Jorge Cortes 
Carrera: Ingeniería Informática
Proyecto: Infraestructura Distribuida - MySQL con Vagrant
