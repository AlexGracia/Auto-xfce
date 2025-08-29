#!/usr/bin/env sh
# Descripcion: Script que personaliza Xfce.
# Autor: Alex Gracia
# Version: 0.1.0
# Requisitos: conexion de red y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

# Variables globales
opcion=$1

# Funcion para mostrar un titulo descriptivo del paso actual.
_titulo () {
    echo
    echo "  $1 ($2 de 3)"
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
    _titulo "Comprobaciones iniciales   " 1

    # Comprobar el paquete wget.
    echo "Comprobando el paquete wget ..."
    wget -h >/dev/null
    if [ $? != 0 ]; then
        _error "Problemas con la instalacion de wget."
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

    _ok
}

# Funcion para elegir opcion,
# si no se eligio previamente en la ejecucion del script.
_elegir_opcion () {
    _titulo "Elegir opcion              " 2

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
        _ok
        return
    fi

    _validar_opcion
}

#
#   3. Personalizar Xfce
#════════════════════════════════════════

# Funcion para personalizar Xfce.
_personalizar_xfce () {
    _titulo "Personalizar Xfce          " 3

    # Variables
    readonly fuente="Serif Bold 18"
    readonly tamanio_cursor="48"
    readonly carpeta_iconos="$HOME/.icons"
    readonly carpeta_temas="$HOME/.themes"
    estilo=""
    tema=""
    cursor=""

    # Carpeta temporal de trabajo
    cd /tmp/
    if [ ! -d "auto-xfce" ]; then
        mkdir auto-xfce
    fi
    cd auto-xfce/

    # Descargas
    # Cursor
    echo "Descargando cursor ..."
    wget -q --show-progress -O cursores.zip https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/heads/master.zip
    # Tema
    echo "Descargando tema ..."
    wget -q --show-progress -O temas.zip https://github.com/AlexGracia/Temas-xfwm4/archive/refs/heads/master.zip

    # Carpetas creadas
    # Iconos
    if [ ! -d "$carpeta_iconos" ]; then
        mkdir $carpeta_iconos
    fi
    # Tema
    if [ ! -d "$carpeta_temas" ]; then
        mkdir $carpeta_temas
    fi

    # Descomprimir
    # Cursor
    echo "Descomprimiendo cursor ..."
    7z x -y cursores.zip '-xr!.gitignore' '-xr!.github' '-xr!colors' '-xr!links' '-xr!release' '-xr!src' '-xr!templates' '-xr!AUTHORS' '-xr!COPYING' '-xr!fluent-icon.jpg' '-xr!install.sh' '-xr!README.md' '-xr!build.sh' '-xr!LICENSE' '-xr!logo.png' '-xr!logo.svg' '-xr!preview-01.png' '-xr!preview-02.png' >/dev/null 2>&1

    sleep 0.5

    # Tema
    echo "Descomprimiendo tema ..."
    7z x -y temas.zip '-xr!img' '-xr!*.md' >/dev/null 2>&1

    sleep 0.5

    # todo  
    echo "Aplicando personalización ..."
    if [ $opcion = "f" ]; then
        estilo="HighContrast"
        # Tema
        tema="Gris-light"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_temas"

        # Cursor
        cursor="Fluent-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist/ "$carpeta_iconos/$cursor"

        # Panel
        # Estilo, color sólido
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 0
        # Posicionar abajo
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=8;x=0;y=0'

        # Mostrar iconos del escritorio
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s true
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s true
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s true

        # Botones del título de las ventanas
        xfconf-query -c xfwm4 -p /general/button_layout -s '|HMC'
    else
        estilo="Adwaita-dark"

        # Tema
        tema="Oliva-dark"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_temas"

        # Cursor
        cursor="Fluent-dark-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist-dark/ "$carpeta_iconos/$cursor"

        # Panel
        # Estilo, color sólido
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1
        # Color de fondo, negro
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba -t double -s 0.000000 -t double -s 0.000000 -t double -s 0.000000 -t double -s 1.000000
        # Posicionar arriba
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=6;x=0;y=0'

        # Ocultar iconos del escritorio
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s false
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s false
        xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s false

        # Botones del título de las ventanas
        xfconf-query -c xfwm4 -p /general/button_layout -s '|C'
    fi

    # Apariencia
    xfconf-query -c xsettings -p /Net/ThemeName -s $estilo
    xfconf-query -c xsettings -p /Gtk/FontName -s "$fuente"

    # Gestor de ventanas
    xfconf-query -c xfwm4 -p /general/theme -s $tema
    xfconf-query -c xfwm4 -p /general/title_font -s "$fuente"
    xfconf-query -c xfwm4 -p /general/use_compositing -s false
    xfconf-query -c xfwm4 -p /general/workspace_count -s 1

    # Cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s $cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s $tamanio_cursor

    # Panel
    # Tamaño de la fila, 32 px
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 32
    # Tamaño de los iconos, 16 px
    xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s 16
    # Mostrar el indicador del modo de presentación
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/show-presentation-indicator -s true

    # Recargar escritorio.
    #xfdesktop --reload
    _ok
}

# Funcion para iniciar el script.
_iniciar () {
    # Bienvenida.
    clear
    echo "
╔═══════════════════╗
║ Personalizar Xfce ║
╚═══════════════════╝"

    _comprobaciones_iniciales
    _elegir_opcion
    _personalizar_xfce
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Despedida.
    echo "
╔═══════════════════╗
║        Fin        ║
╚═══════════════════╝"
}

_finalizar

exit
