#!/bin/bash
#clear


#Variables GLOBALES
#Argumentos que se requieren
ARGUM_REQUER=1

#Errores del script
E_NOREAD_NOEXIS_ARG=64                          #Error 64 se da al no tener argumentos validos/o
                                                #no exista el fichero
ID_INVAL=66                                     #Error 66 se da si el identificador de la
                                                #practica no esvalido
FECH_INVAL=65                                   #Error 65 se da si la fecha es invalida o esta
                                                #fuera de plazo
NO_DIR=73                                       #Error 73 si el directorio de entrega no existe
                                                #o no se pueda crear.



#Flujo del programa despues de las funciones



function tienelaVar(){
    if ! test $MINIENTREGA_CONF; then
        exit $E_NOREAD_NOEXIS_ARG
    fi
}

function esUnDirectorio(){
    if ! test -d ${MINIENTREGA_CONF}; then
        exit $E_NOREAD_NOEXIS_ARG
    fi  
}

function esDirectorioLegible(){
    if ! test -r ${MINIENTREGA_CONF}; then
        exit $E_NOREAD_NOEXIS_ARG
    fi
}

function noEsDirectorioVacio(){
    if test `ls -F ${MINIENTREGA_CONF} | grep -v /| wc -l` -eq 0 ; then
        exit $E_NOREAD_NOEXIS_ARG
    fi
}






function comprobarFormatoFecha(){
    regex='[0-9]{4}-[0-1][0-9]-[0-3][0-9]'
    if ! [[ $MINIENTREGA_FECHALIMITE =~ $regex ]]; then
        exit $FECH_INVAL
    fi
}




function existeArchivoDelParametro(){
    for archivo in `ls ${MINIENTREGA_CONF}/*`; do
        if test $archivo == ${MINIENTREGA_CONF}/$1; then
            return
        fi
    done
    exit $ID_INVAL
}




#Funcion para verificar que la fecha de entrega esta en el plazo
function estaEnFecha(){
    #Creamos estas variables para poder trabajar mejor con la fecha
    anio=`date +%Y` #Año actual
    mes=`date +%m` #Mes actual
    dia=`date +%d` #Dia actual
    anioLimite=${MINIENTREGA_FECHALIMITE:0:4} #Año limite de entrega
    mesLimite=${MINIENTREGA_FECHALIMITE:5:2}  #Mes limite de entrega
    diaLimite=${MINIENTREGA_FECHALIMITE:8:2}  #Dia limite de entrega


    if [ $anio -gt $anioLimite ];then  #Comprobamos si el año es mayor que el limite
        exit $FECH_INVAL
    elif [ $anio -eq $anioLimite ]; then  #Si los años son iguales se sigue, si es menor, esta en el plazo
        if [ $mes -gt $mesLimite ]; then  #Comprobamos si el mes es mayor que el limte
            exit $FECH_INVAL
        elif [ $mes -eq $mesLimite ]; then  #Si los meses son iguales se sigue, si es menor, esta en el plazo
            if [ $dia -gt $diaLimite ]; then  #Comprobamos si el dia es mayor que el limite, hemos considerado que el dia limite esta permitido
                exit $FECH_INVAL
            fi
        fi
    fi
}



#Funcion para comprobar que existen los ficheros y son legibles
function existenYLegiblesFicheros(){
    for fichero in ${MINIENTREGA_FICHEROS}; do
        if test -e ${PWD}/$fichero; then
            if ! test -r ${PWD}/$fichero; then
                exit $ID_INVAL
            fi
        else exit $ID_INVAL
        fi
    done
}


function comprobarDestino(){
    if test -d ${MINIENTREGA_DESTINO}; then
        if ! test -w ${MINIENTREGA_DESTINO}; then
            exit $NO_DIR
        fi
    else exit $NO_DIR
    fi
}

function crearCarpetaUsuarioSiNoExiste(){
    if ! test -d ${MINIENTREGA_DESTINO}/${USER} && ! test -r ${MINIENTREGA_DESTINO}/${USER}/; then
        mkdir -p ${MINIENTREGA_DESTINO}/${USER}
    fi
}



#----------------------------


#Flujo del programa

#Comprobamos que los argumentos son validos
if [ $# -ne $ARGUM_REQUER ]; then
    echo "minientrega.sh: Error(${E_NOREAD_NOEXIS_ARG}), uso incorrecto del mandao. \"Succes\""
    echo "minientrega.sh+ Uso: $0 {nombre_archivo} o -h/--help para la ayuda"
    exit $E_NOREAD_NOEXIS_ARG
else
    if [ $1 == "-h" ] || [ $1 == "--help" ]; then
        echo "minientrega.sh: .*Uso: $0 {nombre_archivo} o -h/--help para la ayuda"
        echo "minientrega.sh: Copia archivos los ficheros apropiados de un directorio del usuario a otro que es el de entrega"
        exit 0
    fi
fi


#---------------------------


#Comprobamos que la variable exista
tienelaVar

#Comprobamos que la variable dirige a un directorio
esUnDirectorio

#Comprobamos que el directorio es legible
esDirectorioLegible

#Comprobamos que el directorio no está vacio
noEsDirectorioVacio


#Comprobamos que el parametro con le que se ejecuto el parametro, es un archivo de configuracion
existeArchivoDelParametro $1

#-----------------------------

#Si lo es, se carga la configuracion
source ${MINIENTREGA_CONF}/$1

#----------------------------

#Se comprueba el formato de la fecha de la configuracion antes de hacer nada mas
comprobarFormatoFecha

#Comprobamos que la entrega este en fecha
estaEnFecha

#-----------------------------

#Comprobamos que los ficheros existen
existenYLegiblesFicheros
#Comprobamos que la carpeta destino existe y es legible
comprobarDestino
#Comprobamos que la carpeta de usuario y si no existe se crea
crearCarpetaUsuarioSiNoExiste

#Como la carpeta existe, es legible, y existen los ficheros y son legibles, se copian
cp ${MINIENTREGA_FICHEROS} ${MINIENTREGA_DESTINO}/${USER}/.
