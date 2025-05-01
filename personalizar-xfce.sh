#!/bin/sh
# Descripcion: Script que personaliza XFCE
# Autor: Alex Gracia
# Version: 0.1.0
# Requisitos: conexion de red y paquete wget
# URL: https://github.com/AlexGracia/Auto-xfce
#════════════════════════════════════════

#
#   1. Personalizar XFCE
#════════════════════════════════════════

# Funcion para personalizar XFCE.
_personalizar_xfce () {

    # Variables
    estilo=""
    letra="Serif Bold 18"
    tema=""
    tipografia="Serif Bold 20"
    cursor=""
    tamanio_cursor="48"
    carpeta_iconos="$HOME/.icons"
    carpeta_tema="$HOME/.themes"

    # Carpeta temporal
    cd /tmp/
    mkdir auto-xfce
    cd auto-xfce/

    # Descargas
    # Color carpetas
    wget -q https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/refs/heads/master/papirus-folders
    # Cursor
    wget -qO cursores.zip https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/heads/master.zip
    # Tema
    wget -qO temas.zip https://github.com/AlexGracia/Temas-xfwm4/archive/refs/heads/master.zip

    # Carpetas creadas
    # Iconos
    if [ ! -d "$carpeta_iconos" ]; then
        mkdir $carpeta_iconos
    fi
    # Tema
    if [ ! -d "$carpeta_tema" ]; then
        mkdir $carpeta_tema
    fi

    # Descomprimir
    # Cursor
    7z x cursores.zip '-xr!.gitignore' '-xr!.github' '-xr!colors' '-xr!links' '-xr!release' '-xr!src' '-xr!templates' '-xr!AUTHORS' '-xr!COPYING' '-xr!fluent-icon.jpg' '-xr!install.sh' '-xr!README.md' '-xr!build.sh' '-xr!LICENSE' '-xr!logo.png' '-xr!logo.svg' '-xr!preview-01.png' '-xr!preview-02.png'

    sleep 0.5

    # Tema
    7z x temas.zip '-xr!img' '-xr!*.md'

    sleep 0.5

# todo  
    if [ $personalizacion = "f" ]; then
        estilo="HighContrast"
        # Tema
        tema="Gris-light"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_tema"

        # Cursor
        cursor="Fluent-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist/ "$carpeta_iconos/$cursor"

        # Cambiar color de carpeta
        papirus-folders -C paleorange --theme Papirus-Light

        # Posicionar panel abajo
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=8;x=0;y=0'

        # Fondo de pantalla
        wget -q https://raw.githubusercontent.com/AlexGracia/Auto-xfce/refs/heads/master/img/wallpaper-6-light.jpeg
        mv wallpaper-6-light.jpeg /usr/share/images/desktop-base
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitoreDP-1/workspace0/last-image -s /usr/share/images/desktop-base/wallpaper-6-light.jpeg
    else
        estilo="Adwaita-dark"

        # Tema
        tema="Oliva-dark"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_tema"

        # Cursor
        cursor="Fluent-dark-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist-dark/ "$carpeta_iconos/$cursor"

        # Cambiar color de carpeta
        papirus-folders -C paleorange --theme Papirus-Dark

        # Posicionar panel arriba
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=6;x=0;y=0'
    fi

    # Apariencia
    xfconf-query -c xsettings -p /Net/ThemeName -s $estilo
    xfconf-query -c xsettings -p /Gtk/FontName -s $letra

    # Gestor de ventanas
    xfconf-query -c xfwm4 -p /general/theme -s $tema
    xfconf-query -c xfwm4 -p /general/title_font -s $tipografia

    # Cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s $cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s $tamanio_cursor

    # Panel
    # Estilo, color sólido
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-style -s 1
    # Color de fondo, negro
    xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba -t double -s 0.000000 -t double -s 0.000000 -t double -s 0.000000 -t double -s 1.000000
    # Tamaño de la fila, 52 px
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 52
    # Tamaño de los iconos, 16 px
    xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -s 16
    # Mostrar el indicador del modo de presentación
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/show-presentation-indicator -s
true

# Recargar escritorio.
#xfdesktop --reload

}

# Funcion para iniciar el script.
_iniciar () {
    # Bienvenida.
    clear
    echo "
██████╗ ███████╗██████╗ ███████╗ ██████╗ ███╗   ██╗ █████╗ ██╗     ██╗███████╗ █████╗ ██████╗
██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║     ██║╚══███╔╝██╔══██╗██╔══██╗
██████╔╝█████╗  ██████╔╝███████╗██║   ██║██╔██╗ ██║███████║██║     ██║  ███╔╝ ███████║██████╔╝
██╔═══╝ ██╔══╝  ██╔══██╗╚════██║██║   ██║██║╚██╗██║██╔══██║██║     ██║ ███╔╝  ██╔══██║██╔══██╗
██║     ███████╗██║  ██║███████║╚██████╔╝██║ ╚████║██║  ██║███████╗██║███████╗██║  ██║██║  ██║
╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝

██╗  ██╗███████╗ ██████╗███████╗
╚██╗██╔╝██╔════╝██╔════╝██╔════╝
 ╚███╔╝ █████╗  ██║     █████╗
 ██╔██╗ ██╔══╝  ██║     ██╔══╝
██╔╝ ██╗██║     ╚██████╗███████╗
╚═╝  ╚═╝╚═╝      ╚═════╝╚══════╝"

    _personalizar_xfce
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Despedida.
    echo "
███████╗██╗███╗   ██╗
██╔════╝██║████╗  ██║
█████╗  ██║██╔██╗ ██║
██╔══╝  ██║██║╚██╗██║
██║     ██║██║ ╚████║
╚═╝     ╚═╝╚═╝  ╚═══╝"
}

_finalizar

exit
