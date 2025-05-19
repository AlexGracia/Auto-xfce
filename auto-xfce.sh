#!/bin/sh
# Descripcion: Script que instala XFCE mínimo, paquetes, configuraciones y personalizaciones.
# Autor: Alex Gracia
# Version: 0.15.1
# Requisitos: paqueteria APT, conexion de red, usuario root y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Variables globales
desatendido=$1
personalizacion=$1
paquetes_frecuentes="anacron evince galculator gnome-boxes mousepad network-manager network-manager-gnome photoflare p7zip-full redshift redshift-gtk gthumb sakura sudo thunar-archive-plugin ufw vlc xfce4 xfce4-power-manager xfce4-whiskermenu-plugin zram-tools"
paquetes_infrecuentes="anacron chromium evince firejail gimp gnome-boxes gnumeric gpicview network-manager network-manager-gnome p7zip-full pandoc qpdf redshift redshift-gtk sakura sd sudo ufw vlc xfce4 xfce4-power-manager zram-tools"
usuario=""

# Funcion para mostrar un titulo descriptivo del paso actual.
f_titulo () {
    echo
    echo "  $1 ($2 de 14)"
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
    apt -h >/dev/null
    if [ $? != 0 ]; then
        f_error "Debes tener la paqueteria apt."
    fi

    # Comprobar la red.
    echo "Comprobando la conexion de red ..."
    ping 1.1.1.1 -c 1 -s 1 -q >/dev/null 2>&1
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
    wget -h >/dev/null
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
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null
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
    archivo="/etc/sudoers.d/reglas-personalizadas"
    echo "# Pedir contraseña root, por cada comando sudo" > $archivo
    echo "Defaults timestamp_timeout=0" >> $archivo

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
#   10. Configurar tareas
#════════════════════════════════════════

# Funcion para configurar las tareas.
f_configurar_tareas () {
    f_titulo "Configurando tareas      " 10

    if [ $personalizacion = "i" ]; then
        return
    fi

    # Variables
    archivo="/etc/anacrontab"

    # 1. Configurar actualizaciones semanalmente.

    # Controlar duplicidades.
    cat $archivo | grep -q "actualizaciones"

    if [ $? = 0 ]; then
        return
    fi

    # Añadir tarea.
    echo -e "7\t5\tactualizaciones\tapt update && apt upgrade -y >/dev/null 2>&1" >> $archivo

    if [ $? != 0 ]; then
        f_error
    fi

    # 2. Configurar limpieza mensualmente.

    # Controlar duplicidades.
    cat $archivo | grep -q "limpieza"

    if [ $? = 0 ]; then
        return
    fi

    # Añadir tarea.
    echo -e "@monthly\t5\tlimpieza\tapt clean -y && apt autoclean -y && apt autoremove -y && apt autopurge -y >/dev/null 2>&1" >> $archivo

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   11. Configurar bashrc
#════════════════════════════════════════

# Funcion para configurar el bashrc.
f_configurar_bashrc () {
    f_titulo "Configurando bashrc      " 11

    if [ $personalizacion = "f" ]; then
        return
    fi

    # 1. Usuario root.
    echo "export PS1='\n\[\033[38;5;196m\]\[$(tput sgr0)\] ( \[\033[38;5;45m\]\w\[$(tput sgr0)\] ) \[\033[38;5;246m\]\$?\[$(tput sgr0)\]: '" >> ~/.bashrc

    if [ $? != 0 ]; then
        f_error
    fi

    # 2. Usuario no root.
    echo "export PS1='\n\[\033[38;5;42m\]\[$(tput sgr0)\] ( \[\033[38;5;45m\]\w\[$(tput sgr0)\] ): '" >> "/home/$usuario/.bashrc"

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   12. Configurar aliases
#════════════════════════════════════════

# Funcion para configurar los aliases.
f_configurar_aliases () {
    f_titulo "Configurando aliases     " 12

    if [ $personalizacion = "f" ]; then
        return
    fi

    # 1. Usuario root.
    echo "alias actualizate='apt update && apt list --upgradable && apt upgrade'" >> ~/.bash_aliases
    echo "alias exit='echo > ~/.bash_history && sync && exit'" >> ~/.bash_aliases
    echo "alias limpiate='apt clean && apt autoclean && apt autoremove && apt autopurge'" >> ~/.bash_aliases
    echo "alias ls='ls -shop --color=auto'" >> ~/.bash_aliases
    echo "alias reboot='sync && reboot'" >> ~/.bash_aliases

    if [ $? != 0 ]; then
        f_error
    fi

    # 2. Usuario no root.
    echo "alias calculadora='bc'" >> "/home/$usuario/.bash_aliases"
    echo "alias curl='firejail curl'" >> "/home/$usuario/.bash_aliases"
    echo "alias cvlc='firejail cvlc'" >> "/home/$usuario/.bash_aliases"
    echo "alias exit='echo > ~/.bash_history && sync && exit'" >> "/home/$usuario/.bash_aliases"
    echo "alias imgver='gpicview'" >> "/home/$usuario/.bash_aliases"
    echo "alias ls='ls -shop --color=auto'" >> "/home/$usuario/.bash_aliases"
    echo "alias pdfver='evince'" >> "/home/$usuario/.bash_aliases"
    echo "alias su='su -'" >> "/home/$usuario/.bash_aliases"
    echo "alias wget='firejail wget'" >> "/home/$usuario/.bash_aliases"

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   13. Configurar nanorc
#════════════════════════════════════════

# Funcion para configurar el nanorc.
f_configurar_nanorc () {
    f_titulo "Configurando nanorc      " 13

    if [ $personalizacion = "f" ]; then
        return
    fi

    # Usuario no root.
    echo "set autoindent" >> "/home/$usuario/.nanorc"
    echo "set tabsize 4" >> "/home/$usuario/.nanorc"
    echo "set tabstospaces" >> "/home/$usuario/.nanorc"
    # Borrar parte seleccionada.
    echo "set zap" >> "/home/$usuario/.nanorc"
    # La línea que excede el ancho de la pantalla, se muestra en múltiples líneas.
    echo "set softwrap" >> "/home/$usuario/.nanorc"
    # Informacion (nombre archivo, nº de lineas, nº de caracteres, ...).
    echo "set constantshow" >> "/home/$usuario/.nanorc"
    echo "set minibar" >> "/home/$usuario/.nanorc"

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

#
#   14. Configurar hidden
#════════════════════════════════════════

# Funcion para configurar el hidden.
f_configurar_hidden () {
    f_titulo "Configurando hidden      " 14

    if [ $personalizacion = "f" ]; then
        return
    fi

    # Usuario no root.
    # Este archivo oculta las carpetas y archivos escritos aqui
    echo "Escritorio" >> "/home/$usuario/.hidden"
    echo "Imágenes" >> "/home/$usuario/.hidden"
    echo "Música" >> "/home/$usuario/.hidden"
    echo "Plantillas" >> "/home/$usuario/.hidden"
    echo "Público" >> "/home/$usuario/.hidden"
    echo "Vídeos" >> "/home/$usuario/.hidden"

    if [ $? != 0 ]; then
        f_error
    fi

    f_ok
}

# Funcion para iniciar el script.
f_iniciar () {
    # Bienvenida.
    clear
    echo "
 █████╗ ██╗   ██╗████████╗ ██████╗      ██╗  ██╗███████╗ ██████╗███████╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ╚██╗██╔╝██╔════╝██╔════╝██╔════╝
███████║██║   ██║   ██║   ██║   ██║█████╗╚███╔╝ █████╗  ██║     █████╗
██╔══██║██║   ██║   ██║   ██║   ██║╚════╝██╔██╗ ██╔══╝  ██║     ██╔══╝
██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ██╔╝ ██╗██║     ╚██████╗███████╗
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚═╝  ╚═╝╚═╝      ╚═════╝╚══════╝"

    # Ejecucion de funciones.
    f_comprobaciones_iniciales

    f_elegir_personalizacion

    f_actualizar_paquetes

    f_instalar_paquetes

    f_configurar_seguridad

    f_configurar_servicios

    f_configurar_red

    f_configurar_swap

    f_configurar_autoinicio

    f_configurar_tareas

    f_configurar_bashrc

    f_configurar_aliases

    f_configurar_nanorc

    f_configurar_hidden

}

f_iniciar

# Funcion para finalizar el script.
f_finalizar () {
    # Limpiar y ordenar.
    # Paquetes.
    apt clean -y
    apt autoclean -y
    apt autoremove -y
    apt autopurge -y
    sync

    # Preguntar reinicio,
    # si en la ejecución del script,
    # no se pasó parámetros.
    respuesta="s"
    if [ ! $desatendido ]; then
        echo
        read -p "¿Deseas reiniciar ahora [S/n]?: " respuesta

        # La respuesta por defecto sera s,
        # si no se elige ninguna manualmente.
        if [ ! $respuesta ]; then
            respuesta="s"
        fi
    fi

    # Despedida.
    echo "
███████╗██╗███╗   ██╗
██╔════╝██║████╗  ██║
█████╗  ██║██╔██╗ ██║
██╔══╝  ██║██║╚██╗██║
██║     ██║██║ ╚████║
╚═╝     ╚═╝╚═╝  ╚═══╝"

    # Reiniciar.
    if [ $respuesta = "s" ] || [ $respuesta = "S" ]; then
        echo
        echo "Reinicio en 3 segundos ..."
        sleep 3
        reboot
    fi
}

f_finalizar
exit
