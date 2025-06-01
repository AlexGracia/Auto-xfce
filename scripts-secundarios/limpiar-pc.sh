#!/bin/sh
# Descripcion: Script que limpiar el pc
# Autor: Alex Gracia
# Version: 0.1.0
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Funcion para limpiar el pc.
_limpiar_pc () {
    # Avisar al usuario,
    # para que no apague el pc.
    notify-send -t 10000 -i "/usr/share/icons/HighContrast/scalable/status/dialog-warning.svg" "Limpiando ..." "No apague el PC."

    # Limpiar pc.
    apt clean -y
    apt autoclean -y
    apt autoremove -y
    apt autopurge -y

    # Avisar al usuario,
    # para que apague el pc, si quiere.
    notify-send -t 10000 -i "/usr/share/icons/HighContrast/scalable/actions/dialog-ok.svg" "Limpiado" "PC limpiado correctamente."
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
