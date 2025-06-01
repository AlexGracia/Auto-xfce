#!/bin/sh
# Descripcion: Script que actualiza el pc
# Autor: Alex Gracia
# Version: 0.1.0
# Requisitos: conexion de red
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Funcion para actualizar el pc.
_actualizar_pc () {
    # Avisar al usuario,
    # para que no apague el pc.
    notify-send -t 10000 -i "/usr/share/icons/HighContrast/scalable/status/dialog-warning.svg" "Actualizando ..." "No apague el PC."

    # Actualizar pc.
    apt update
    apt upgrade -y

    # Avisar al usuario,
    # para que apague el pc, si quiere.
    notify-send -t 10000 -i "/usr/share/icons/HighContrast/scalable/actions/dialog-ok.svg" "Actualizado" "PC actualizado correctamente."
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
