#!/bin/sh
# Descripcion: Script que instala paquetes y personaliza [XFCE](https://www.xfce.org/)
# Autor: Alex Gracia
# Version: 0.1.1
# Requisitos: paqueteria APT, conexion de red, usuario root y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#══════════════════════════════════════

# Variables globales
personalizacion=$1
paquetes_frecuentes="evince galculator gnome-boxes mousepad network-manager photoflare p7zip-full p7zip-rar redshift redshift-gtk gthumb sakura thunar-archive-plugin ufw vlc xfce4 xfce4-whiskermenu-plugin zram-tools"
paquetes_infrecuentes="chromium evince firejail gimp gnome-boxes gnumeric gpicview network-manager p7zip-full p7zip-rar pandoc qpdf redshift redshift-gtk sakura sd ufw vlc xfce4 zram-tools"
# OnlyOffice: https://youtu.be/UQanxlQh_bY
# https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx
# Firefox: https://support.mozilla.org/en-US/kb/install-firefox-linux
# Auto-cpufreq: https://github.com/AdnanHodzic/auto-cpufreq

# Funcion para mostrar un titulo descriptivo del paso actual.
f_titulo () {
    echo
    echo "  $1 ($2 de 5)"
    echo "══════════════════════════════════════"
}

# Funcion para mostrar un mensaje de error en rojo.
f_error () {
    echo
    echo "\e[91;1m[ ERROR ] $1 \e[0m"
    exit 1
}

# Funcion para mostrar un mensaje de ok en verde.
f_ok () {
    echo
    echo "\e[92;1m[ OK ]\e[0m"
    sync
}

#
#   1. Comprobaciones iniciales
#═════════════════════════════════════

# Funcion para las comprobaciones iniciales.
f_comprobaciones_iniciales () {
    f_titulo "Comprobaciones iniciales " 1

    # Comprobar la paqueteria.
    echo "Comprobando la paqueteria ..."
    apt -h > /dev/null
    if [ $? != 0 ]; then
        f_error "Debes tener la paqueteria apt."
    fi

    # Comprobar la red.
    echo "Comprobando la conexion de red ..."
    ping github.com -c 1 -s 1 -q > /dev/null 2> /dev/null
    if [ $? != 0 ]; then
        f_error "Debes tener conexion de red."
    fi

    # Comprobar el usuario.
    echo "Comprobando el usuario ..."
    if [ "$(whoami)" != "root" ]; then
        f_error "Debes ser usuario root."
    fi

    f_ok
}

#
#   2. Elegir personalizacion
#═════════════════════════════════════

# Funcion para validar la personalizacion elegida.
f_validar_personalizacion () {
    # Convertir mayusculas en minusculas.
    personalizacion=$(echo "$personalizacion" | tr '[:upper:]' '[:lower:]')

    # Advertir si la personalizacion es invalida y volver a preguntar.
    if [ $personalizacion != "f" ] && [ $personalizacion != "i" ]; then
        echo
        echo "\e[93;1m[ ! ] Debes escoger una personalizacion valida (f/i).\e[0m"
        personalizacion=""
        f_elegir_personalizacion
        return
    fi

    echo "Personalizacion $personalizacion elegida."

    f_ok
}

# Funcion para elegir personalizacion,
# si no se eligio previamente en la ejecucion del script.
f_elegir_personalizacion () {
    f_titulo "Eligiendo personalizacion" 2

    # No elegir manualmente personalizacion,
    # si ya se ha elegido en la ejecucion del script.
    if [ $personalizacion ]; then
        f_validar_personalizacion
        return
    fi

    # Elegir personalizacion.
    echo "- Personalizacion [f]recuente."
    echo "- Personalizacion [i]nfrecuente."
    echo
    read -p "¿Que deseas elegir [F/i]?: " personalizacion

    # La personalizacion por defecto sera f,
    # si no se elige ninguna manualmente.
    if [ ! $personalizacion ]; then
        personalizacion="f"
        echo "Personalizacion $personalizacion elegida."
        f_ok
        return
    fi

    f_validar_personalizacion
}

