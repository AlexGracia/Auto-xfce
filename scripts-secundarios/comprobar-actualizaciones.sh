#!/usr/bin/env sh
# Descripcion: Script que comprueba la disponibilidad de actualizaciones.
# Autor: Alex Gracia
# Version: 0.1.0
#════════════════════════════════════════

# Funcion para avisar de que hay actualizaciones disponibles.
_actualizacion_disponible () {
    export DISPLAY=:0.0
    # Obtener nombre de usuario.
    usuario=$(getent group users | cut -d: -f4 -s | sed -n 1p)
    if [ "$usuario" = "" ]; then
        usuario=$(getent passwd | grep home | cut -d: -f1 -s | sed -n 1p)
        if [ "$usuario" = "" ]; then
            usuario=$(cat /etc/passwd | grep home | cut -d: -f1 -s | sed -n 1p)
            if [ "$usuario" = "" ]; then
                echo
                echo "\e[91;1m[ ERROR ] Usuario no encontrado. \e[0m"
                exit 1
            fi
        fi
    fi
    export XAUTHORITY="/home/$usuario/.Xauthority"
    # Mostrar aviso.
    xmessage -center -title "Actualización disponible" -buttons "" "Actualice el PC." -fn 12x24
}

# Comprobar actualizaciones.
apt update | grep upgradable

# Avisar.
if [ $? = 0 ]; then
    _actualizacion_disponible
fi

exit
