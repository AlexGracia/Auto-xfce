#!/bin/sh
# Descripcion: Script que limpiar el pc
# Autor: Alex Gracia
# Version: 0.1.1
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Funcion para mostrar un mensaje de error en rojo.
f_error () {
    echo
    echo "\e[91;1m[ ERROR ] $1 \e[0m"
    exit 1
}

# Funcion para limpiar el pc.
_limpiar_pc () {
    export DISPLAY=:0.0
    # Obtener nombre de usuario.
    usuario=$(getent group users | cut -d: -f4 -s | sed -n 1p)
    if [ "$usuario" = "" ]; then
        usuario=$(getent passwd | grep home | cut -d: -f1 -s | sed -n 1p)
        if [ "$usuario" = "" ]; then
            usuario=$(cat /etc/passwd | grep home | cut -d: -f1 -s | sed -n 1p)
            if [ "$usuario" = "" ]; then
                f_error "Usuario no encontrado."
            fi
        fi
    fi
    export XAUTHORITY="/home/$usuario/.Xauthority"

    # Avisar al usuario,
    # para que no apague el pc.
    xmessage -timeout 10 -center -title "Limpieza mensual" -buttons Aceptar:0,Cancelar:1 "¿Limpiar PC ahora?" -fn 12x24

    if [ $? != 0 ]; then
        return
    fi

    # Limpiar pc.
    apt clean -y
    apt autoclean -y
    apt autoremove -y
    apt autopurge -y
    apt purge -y $(apt-mark showremove)
    journalctl --vacuum-size=100M
    sync

    # Avisar al usuario,
    # para que apague el pc, si quiere.
    xmessage -timeout 5 -center -title "Limpieza mensual" -buttons "" "PC limpio." -fn 12x24
}

# Funcion para iniciar el script.
_iniciar () {
    # Bienvenida.
    clear
    echo "
╔════════════╗
║ Limpiar pc ║
╚════════════╝"

    _limpiar_pc
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Despedida.
    echo "
╔════════════╗
║    Fin     ║
╚════════════╝"
}

_finalizar

exit
