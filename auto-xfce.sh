#!/bin/sh
# Descripcion: Script que instala XFCE mínimo, paquetes, configuraciones y personalizaciones.
# Autor: Alex Gracia
# Version: 0.9.0
# Requisitos: paqueteria APT, conexion de red, usuario root y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Variables globales
personalizacion=$1
paquetes_frecuentes="evince galculator gnome-boxes mousepad network-manager network-manager-gnome photoflare p7zip-full redshift redshift-gtk gthumb sakura sudo thunar-archive-plugin ufw vlc xfce4 xfce4-power-manager xfce4-whiskermenu-plugin zram-tools"
paquetes_infrecuentes="chromium evince firejail gimp gnome-boxes gnumeric gpicview network-manager network-manager-gnome p7zip-full pandoc qpdf redshift redshift-gtk sakura sd sudo ufw vlc xfce4 xfce4-power-manager zram-tools"

# Funcion para mostrar un titulo descriptivo del paso actual.
f_titulo () {
    echo
    echo "  $1 ($2 de 10)"
    echo "════════════════════════════════════════"
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
#════════════════════════════════════════

# Funcion para las comprobaciones iniciales.
f_comprobaciones_iniciales () {
    f_titulo "Comprobaciones iniciales  " 1

    # Comprobar la paqueteria.
    echo "Comprobando la paqueteria ..."
    apt -h > /dev/null
    if [ $? != 0 ]; then
        f_error "Debes tener la paqueteria apt."
    fi

    # Comprobar la red.
    echo "Comprobando la conexion de red ..."
    ping 1.1.1.1 -c 1 -s 1 -q > /dev/null 2> /dev/null
    if [ $? != 0 ]; then
        f_error "Debes tener conexion de red."
    fi

    # Comprobar el usuario.
    echo "Comprobando el usuario ..."
    if [ "$(whoami)" != "root" ]; then
        f_error "Debes ser usuario root."
    fi

    # Comprobar el paquete wget.
    echo "Comprobando el paquete wget ..."
    wget -h > /dev/null
    # Intentar instalar si falta.
    if [ $? != 0 ]; then
        apt install -y wget
        if [ $? != 0 ]; then
            f_error "Problemas con la instalacion de wget."
        fi
    fi

    f_ok
}

#
#   2. Elegir personalizacion
#════════════════════════════════════════

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
    f_titulo "Eligiendo personalizacion " 2

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
#════════════════════════════════════════

# Funcion para actualizar paquetes.
f_actualizar_paquetes () {
    f_titulo "Actualizando paquetes     " 3

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
#════════════════════════════════════════

# Funcion para instalar OnlyOffice, desde su repositorio oficial.
# URL: https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx
f_onlyoffice () {
    # Añadir repositorio.
    mkdir -p -m 700 ~/.gnupg
    gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
    chmod 644 /tmp/onlyoffice.gpg
    chown root:root /tmp/onlyoffice.gpg
    mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
    echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | tee -a /etc/apt/sources.list.d/onlyoffice.list

    # Actualizar lista de paquetes.
    apt update

    # Instalar OnlyOffice.
    apt install -y onlyoffice-desktopeditors

    if [ $? != 0 ]; then
        f_error "Problemas con la instalacion de OnlyOffice."
    fi
}

# Funcion para instalar Firefox, desde su repositorio oficial.
# URL: https://support.mozilla.org/en-US/kb/install-firefox-linux
f_firefox () {
    # Añadir repositorio.
    install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla

    # Actualizar lista de paquetes.
    apt update

    # Instalar Firefox.
    apt install -y firefox firefox-l10n-es-es

    if [ $? != 0 ]; then
        f_error "Problemas con la instalacion de Firefox."
    fi
}

# Funcion para instalar paquetes.
f_instalar_paquetes () {
    f_titulo "Instalando paquetes       " 4

    # Instalar paquetes.
    if [ $personalizacion = "f" ]; then
        apt install -y $paquetes_frecuentes

        if [ $? != 0 ]; then
            f_error
        fi

        # Instalar OnlyOffice.
        f_onlyoffice
    else
        apt install -y $paquetes_infrecuentes

        if [ $? != 0 ]; then
            f_error
        fi
    fi

    # Instalar Firefox.
    f_firefox

    f_ok
}

#
#   5. Configurar seguridad
#════════════════════════════════════════

# Funcion para configurar la seguridad.
f_configurar_seguridad () {
    f_titulo "Configurando seguridad    " 5

    # Configurar sudo.
    cd /etc/sudoers.d/
    echo "# Pedir contraseña root, por cada comando sudo" > reglas-personalizadas
    echo "Defaults timestamp_timeout=0" >> reglas-personalizadas

    if [ $? != 0 ]; then
        f_error
    fi

    # Configurar ufw.
    ufw default deny incoming
    ufw default deny outgoing
    ufw allow out 'WWW Full'
    ufw allow out DNS
    ufw enable

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   6. Configurar servicios
#════════════════════════════════════════

# Funcion para configurar los servicios.
f_configurar_servicios () {
    f_titulo "Configurando servicios    " 6

    if [ $personalizacion = "f" ]; then
        return
    fi

    # Deshabilitar servicio de bluetooth.
    systemctl disable bluetooth

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   7. Configurar red
#════════════════════════════════════════

# Funcion para configurar la red.
f_configurar_red () {
    f_titulo "Configurando red          " 7

    # Comentar las interfaces de red, para gestionarlas manualmente.
    sed -i '/^$/b; /^#/b; s/^/#/' /etc/network/interfaces

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   8. Configurar swap
#════════════════════════════════════════

# Funcion para configurar el swap.
f_configurar_swap () {
    f_titulo "Configurando swap         " 8

    # Configurar 25% de RAM.
    sed -i 's/^#PERCENT=.*$/PERCENT=25/' /etc/default/zramswap

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   9. Configurar autoinicio
#════════════════════════════════════════

# Funcion para configurar el autoinicio.
f_configurar_autoinicio () {
    f_titulo "Configurando autoinicio   " 9

    # Obtener nombre de usuario.
    usuario=$(getent group users | cut -d: -f4 -s | sed -n 1p)

    # Configurar LightDM.

    # Usuario que iniciará sesión.
    sed -i "s/^#autologin-user=.*$/autologin-user=$usuario/" /etc/lightdm/lightdm.conf

    if [ $? != 0 ]; then
        f_error
    fi

    # Quitar tiempo de espera.
    sed -i 's/^#autologin-user-timeout=.*$/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   10. Personalizar XFCE
#════════════════════════════════════════

# Funcion para personalizar XFCE.
f_personalizar_xfce () {
    f_titulo "Personalizando XFCE      " 10

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
 █████╗ ██╗   ██╗████████╗ ██████╗      ██╗  ██╗███████╗ ██████╗███████╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ╚██╗██╔╝██╔════╝██╔════╝██╔════╝
███████║██║   ██║   ██║   ██║   ██║█████╗╚███╔╝ █████╗  ██║     █████╗
██╔══██║██║   ██║   ██║   ██║   ██║╚════╝██╔██╗ ██╔══╝  ██║     ██╔══╝
██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ██╔╝ ██╗██║     ╚██████╗███████╗
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚═╝  ╚═╝╚═╝      ╚═════╝╚══════╝"

    # Ejecucion de funciones.
#    f_comprobaciones_iniciales

    f_elegir_personalizacion

#    f_actualizar_paquetes

#    f_instalar_paquetes

#    f_configurar_seguridad

#    f_configurar_servicios

#    f_configurar_red

#    f_configurar_swap

    f_configurar_autoinicio

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
