#!/bin/bash

# Total de pasos
TOTAL=50

# Barra de progreso simple
for ((i=1; i<=TOTAL; i++)); do
    printf "\r[%-*s] %d%%" "$TOTAL" "$(head -c $i < /dev/zero | tr '\0' '=')" $(( i * 100 / TOTAL ))
    sleep 0.1  # Simula el tiempo de ejecución
done

echo -e "\n¡Tarea completada!"
