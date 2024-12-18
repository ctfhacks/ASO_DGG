#!/bin/bash

echo "  ______                  __                                _                              _ "
echo " |  ____|                /_/                               | |                            | |"
echo " | |__     ___    ___    __ _   _ __     ___   _ __      __| |   ___     _ __    ___    __| |"
echo " |  __|   / __|  / __|  / _  | |  _ \   / _ \ |  __|    / _  |  / _ \   |  __|  / _ \  / _  |"
echo " | |____  \__ \ | (__  | (_| | | | | | |  __/ | |      | (_| | |  __/   | |    |  __/ | (_| |"
echo " |______| |___/  \___|  \__,_| |_| |_|  \___| |_|       \__,_|  \___|   |_|     \___|  \__,_|"
echo "                                                                                             "
echo "  Hecho por: D4v1d Gr4nd3"
echo ""

                                                                                             
                                                                                             
#  Calcula la duración del script
SECONDS=0

# Captura los parámetros
redIP=$1;
puertos=$2;
archivo=$3;

# Número de parámetros introducidos
numParams=$#

# Cuenta número de IPs escaneadas
let contadorIP=1
echo -e ""

# Declara variables de colores
RED="\e[31m"
GREEN="\e[92m"
YELLOW="\e[33m"
BLUE="\e[94m"
WHITE="\e[97m"

# Función de ayuda
ayuda(){
    echo -e "${WHITE}"
    echo -e "            [+] Menú de ayuda [+]"
    echo -e "==============================================="
    echo -e $0 "<IP-RED/SUBRED> <RANGO-PUERTOS> <ARCHIVO>"
    echo -e $0 "192.168.1.0/24 22-445 file.txt"
    echo -e ""
}

# Función para escanear puertos a una IP activa
scanPuertos(){
    echo -e "${WHITE}   == Puertos abiertos =="
    # Comprueba los puertos indicados en el rango la IP
    for(( port=$puertoInicial; port < $puertoFin+1; port++ ))
    do
        scan=$(nc -zv $ipFinal $port 2</dev/null)
        cod=$(echo $?)
        if [[ $cod -eq 0 ]]
        then
            # Extrae del archivo tcp.csv el nombre de cada puerto
            namePort=$(cat tcp.csv | grep ",$port," | awk -F ',' {'print $3'} | tr -d '"')
            echo -e "${WHITE}      [-] Puerto "$port" ($namePort)"
        fi
    done
}

# Función para conocer el sistema operativo según el TTL
scanTTL(){
    # Obtiene el TTL
    ttl=$(echo $ping | grep ttl= | awk -F 'ttl=' '{print $2}' | awk -F ' ' '{print $1}')
    echo -e "${WHITE}  [-] TTL: "$ttl
    # Comprueba si es Linux o Windows
    if [[ $ttl -lt 65 ]]
    then
        echo -e "${WHITE}  [-] SO: Linux"
        so="Linux"
    else
        echo -e "${WHITE}  [-] SO: Windows"
        so="Windows"
    fi
}

# Función que escanea todas las IPs y detecta cual está activa
scanIP(){
    # Obtiene la MAC de cada IP con el comando arp
    mac=$(arp -a $ipFinal | awk -F 'at ' {'print $2'} | awk -F ' ' {'print $1'})
    echo -e ""
    echo -e "${WHITE}[+] La IP ${GREEN}"$ipFinal"${WHITE} está activa y su MAC es${GREEN} $mac${WHITE}";
}

# Función que almacena en el archivo indicado los datos capturados en formato CSV
saveCSV(){
    echo $ipFinal,\"$mac\",\"$so\",$ttl,$port,\"$namePort\" >> $archivo
}

# Muestra el número total de IPs posibles según la subred y las escaneadas en tiempo real
porcentajeScan(){
    let contadorIP=contadorIP+1
    # Con \r actualiza el contador sin necesidad de repetir esta línea continuamente
    echo -ne ${BLUE}[$contadorIP/$totalIP]'\r'
}

# Función para la red 255.0.0.0
mascara8(){
    totalIP=16581374
    ipRed=$ip1
    # Itera las 3 últimos partes de la IP
    for(( p2=1; p2 < 256; p2++ ))
    do
        for(( p3=1; p3 < 256; p3++ ))
        do
            for(( p4=1; p4 < 255; p4++ ))
            do
                ipFinal=$ipRed"."$p2"."$p3"."$p4;
                ping=$(ping -c 1 -W 1 $ipFinal)
                cod=$(echo $?)
                # Si la IP responde al ping estará activa y ejecuta las siguientes funciones
                if [[ $cod -eq 0 ]]
                then
                    scanIP
                    scanTTL
                    scanPuertos
                    saveCSV
                fi
                porcentajeScan
            done
        done
    done
}

