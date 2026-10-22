
# Práctica 1 — Infraestructura Big Data virtualizada

## Arquitectura

- Master: 192.168.56.10
- Worker 1: 192.168.56.11
- Worker 2: 192.168.56.12

## Tecnologías

- Vagrant y VirtualBox: infraestructura virtual.
- Ansible: configuración automatizada.
- Docker: ejecución de los servicios del clúster.
- HDFS y Spark: servicios Big Data (pendientes de integración).

## Arranque de la infraestructura

Desde la raíz del proyecto:

```bash
vagrant up
```

## Configuración de los nodos

Desde WSL, en la raíz del proyecto:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml
```

## Comprobación de conectividad

```bash
ansible -i ansible/inventory/hosts.ini all -m ping
```

## Comprobación de Docker

```bash
ansible -i ansible/inventory/hosts.ini bigdata -m command -a "docker --version"
```
