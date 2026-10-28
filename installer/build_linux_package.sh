#!/usr/bin/env bash
set -e

echo "================================================================="
echo "       FARMSYS ECUADOR - EMPAQUETADOR DE PRODUCCIÓN LINUX       "
echo "================================================================="
echo ""

mkdir -p installer/output

echo "[1/3] Descargando y validando dependencias..."
flutter pub get

echo ""
echo "[2/3] Compilando binario de release con ofuscación de símbolos..."
flutter build linux --release --obfuscate --split-debug-info=build/linux/debug-info

echo ""
echo "[3/3] Empaquetando distribución portable (.tar.gz)..."
tar -czvf "installer/output/FarmSys_Linux_x64_v1.0.2.tar.gz" -C build/linux/x64/release/bundle .

echo ""
echo "================================================================="
echo "  ÉXITO: Paquete generado en:"
echo "  installer/output/FarmSys_Linux_x64_v1.0.2.tar.gz"
echo "================================================================="

