#!/usr/bin/env sh
# Descripcion: Script que instala Xfce mínimo, paquetes, configuraciones y personalizaciones.
# Autor: Alex Gracia
# Version: 0.16.0
# Requisitos: paqueteria APT, conexion de red, usuario root y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Variables globales
readonly desatendido=$1
opcion=$1
readonly paquetes_frecuentes="anacron brightnessctl cups evince galculator gthumb lazpaint-qt5 mousepad network-manager network-manager-gnome p7zip-full printer-driver-all redshift redshift-gtk sakura simple-scan sudo system-config-printer thunar-archive-plugin ufw vlc xfce4 xfce4-power-manager xfce4-screenshooter xfce4-whiskermenu-plugin zram-tools"
readonly paquetes_infrecuentes="brightnessctl chromium evince firejail gimp git gnome-boxes gnumeric gpdf gpicview jigdo network-manager network-manager-gnome optipng p7zip-full pandoc qpdf redshift redshift-gtk sakura sd sudo ufw vlc xfce4 xfce4-power-manager xfce4-screenshooter zram-tools"
usuario=""
carpeta_usuario=""

# Funcion para mostrar un titulo descriptivo del paso actual.
_titulo () {
    echo
    echo "  $1 ($2 de 16)"
    echo "════════════════════════════════════════"
}

# Funcion para mostrar un mensaje de error en rojo.
_error () {
    echo
    echo "\e[91;1m[ ERROR ] $1 \e[0m"
    exit 1
}

# Funcion para mostrar un mensaje de ok en verde.
_ok () {
    echo
    echo "\e[92;1m[ OK ]\e[0m"
    sync
}

#
#   1. Comprobaciones iniciales
#════════════════════════════════════════

# Funcion para las comprobaciones iniciales.
_comprobaciones_iniciales () {
    _titulo "Comprobaciones iniciales  " 1

    # Comprobar la paqueteria.
    echo "Comprobando la paqueteria ..."
    apt-get -h >/dev/null
    if [ $? != 0 ]; then
        _error "Debes tener la paqueteria apt."
    fi

    # Comprobar el usuario.
    echo "Comprobando el usuario ..."
    if [ "$(whoami)" != "root" ]; then
        _error "Debes ser usuario root."
    fi

    # Comprobar el paquete wget.
    echo "Comprobando el paquete wget ..."
    wget -h >/dev/null
    # Intentar instalar si falta.
    if [ $? != 0 ]; then
        apt-get install -y wget
        if [ $? != 0 ]; then
            _error "Problemas con la instalacion de wget."
        fi
    fi

    _ok
}

#
#   2. Elegir opcion
#════════════════════════════════════════

# Funcion para validar la opcion elegida.
_validar_opcion () {
    # Convertir mayusculas en minusculas.
    opcion=$(echo "$opcion" | tr '[:upper:]' '[:lower:]')

    # Advertir si la opcion es invalida y volver a preguntar.
    if [ $opcion != "f" ] && [ $opcion != "i" ]; then
        echo
        echo "\e[93;1m[ ! ] Debes escoger una opcion valida (f/i).\e[0m"
        opcion=""
        _elegir_opcion
        return
    fi

    echo "Opcion $opcion elegida."

    _ok
}

# Funcion para elegir opcion,
# si no se eligio previamente en la ejecucion del script.
_elegir_opcion () {
    _titulo "Eligiendo opcion " 2

    # No elegir manualmente opcion,
    # si ya se ha elegido en la ejecucion del script.
    if [ $opcion ]; then
        _validar_opcion
        return
    fi

    # Elegir opcion.
    echo "- Opcion [f]recuente."
    echo "- Opcion [i]nfrecuente."
    echo
    read -p "¿Que deseas elegir [F/i]?: " opcion

    # La opcion por defecto sera f,
    # si no se elige ninguna manualmente.
    if [ ! $opcion ]; then
        opcion="f"
        echo "Opcion $opcion elegida."
        _ok
        return
    fi

    _validar_opcion
}

#
#   3. Actualizar paquetes
#════════════════════════════════════════

