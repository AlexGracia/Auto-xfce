#!/bin/sh
# Descripcion: Script que actualiza el pc
# Autor: Alex Gracia
# Version: 0.1.0
# Requisitos: conexion de red
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Funcion para actualizar el pc.
_actualizar_pc () {
    export DISPLAY=:0.0
    usuario=$(getent group users | cut -d: -f4 -s | sed -n 1p)
    export XAUTHORITY="/home/$usuario/.Xauthority"


    # Avisar al usuario,
    # para que no apague el pc.
    xmessage -timeout 10 -center -title "Actualización semanal" -buttons Aceptar:0,Cancelar:1 "¿Actualizar PC ahora?" -fn 12x24

    if [ $? != 0 ]; then
        return
    fi

    # Actualizar pc.
    apt update
    apt upgrade -y
    sync

    # Avisar al usuario,
    # para que apague el pc, si quiere.
    xmessage -timeout 5 -center -title "Actualización semanal" -buttons "" "PC actualizado." -fn 12x24
}

# Funcion para iniciar el script.
_iniciar () {
    # Bienvenida.
    clear
    echo "
╔═══════════════╗
║ Actualizar pc ║
╚═══════════════╝"

    _actualizar_pc
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Despedida.
    echo "
╔═══════════════╗
║      Fin      ║
╚═══════════════╝"
}

_finalizar

exit
