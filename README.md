# 💊 FarmSys — Sistema de Farmacia y Punto de Venta (Flutter Desktop)

Sistema de punto de venta (POS), inventario físico por lotes (FEFO) y facturación electrónica para farmacias en Ecuador, construido con **Flutter Desktop (Dart nativo)** para Windows, macOS y Linux.

---

## 🏛️ Arquitectura y Principios de Diseño

El proyecto está diseñado bajo **Clean Architecture** con estructura **Feature-First** y cumplimiento estricto de **principios SOLID**:

* **S (Single Responsibility):** Los widgets únicamente renderizan la UI y reaccionan a eventos. Toda la lógica de negocio vive en Notifiers (`Riverpod`) y los accesos a datos en Repositorios y DAOs (`Drift/SQLite`).
* **O (Open/Closed):** Nuevos métodos de pago (ej. billeteras digitales) o tipos de impresoras se integran extendiendo contratos abstractos (`PaymentMethodHandler`, `TicketPrinter`) sin modificar el motor de cobro base.
* **L (Liskov Substitution):** Todas las interfaces de repositorios y hardware son intercambiables con mocks para pruebas unitarias.
* **I (Interface Segregation):** Contratos pequeños y especializados (`ReceiptPrintable`, `CashDrawerKickable`, `BarcodeScannable`).
* **D (Dependency Inversion):** La lógica de negocio depende de abstracciones inyectadas mediante **Riverpod**.
* **DRY (Don't Repeat Yourself):** Motores de cálculo reutilizables para Módulo 11 del SRI (`SriModulo11`), liquidación de IVA 15% (`TaxCalculator`) y ordenamiento FEFO (`FefoComparator`).

---

## 📁 Estructura del Proyecto

```text
FarmSys/
├── lib/
│   ├── main.dart                 # Inicialización y control de ventana nativa (window_manager)
│   ├── app.dart                  # Configuración de MaterialApp.router y temas
│   │
│   ├── core/                     # Capa transversal y contratos base
│   │   ├── constants/            # Colores, IVA 15%, roles y códigos SRI
│   │   ├── database/             # Base de datos Drift (SQLite) en background isolate
│   │   │   └── tables/           # Tablas: lotes, ventas, movimientos, productos, etc.
│   │   ├── hardware/             # Servicios de hardware (impresora térmica, gaveta, escáner)
│   │   ├── router/               # Navegación declarativa (GoRouter)
│   │   ├── theme/                # Tema visual adaptativo para escritorio
│   │   └── utils/                # Utilidades compartidas (FEFO, Módulo 11, IVA, formateadores)
│   │
│   ├── features/                 # Módulos organizados por característica (Feature-First)
│   │   ├── pos_ventas/           # Punto de venta, carrito, cobro y arqueo de caja
│   │   ├── inventario/           # Trazabilidad de lotes, kardex y vencimientos
│   │   ├── facturacion_sri/      # Firma electrónica PKCS#12, XML y RIDE
│   │   ├── catalogo_productos/   # Catálogo de medicamentos y presentaciones
│   │   ├── clientes/             # Ficha de clientes (Cédula / RUC)
│   │   └── proveedores/          # Gestión de distribuidores farmacéuticos
│   │
│   └── shared/                   # Componentes UI reutilizables (Botones, Tablas, Modales, Badges)
│
└── test/                         # Pruebas unitarias de algoritmos de negocio y componentes
```

---

## 🚀 Comandos de Ejecución y Compilación

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Generar código de base de datos (Drift / SQLite)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Ejecutar en modo desarrollo
* En Windows:
  ```bash
  flutter run -d windows
  ```
* En Linux:
  ```bash
  flutter run -d linux
  ```
* En macOS:
  ```bash
  flutter run -d macos
  ```

### 4. Ejecutar pruebas unitarias
```bash
flutter test
```

### 5. Compilar binario final para producción
```bash
# Windows (.exe portable/instalador)
flutter build windows --release

# Linux (binario nativo)
flutter build linux --release
```

---

## ⌨️ Atajos de Teclado en el Punto de Venta (POS)

* <kbd>F1</kbd>: Cobrar y emitir comprobante / ticket.
* <kbd>F2</kbd>: Foco inmediato en el buscador de medicamentos o código de barras.
* <kbd>Enter</kbd>: Agregar producto al carrito desde el buscador o confirmar diálogos.
* <kbd>Esc</kbd>: Cancelar modal o vaciar el carrito actual.
