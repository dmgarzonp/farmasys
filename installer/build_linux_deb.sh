#!/usr/bin/env bash
set -e

echo "================================================================="
echo "       FARMSYS ECUADOR - EMPAQUETADOR DEBIAN (.DEB) LINUX        "
echo "================================================================="
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="1.0.0"
OUTPUT_DIR="$ROOT_DIR/installer/output"
mkdir -p "$OUTPUT_DIR"

echo "[1/4] Verificando binarios compilados de Linux..."
if [ ! -d "build/linux/x64/release/bundle" ]; then
    echo "Compilando versión Release para Linux..."
    flutter build linux --release --obfuscate --split-debug-info=build/linux/debug-info
fi

echo "[2/4] Preparando estructura del paquete .deb..."
BUILD_DIR="/tmp/farmsys_build_deb"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/lib/farmsys"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps"

# Copiar bundle de Flutter
cp -r build/linux/x64/release/bundle/* "$BUILD_DIR/usr/lib/farmsys/"

# Enlace simbólico en /usr/bin
ln -s "/usr/lib/farmsys/farmsys" "$BUILD_DIR/usr/bin/farmsys"

# Icono oficial del sistema
cp assets/icons/app_icon.png "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps/farmsys.png"

# Acceso directo .desktop para el menú de aplicaciones de Linux
cat << 'EOF' > "$BUILD_DIR/usr/share/applications/farmsys.desktop"
[Desktop Entry]
Name=FarmSys
Comment=Sistema Integral de Farmacia y Punto de Venta POS
Exec=/usr/bin/farmsys
Icon=farmsys
Terminal=false
Type=Application
Categories=Office;Finance;MedicalSoftware;
StartupWMClass=farmsys
Keywords=farmacia;pos;ventas;sri;medicamentos;
EOF

# Metadatos del paquete DEBIAN/control
cat << EOF > "$BUILD_DIR/DEBIAN/control"
Package: farmsys
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: FarmSys Ecuador <contacto@farmsys.ec>
Depends: libgtk-3-0, libsqlite3-0, libblkid1, liblzma5
Description: FarmSys - Sistema Integral de Farmacia y POS Ecuador
 Sistema de facturación electrónica SRI, gestión de inventario farmacéutico
 con lotes FEFO, semáforo de vencimientos y punto de venta ágil.
EOF

chmod 755 "$BUILD_DIR/DEBIAN"
chmod 644 "$BUILD_DIR/DEBIAN/control"

echo "[3/4] Construyendo instalador .deb con dpkg-deb..."
dpkg-deb --build "$BUILD_DIR" "$OUTPUT_DIR/farmsys_${VERSION}_amd64.deb"

echo "[4/4] Limpiando archivos temporales..."
rm -rf "$BUILD_DIR"

echo ""
echo "================================================================="
echo "  ÉXITO: Instalador Linux .deb generado en:"
echo "  $OUTPUT_DIR/farmsys_${VERSION}_amd64.deb"
echo "================================================================="
