#!/usr/bin/env bash
set -euo pipefail

echo "=== Preparando claves SSH ==="

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

for node in master worker1 worker2; do
    source_key=".vagrant/machines/$node/virtualbox/private_key"
    target_key="$HOME/.ssh/practica1_$node"

    if [[ ! -f "$source_key" ]]; then
        echo "ERROR: No existe la clave SSH de $node"
        exit 1
    fi

    cp "$source_key" "$target_key"
    chmod 600 "$target_key"
done

# Limpiar identificaciones SSH antiguas de las VM locales
for ip in 192.168.56.10 192.168.56.11 192.168.56.12; do
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$ip" 2>/dev/null || true
done

echo "=== Comprobando conexiones ==="

echo "=== Esperando conectividad de los tres nodos ==="

MAX_INTENTOS=12
INTERVALO=5
CONEXION_OK=false

for ((intento=1; intento<=MAX_INTENTOS; intento++)); do
    echo "Intento $intento de $MAX_INTENTOS..."

    if ansible -i ansible/inventory/hosts.ini all -m ping; then
        echo "Los tres nodos responden correctamente."
        CONEXION_OK=true
        break
    fi

    echo "Algún nodo todavía no responde. Reintentando..."
    sleep "$INTERVALO"
done

if [[ "$CONEXION_OK" != "true" ]]; then
    echo "ERROR: No fue posible conectar con todos los nodos."
    exit 1
fi

echo "=== Desplegando infraestructura Big Data ==="

ansible-playbook \
    -i ansible/inventory/hosts.ini \
    ansible/site.yml

echo "=== Despliegue completado correctamente ==="
