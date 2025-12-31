import csv
import random
import os
from datetime import datetime, timedelta
from faker import Faker

fake = Faker(['es_CO'])
os.makedirs('data', exist_ok=True)

# --- CONFIGURACIÓN ---
NUM_TIENDAS = 30
NUM_PRODUCTOS = 100
NUM_CLIENTES = 1200
NUM_VENDEDORES = 150
FILAS_VENTAS = 20000

# --- CATEGORÍAS REALISTAS DE RETAIL ---
categorias_productos = {
    'Herramientas': ['Taladro', 'Sierra Eléctrica', 'Lijadora', 'Martillo', 'Destornillador', 'Llave Inglesa'],
    'Construcción': ['Cemento Portland', 'Arena', 'Ladrillo', 'Varilla', 'Malla Electrosoldada', 'Tubería PVC'],
    'Pintura': ['Pintura Latex', 'Esmalte', 'Thinner', 'Brocha', 'Rodillo', 'Sellador'],
    'Eléctricos': ['Cable THW', 'Toma Corriente', 'Interruptor', 'Bombillo LED', 'Extensión', 'Cinta Aislante'],
    'Plomería': ['Llave de Paso', 'Tubo PVC', 'Codo 90°', 'Válvula Check', 'Sifón', 'Flexible Agua'],
    'Iluminación': ['Lámpara LED', 'Reflector', 'Aplique Pared', 'Foco Ahorrador', 'Tira LED'],
    'Pisos': ['Cerámica', 'Porcelanato', 'Piso Laminado', 'Alfombra', 'Vinilo'],
    'Jardín': ['Pala', 'Rastrillo', 'Manguera', 'Tijera Podar', 'Maceta', 'Tierra Abonada'],
    'Baño': ['Sanitario', 'Lavamanos', 'Grifería', 'Ducha', 'Espejo', 'Mueble Baño'],
    'Cocina': ['Lavaplatos', 'Grifería Cocina', 'Campana Extractora', 'Mueble Cocina'],
}

# --- CIUDADES COLOMBIANAS ---
ciudades_col = ['Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Bucaramanga', 
                'Pereira', 'Cartagena', 'Ibagué', 'Manizales', 'Villavicencio']

# --- 1. GENERAR PRODUCTOS REALISTAS ---
lista_productos = []
pid = 1000
for categoria, items in categorias_productos.items():
    for item in items:
        # Precios realistas según categoría
        if categoria in ['Construcción', 'Pisos', 'Baño', 'Cocina']:
            precio_base = round(random.uniform(50000, 800000), 2)
        elif categoria in ['Herramientas', 'Eléctricos']:
            precio_base = round(random.uniform(25000, 350000), 2)
        else:
            precio_base = round(random.uniform(10000, 200000), 2)
        
        lista_productos.append({
            'id': f'PROD-{pid}',
            'nombre': f'{item} {random.choice(["Premium", "Estándar", "Profesional", "Hogar", "Industrial"])}',
            'cat': categoria,
            'precio_base': precio_base
        })
        pid += 1

# Completar hasta 100 productos con variantes (sin duplicar IDs)
variantes = ["Plus", "Eco", "Pro", "Max", "V2", "Deluxe"]
idx_variante = 0
while len(lista_productos) < NUM_PRODUCTOS:
    base = random.choice(lista_productos[:60])
    lista_productos.append({
        'id': f'PROD-{pid}',
        'nombre': f'{base["nombre"]} {variantes[idx_variante % len(variantes)]}',
        'cat': base['cat'],
        'precio_base': round(base['precio_base'] * random.uniform(0.8, 1.3), 2)
    })
    pid += 1
    idx_variante += 1