# Función para la red 255.255.0.0
mascara16(){
    totalIP=65024
    ipRed=$ip1"."$ip2
    # Itera las 2 últimos partes de la IP
    for(( p3=1; p3 < 256; p3++ ))
    do
        for(( p4=1; p4 < 255; p4++ ))
        do
            ipFinal=$ipRed"."$p3"."$p4;
            ping=$(ping -c 1 -W 1 $ipFinal)
            cod=$(echo $?)
            # Si la IP responde al ping estará activa y ejecuta las siguientes funciones
            if [[ $cod -eq 0 ]]
            then
                scanIP
                scanTTL
                scanPuertos
                saveCSV
            fi
            porcentajeScan
        done
    done
}

# Función para la red 255.255.255.0
mascara24(){
    totalIP=254
    ipRed=$ip1"."$ip2"."$ip3
    # Itera la última partes de la IP
    for(( p4=1; p4 < 255; p4++ ))
    do
        ipFinal=$ipRed"."$p4;
        ping=$(ping -c 1 -W 1 $ipFinal)
        cod=$(echo $?)
        # Si la IP responde al ping estará activa y ejecuta las siguientes funciones
        if [[ $cod -eq 0 ]]
        then
            scanIP
            scanTTL
            scanPuertos
            saveCSV
        fi
        porcentajeScan
    done
}

# Debe introducirse justo 3 parámetros, sino ejecutará el código dentro del IF
if ! [[ $numParams -eq 3 ]]
then
    echo -e "${YELLOW}[!] Son necesarios 3 parámetros..."
    ayuda
    exit
fi

# Obtiene la IP
ip=$(echo $redIP | awk -F '/' {'print $1'})
# Obtiene la máscara
mascara=$(echo $redIP | awk -F '/' {'print $2'})

# Obtiene la IP por partes
ip1=$(echo $ip | awk -F '.' '{print $1}')
ip2=$(echo $ip | awk -F '.' '{print $2}')
ip3=$(echo $ip | awk -F '.' '{print $3}')
ip4=$(echo $ip | awk -F '.' '{print $4}')

# Obtiene el puerto inicial del rango
puertoInicial=$(echo $puertos | awk -F '-' '{print $1}')
# Obtiene el puerto final del rango
puertoFin=$(echo $puertos | awk -F '-' '{print $2}')

# Si el archivo introducido no existe lo creará
if [[ -f $archivo ]]
then
    echo -e "${YELLOW}[!] El archivo ya existe${WHITE}"
else
    echo -e "${YELLOW}[!] Creando archivo $archivo..."
    # Crea archivo y añade las columnas para el CSV
    echo '"IP","MAC","SO","TTL","PUERTO","SERVICIO"' > $archivo
fi

# Comprueba si existe el comando `arp`
arpCheck=$(arp 2</dev/null)
arpCod=$(echo $?)
# Si su status al ejecutar es 127 es que no está instalado
if [[ $arpCod -eq 127 ]]
then
    # Preguntará si quieres instalar el paquete net-tools
    echo -e "${YELLOW}[!] Tienes que instalar NET-TOOLS!${WHITE}"
    read -p "[?] ¿Quieres instalarlo? (y/n)" arpInstall
    case $arpInstall in
        y|Y)
            # Comienza con la actualización de repositorios e instalación
            sudo apt update -y
            sudo apt install net-tools -y;;
        *)
            # Si no se instala cierra el programa
            echo -e "${RED}No instalarás net-tools, saliendo..."
            exit;;
    esac

fi

# Verifica la máscara introducida, deberá ser 8, 16 o 24
case $mascara in
    8)
        echo -e "${WHITE}[*] Máscara de subred: ${BLUE}255.0.0.0"
        mascara8;;
    16)
        echo -e "${WHITE}[*] Máscara de subred: ${BLUE}255.255.0.0"
        mascara16;;
    24)
        echo -e "${WHITE}[*] Máscara de subred: ${BLUE}255.255.255.0"
        mascara24;;
    *)
        # Si no se introduce ninguna de las anteriores cierra el programa
        echo -e "${RED}[*] Máscara de subred incorrecta. (/8 , /16 , /24)"
        echo -e "Saliendo..."
        exit;;
esac

# Muestra el tiempo que se tardó en ejecutar el script
echo ""
echo "${YELLOW}[!] El script tardó $SECONDS segundos en ejecutarse."