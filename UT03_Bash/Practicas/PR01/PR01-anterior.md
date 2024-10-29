# Bash Scripting  | T3 - PR01

## 1. Crea un script que muestre por pantalla la fecha y la hora del sistema

```bash 
date "+%D %H:%M"
```

## 2. “Hoy es jueves día 15 de abril y son las 12:00 horas”.

```bash
diaSemana=$(date +"%A")
dia=$(date +%d)
mes=$(date +%B)
hora=$(date +%H)
minuto=$(date +%M)

echo "Hoy es $diaSemana día $dia de $mes y son las $hora:$minuto horas."
```

## 3. Crea un script que solicite la usuario dos números y luego imprima la suma de esos números

```bash
read -p "Numero 1: " num1
read -p "Número 2: " num2
let suma=$num1+$num2
echo $suma
```

## 4. Crea un script que determine si un número introducido por el usuario es par o impar. Para realizar este ejercicio puedes utilizar el operador módulo, que es el símbolo %

```bash
read -p "Número: " num

let par=$num%2

if [ $par -eq 0 ];
then
 echo "PAR";
else
 echo "IMPAR"
fi
```

## 5. Escribe un script que solicite el nombre de un archivo y luego imprima cuántas líneas tiene ese archivo. Verifica que el archivo exista antes de contar las líneas.

```bash
read -p "File: " archivo
wc -l $archivo
```

## 6. Escribe un script que imprima la tabla de multiplicar de un número introducido por el usuario.

```bash
read -p "Número: " num

for (( i=0; i<=10; i++ ))
do
  let multi=$num*$i
  echo $num "*" $i "=" $multi
done
```

## 7. Crea un script que solicite el nombre de un archivo y luego informe si el archivo tiene permisos de lectura, escritura y ejecución para el usuario actual.

```

```