# --- 2. GENERAR TIENDAS (Sodimac Style) ---
tiendas = []
zonas = ['Norte', 'Sur', 'Centro', 'Occidente', 'Oriente', 'Calle 80', 'Autopista', 'Suba']
for i in range(NUM_TIENDAS):
    ciudad = random.choice(ciudades_col)
    tiendas.append({
        'nombre': f"Sodimac {ciudad} {random.choice(zonas)}",
        'ciudad': ciudad
    })

# --- 3. GENERAR CLIENTES REALISTAS ---
# Los clientes están en las mismas ciudades donde hay tiendas
clientes = []
for _ in range(NUM_CLIENTES):
    ciudad = random.choice(ciudades_col)
    clientes.append({
        'nombre': fake.name(),
        'email': fake.unique.email(),
        'city': ciudad
    })

# --- 4. GENERAR VENDEDORES (Asignados a tiendas) ---
vendedores = []
for _ in range(NUM_VENDEDORES):
    tienda = random.choice(tiendas)
    vendedores.append({
        'nombre': fake.name(),
        'email': fake.company_email(),
        'tienda': tienda
    })

# --- 5. GENERACIÓN DEL CSV CON LÓGICA DE NEGOCIO ---
ARCHIVOCSV = "data/raw_sales_data.csv"
with open(ARCHIVOCSV, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['order_id', 'order_date', 'customer_name', 'customer_email', 
                     'customer_city', 'seller_name', 'seller_email', 'product_id', 
                     'product_name', 'category', 'unit_price', 'quantity', 
                     'store_name', 'store_city', 'payment_type'])

    for i in range(1, FILAS_VENTAS + 1):
        c = random.choice(clientes)
        v = random.choice(vendedores)
        p = random.choice(lista_productos)
        
        # LÓGICA: Los clientes tienden a comprar en tiendas de su ciudad (80%)
        if random.random() < 0.8:
            # Buscar tienda en la ciudad del cliente
            tiendas_locales = [t for t in tiendas if t['ciudad'] == c['city']]
            if tiendas_locales:
                tienda_venta = random.choice(tiendas_locales)
                # Reasignar vendedor de esa tienda
                vendedores_tienda = [vend for vend in vendedores if vend['tienda'] == tienda_venta]
                if vendedores_tienda:
                    v = random.choice(vendedores_tienda)
        
        # Precio con variación (descuentos ocasionales)
        precio_final = p['precio_base']
        if random.random() < 0.15:  # 15% de descuento ocasional
            precio_final = round(precio_final * random.uniform(0.7, 0.95), 2)
        
        # Cantidades más realistas
        if p['cat'] in ['Construcción', 'Pintura']:
            cantidad = random.randint(1, 10)  # Materiales en mayor cantidad
        elif p['cat'] in ['Herramientas', 'Eléctricos']:
            cantidad = random.randint(1, 3)   # Herramientas pocas unidades
        else:
            cantidad = random.randint(1, 5)
        
        # Métodos de pago más realistas
        metodos_pago = ['Tarjeta Crédito', 'Tarjeta Débito', 'Efectivo', 'Transferencia', 'Tarjeta Sodimac']
        pesos_pago = [0.35, 0.25, 0.15, 0.10, 0.15]  # Probabilidades
        
        writer.writerow([
            f'ORD-{100000+i}',
            fake.date_between(start_date='-2y', end_date='today'),
            c['nombre'], c['email'], c['city'],
            v['nombre'], v['email'],
            p['id'], p['nombre'], p['cat'],
            precio_final,
            cantidad,
            v['tienda']['nombre'], v['tienda']['ciudad'],
            random.choices(metodos_pago, weights=pesos_pago)[0]
        ])

print(f"✅ Dataset generado: {FILAS_VENTAS} ventas")
print(f"📊 {len(lista_productos)} productos en {len(categorias_productos)} categorías")
print(f"🏪 {NUM_TIENDAS} tiendas en {len(ciudades_col)} ciudades")
print(f"👥 {NUM_CLIENTES} clientes, {NUM_VENDEDORES} vendedores")