#
#   3. Actualizar paquetes
#═════════════════════════════════════

# Funcion para actualizar paquetes.
f_actualizar_paquetes () {
    f_titulo "Actualizando paquetes    " 3

    # Actualizar paquetes.
    apt update
    apt upgrade -y

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   4. Instalar paquetes
#═════════════════════════════════════

# Funcion para instalar OnlyOffice, desde su repositorio oficial.
f_onlyoffice () {
# onlyoffice-desktopeditors
    if [ $? != 0 ]; then
        f_error "Problemas con la instalacion de OnlyOffice."
    fi
}

# Funcion para instalar Firefox, desde su repositorio oficial.
f_firefox () {
# firefox firefox-l10n-es-es
    if [ $? != 0 ]; then
        f_error "Problemas con la instalacion de Firefox."
    fi
}

# Funcion para instalar paquetes.
f_instalar_paquetes () {
    f_titulo "Instalando paquetes      " 4

    # Instalar paquetes.
    if [ $personalizacion = "f" ]; then
        echo $paquetes_frecuentes
#        apt install $paquetes_frecuentes
        # Instalar OnlyOffice.
        f_onlyoffice
    else
        echo $paquetes_infrecuentes
#        apt install $paquetes_infrecuentes
    fi

    if [ $? != 0 ]; then
        f_error
    fi

    # Instalar Firefox.
    f_firefox

    f_ok
}

#
#   5. Personalizar XFCE
#═════════════════════════════════════

# Funcion para personalizar XFCE.
f_personalizar_xfce () {
    f_titulo "Personalizando XFCE      " 5

#    Para cambiar el tema de XFCE, puedes utilizar el comando xfconf-query:

#    xfconf-query -c xsettings -p /Net/ThemeName -s nombre_del_tema

#    Para cambiar el fondo de pantalla, puedes utilizar el comando xfconf-query:

#    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s /ruta/al/fondo/de/pantalla

#    Para cambiar la configuración de la barra de tareas, puedes utilizar el comando xfconf-query:

#    xfconf-query -c xfce4-panel -p /panels/panel-1/config -s configuración_de_la_barra

#    Para cambiar la configuración del escritorio, puedes utilizar el comando xfconf-query:

#    xfconf-query -c xfce4-desktop -p /desktop/config -s configuración_del_escritorio

# Recargar escritorio.
#xfdesktop --reload

    f_ok
}

# Funcion para iniciar el script.
f_iniciar () {
    # Bienvenida.
    # URL: https://github.com/CorentinTh/it-tools
    # Fuente: ANSI Shadow.
    clear
    echo "
 █████╗ ██╗   ██╗████████╗ ██████╗ ██╗  ██╗███████╗ ██████╗███████╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗╚██╗██╔╝██╔════╝██╔════╝██╔════╝
███████║██║   ██║   ██║   ██║   ██║ ╚███╔╝ █████╗  ██║     █████╗
██╔══██║██║   ██║   ██║   ██║   ██║ ██╔██╗ ██╔══╝  ██║     ██╔══╝
██║  ██║╚██████╔╝   ██║   ╚██████╔╝██╔╝ ██╗██║     ╚██████╗███████╗
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝      ╚═════╝╚══════╝"

    # Ejecucion de funciones.
#    f_comprobaciones_iniciales

    f_elegir_personalizacion

#    f_actualizar_paquetes

    f_instalar_paquetes

    f_personalizar_xfce
}

f_iniciar

# Funcion para finalizar el script.
f_finalizar () {
    # Despedida.
    echo "
███████╗██╗███╗   ██╗
██╔════╝██║████╗  ██║
█████╗  ██║██╔██╗ ██║
██╔══╝  ██║██║╚██╗██║
██║     ██║██║ ╚████║
╚═╝     ╚═╝╚═╝  ╚═══╝"
}

f_finalizar
exit