# Funcion para actualizar paquetes.
_actualizar_paquetes () {
    _titulo "Actualizando paquetes     " 3

    # Actualizar paquetes.
    apt-get update
    apt-get upgrade -y

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   4. Instalar paquetes
#════════════════════════════════════════

# Funcion para obtener el nombre de usuario.
_obtener_usuario () {
    usuario=$(getent group users | cut -d: -f4 -s | sed -n 1p)
    if [ "$usuario" = "" ]; then
        usuario=$(getent passwd | grep home | cut -d: -f1 -s | sed -n 1p)
        if [ "$usuario" = "" ]; then
            usuario=$(cat /etc/passwd | grep home | cut -d: -f1 -s | sed -n 1p)
            if [ "$usuario" = "" ]; then
                _error "Usuario no encontrado."
            fi
        fi
    fi
    readonly carpeta_usuario="/home/$usuario"
}

# Funcion para instalar OnlyOffice, desde su repositorio oficial.
# URL: https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx
_onlyoffice () {
    # Añadir repositorio.
    mkdir -p -m 700 "$carpeta_usuario/.gnupg"
    gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
    chmod 644 /tmp/onlyoffice.gpg
    chown root:root /tmp/onlyoffice.gpg
    mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
    echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | tee -a /etc/apt/sources.list.d/onlyoffice.list

    # Actualizar lista de paquetes.
    apt-get update

    # Instalar OnlyOffice.
    apt-get install -y onlyoffice-desktopeditors

    if [ $? != 0 ]; then
        _error "Problemas con la instalacion de OnlyOffice."
    fi
}

# Funcion para instalar Firefox, desde su repositorio oficial.
# URL: https://support.mozilla.org/en-US/kb/install-firefox-linux
_firefox () {
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
    apt-get update

    # Instalar Firefox.
    apt-get install -y firefox firefox-l10n-es-es

    if [ $? != 0 ]; then
        _error "Problemas con la instalacion de Firefox."
    fi
}

# Funcion para instalar paquetes.
_instalar_paquetes () {
    _titulo "Instalando paquetes       " 4

    _obtener_usuario

    # Instalar paquetes.
    if [ $opcion = "f" ]; then
        apt-get install -y $paquetes_frecuentes

        if [ $? != 0 ]; then
            _error
        fi

        # Instalar OnlyOffice.
        _onlyoffice
    else
        apt-get install -y $paquetes_infrecuentes

        if [ $? != 0 ]; then
            _error
        fi
    fi

    # Instalar Firefox.
    _firefox

    _ok
}

#
#   5. Configurar seguridad
#════════════════════════════════════════

# Funcion para configurar la seguridad.
_configurar_seguridad () {
    _titulo "Configurando seguridad    " 5

    # Variables
    local archivo="/etc/sudoers.d/reglas-personalizadas"
    readonly archivo

    # Configurar sudo.
    echo "# Pedir contraseña root, por cada comando sudo" > $archivo
    echo "Defaults timestamp_timeout=0" >> $archivo

    if [ $? != 0 ]; then
        _error
    fi

    # Configurar ufw.
    ufw default deny incoming
    ufw default deny outgoing
    ufw allow out 'WWW Full'
    ufw allow out DNS
    ufw enable

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   6. Configurar servicios
#════════════════════════════════════════

# Funcion para configurar los servicios.
_configurar_servicios () {
    _titulo "Configurando servicios    " 6

    # Deshabilitar servicio de bluetooth.
    if systemctl is-active --quiet bluetooth; then
        systemctl stop bluetooth
        systemctl disable bluetooth
        systemctl mask bluetooth
    fi

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   7. Configurar red
#════════════════════════════════════════

# Funcion para configurar la red.
_configurar_red () {
    _titulo "Configurando red          " 7

    # Variables
    local archivo="/etc/network/interfaces"
    readonly archivo

    # Comentar las interfaces de red, para gestionarlas manualmente.
    sed -i '/^$/b; /^#/b; s/^/#/' $archivo

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   8. Configurar swap
#════════════════════════════════════════

# Funcion para configurar el swap.
_configurar_swap () {
    _titulo "Configurando swap         " 8

    # Variables
    local archivo="/etc/default/zramswap"
    readonly archivo

    # Configurar 25% de RAM.
    sed -i 's/PERCENT=.*$/PERCENT=25/' $archivo

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   9. Configurar autoinicio
#════════════════════════════════════════

# Funcion para configurar el autoinicio.
_configurar_autoinicio () {
    _titulo "Configurando autoinicio   " 9

    # Variables
    local archivo="/etc/lightdm/lightdm.conf"
    readonly archivo

    # Configurar LightDM.

    # Usuario que iniciará sesión.
    sed -i "s/^#autologin-user=.*$/autologin-user=$usuario/" $archivo

    if [ $? != 0 ]; then
        _error
    fi

    # Quitar tiempo de espera.
    sed -i 's/^#autologin-user-timeout=.*$/autologin-user-timeout=0/' $archivo

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   10. Configurar tareas
#════════════════════════════════════════

# Funcion para configurar las tareas.
_configurar_tareas () {
    _titulo "Configurando tareas      " 10

    # Variables
    local tareas="/etc/anacrontab"
    local carpeta="/usr/local/sbin/"
    local url="https://github.com/AlexGracia/Auto-xfce/raw/refs/heads/master/scripts-secundarios/"
    readonly tareas
    readonly carpeta
    readonly url
    local script=""

    if [ $opcion = "f" ]; then
        # 1. Configurar actualizaciones semanalmente.

        # Controlar duplicidades.
        cat $tareas | grep -q "actualizacion"

        if [ $? = 0 ]; then
            return
        fi

        # Descargar script.
        echo "Descargando script para actualizar pc ..."
        script="actualizar-pc.sh"
        wget -q --show-progress -O $script $url$script

        # Dar permiso de ejecución.
        chmod u+x $script

        # Guardar el script.
        mv $script $carpeta

        # Añadir tarea.
        echo "7 5 actualizacion $carpeta$script >/dev/null 2>&1" >> $tareas

        if [ $? != 0 ]; then
            _error
        fi

        # 2. Configurar limpieza mensualmente.

        # Controlar duplicidades.
        cat $tareas | grep -q "limpieza"

        if [ $? = 0 ]; then
            return
        fi

        # Descargar script.
        echo "Descargando script para limpiar pc ..."
        script="limpiar-pc.sh"
        wget -q --show-progress -O $script $url$script

        # Dar permiso de ejecución.
        chmod u+x $script

        # Guardar el script.
        mv $script $carpeta

        # Añadir tarea.
        echo "@monthly 5 limpieza $carpeta$script >/dev/null 2>&1" >> $tareas

        if [ $? != 0 ]; then
            _error
        fi
    else
        # Comprobar actualizaciones semanalmente.

        # Controlar duplicidades.
        cat $tareas | grep -q "actualizaciones"

        if [ $? = 0 ]; then
            return
        fi

        # Descargar script.
        echo "Descargando script para comprobar actualizaciones ..."
        script="comprobar-actualizaciones.sh"
        wget -q --show-progress -O $script $url$script

        # Dar permiso de ejecución.
        chmod u+x $script

        # Guardar el script.
        mv $script $carpeta

        # Añadir tarea.
        echo "7 1 actualizaciones $carpeta$script >/dev/null 2>&1" >> $tareas

        if [ $? != 0 ]; then
            _error
        fi
    fi

    _ok
}

#
#   11. Configurar bashrc
#════════════════════════════════════════

# Funcion para configurar el bashrc.
_configurar_bashrc () {
    _titulo "Configurando bashrc      " 11

    if [ $opcion = "f" ]; then
        return
    fi

    # Variables
    local archivo=".bashrc"
    readonly archivo

    # 1. Usuario root.
    echo "export PS1='\n\[\033[38;5;196m\]\[$(tput sgr0)\] ( \[\033[38;5;45m\]\w\[$(tput sgr0)\] ) \[\033[38;5;246m\]\$?\[$(tput sgr0)\]: '" >> ~/$archivo

    if [ $? != 0 ]; then
        _error
    fi

    # 2. Usuario no root.
    echo "export PS1='\n\[\033[38;5;42m\]\[$(tput sgr0)\] ( \[\033[38;5;45m\]\w\[$(tput sgr0)\] ): '" >> "$carpeta_usuario/$archivo"

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   12. Configurar aliases
#════════════════════════════════════════

# Funcion para configurar los aliases.
_configurar_aliases () {
    _titulo "Configurando aliases     " 12

    if [ $opcion = "f" ]; then
        return
    fi

    # Variables
    local archivo=""

    # 1. Usuario root.
    archivo=".bashrc"
    echo "alias actualizate='apt-get update && apt list --upgradable && apt-get upgrade'" >> ~/$archivo
    echo "alias exit='echo > ~/.bash_history && sync && exit'" >> ~/$archivo
    echo "alias limpiate='apt-get clean && apt-get autoclean && apt-get autopurge && apt-get purge $(apt-mark showremove) && journalctl --vacuum-size=100M'" >> ~/$archivo
    echo "alias ls='ls -shop --color=auto'" >> ~/$archivo
    echo "alias reboot='sync && reboot'" >> ~/$archivo

    if [ $? != 0 ]; then
        _error
    fi

    # 2. Usuario no root.
    archivo="$carpeta_usuario/.bash_aliases"
    echo "alias calculadora='bc'" >> "$archivo"
    echo "alias curl='firejail curl'" >> "$archivo"
    echo "alias cvlc='firejail cvlc'" >> "$archivo"
    echo "alias exit='echo > ~/.bash_history && sync && exit'" >> "$archivo"
    echo "alias imgcomprimir='optipng -strip all'" >> "$archivo"
    echo "alias imgver='gpicview'" >> "$archivo"
    echo "alias ls='ls -shop --color=auto'" >> "$archivo"
    echo "alias pdfver='evince'" >> "$archivo"
    echo "alias su='su -'" >> "$archivo"
    echo "alias wget='firejail wget'" >> "$archivo"

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   13. Configurar nanorc
#════════════════════════════════════════

# Funcion para configurar el nanorc.
_configurar_nanorc () {
    _titulo "Configurando nanorc      " 13

    if [ $opcion = "f" ]; then
        return
    fi

    # Variables
    local archivo="$carpeta_usuario/.nanorc"
    readonly archivo

    # Usuario no root.
    echo "set autoindent" >> "$archivo"
    echo "set tabsize 4" >> "$archivo"
    echo "set tabstospaces" >> "$archivo"
    # Borrar parte seleccionada.
    echo "set zap" >> "$archivo"
    # La línea que excede el ancho de la pantalla, se muestra en múltiples líneas.
    echo "set softwrap" >> "$archivo"
    # Informacion (nombre archivo, nº de lineas, nº de caracteres, ...).
    echo "set constantshow" >> "$archivo"
    echo "set minibar" >> "$archivo"

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   14. Configurar hidden
#════════════════════════════════════════

# Funcion para configurar el hidden.
_configurar_hidden () {
    _titulo "Configurando hidden      " 14

    # Variables
    local archivo="$carpeta_usuario/.hidden"
    readonly archivo

    # Usuario no root.
    # Este archivo oculta las carpetas y archivos escritos aqui
    echo "Escritorio" >> "$archivo"
    echo "Imágenes" >> "$archivo"
    echo "Música" >> "$archivo"
    echo "Plantillas" >> "$archivo"
    echo "Público" >> "$archivo"
    echo "Vídeos" >> "$archivo"

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   15. Configurar redshift
#════════════════════════════════════════

# Funcion para configurar redshift.
_configurar_redshift () {
    _titulo "Configurando redshift    " 15

    # Variables
    local archivo="$carpeta_usuario/.config/redshift.conf"
    readonly archivo

    echo "[redshift]" >> "$archivo"
    echo "temp-day=5780" >> "$archivo"
    echo "temp-night=5780" >> "$archivo"
    echo "fade=0" >> "$archivo"
    echo "gamma=0.8" >> "$archivo"
    echo "location-provider=manual" >> "$archivo"
    echo "adjustment-method=randr" >> "$archivo"
    echo "[manual]" >> "$archivo"
    echo "lat=41.64" >> "$archivo"
    echo "lon=-0.88" >> "$archivo"
    echo "[randr]" >> "$archivo"

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

#
#   16. Configurar brillo
#════════════════════════════════════════

# Funcion para configurar el brillo de la pantalla.
_configurar_brillo () {
    _titulo "Configurando brillo      " 16

    brightnessctl set 90%

    if [ $? != 0 ]; then
        _error
    fi

    _ok
}

# Funcion para iniciar el script.
_iniciar () {
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
    _comprobaciones_iniciales

    _elegir_opcion

    _actualizar_paquetes

    _instalar_paquetes

    _configurar_seguridad

    _configurar_servicios

    _configurar_red

    _configurar_swap

    _configurar_autoinicio

    _configurar_tareas

    _configurar_bashrc

    _configurar_aliases

    _configurar_nanorc

    _configurar_hidden

    _configurar_redshift

    _configurar_brillo
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Limpiar y ordenar.
    # Paquetes.
    apt-get clean -y
    apt-get autoclean -y
    apt-get autopurge -y
    apt-get purge $(apt-mark showremove)
    journalctl --vacuum-size=100M
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

_finalizar
exit
