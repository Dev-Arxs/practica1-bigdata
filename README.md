
# Práctica 1 — Infraestructura Big Data virtualizada

## Arquitectura

- Master: 192.168.56.10
- Worker 1: 192.168.56.11
- Worker 2: 192.168.56.12

## Tecnologías

- Vagrant y VirtualBox: infraestructura virtual.
- Ansible: configuración automatizada.
- Docker: ejecución de los servicios del clúster.
- HDFS y Spark: servicios Big Data distribuidos en contenedores Docker.

## 1. Arranque de la infraestructura

Desde la raíz del proyecto:

```bash
vagrant up
```

## 2. Aprovisionamiento con Ansible

Desde WSL, en la raíz del proyecto:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml
```

### Comprobación de conectividad de los nodos y el Docker:

```bash
ansible -i ansible/inventory/hosts.ini all -m ping
ansible -i ansible/inventory/hosts.ini bigdata -m command -a "docker --version"
```

## 3. Interfaces Web de monitorización

Una vez desplegado todo, las interfaces web están disponibles en:

- HDFS NameNode: http://192.168.56.10:9870 (pestaña Datanodes para ver los 2 nodos vivos).
- Spark Master: http://192.168.56.10:8080 (sección Workers para ver los 2 workers en estado ALIVE).

---

## 4. Subir un fichero a HDFS

Conectarse por SSH al nodo master y entrar en el contenedor de NameNode:

```bash
vagrant ssh master
sudo docker exec -it namenode bash
```

Crear el directorio, subir el fichero y verificar que está correctamente subido:

```bash
hdfs dfs -mkdir -p /user/datos
echo "Prueba de almacenamiento en HDFS" > /tmp/archivo_prueba.txt
hdfs dfs -put /tmp/archivo_prueba.txt /user/datos/archivo_prueba.txt
hdfs dfs -ls /user/datos
```

Comprobar que en los 2 workers aparece factor de replicación = 2:

```bash
hdfs fsck /user/datos/archivo_prueba.txt -files -blocks -locations
```

---

## 5. Ejecutar un Job Spark en el clúster

El script `scripts/spark_job.py` lee el archivo desde HDFS, distribuye las tareas en 4 particiones y guarda el resultado en HDFS.

Desde el master, lanzar el trabajo con `spark-submit`:

```bash
sudo docker exec -e SPARK_LOCAL_IP=192.168.56.10 -i spark-master /opt/spark/bin/spark-submit \
  --master spark://192.168.56.10:7077 \
  --conf spark.driver.host=192.168.56.10 \
  --deploy-mode client \
  --executor-memory 512M \
  --total-executor-cores 2 \
  /vagrant/scripts/spark_job.py
```

Comprobar el resultado generado en HDFS:

```bash
sudo docker exec -it namenode hdfs dfs -ls /user/output/resultado_wordcount
sudo docker exec -it namenode hdfs dfs -cat /user/output/resultado_wordcount/*.csv
```

---

## 6. Comprobación de tolerancia a fallos

Para verificar que los datos siguen disponibles si se para un worker:

1. Desde la máquina anfitriona, apagar `worker1`:
   ```bash
   vagrant halt worker1
   ```

2. Desde el master, comprobar que el archivo sigue siendo accesible a través de la réplica en `worker2`:
   ```bash
   sudo docker exec -it namenode hdfs dfs -cat /user/datos/archivo_prueba.txt
   ```

