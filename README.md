# [<img alt="qr-code" src=".github/img/qr-code.png" width="80" height="80">](https://github.com/AlexGracia/Auto-xfce) Auto-xfce
[![licencia](https://img.shields.io/github/license/AlexGracia/Auto-xfce?label=licencia&logo=opensourceinitiative&logoColor=orange&style=flat-square)](LICENSE.md)
![plataforma](https://img.shields.io/badge/plataforma-linux-%23FCC624?style=flat-square&logo=linux)
[![version](https://img.shields.io/github/v/tag/AlexGracia/Auto-xfce?style=flat-square&label=version&color=blue)](https://github.com/AlexGracia/Auto-xfce/tags)

Script que instala [Xfce](https://www.xfce.org/) mínimo, paquetes y configuraciones.

## Requisitos
- Paquetería APT
- Conexión de red
- Usuario root
- Paquete [wget](https://www.gnu.org/software/wget/)

## Demostración
![demo-auto](.github/img/demo-auto.gif)

## Instalación
1. Descargar
    ```sh
    wget https://git.new/auto-xfce.sh
    ```
1. Ejecutar
    ```sh
    sh auto-xfce.sh
    ```

> [!TIP]
> Utiliza [personalizar-xfce.sh](https://github.com/AlexGracia/Personalizar-xfce) para personalizar Xfce.

## Características
- [x] 1. Comprobaciones iniciales
- [x] 2. Elegir opcion
- [x] 3. Actualizar paquetes
- [x] 4. Instalar paquetes
- [x] 5. Configurar seguridad
- [x] 6. Configurar servicios
- [x] 7. Configurar red
- [x] 8. Configurar swap
- [x] 9. Configurar autoinicio
- [x] 10. Configurar tareas
- [x] 11. Configurar bashrc
- [x] 12. Configurar aliases
- [x] 13. Configurar nanorc
- [x] 14. Configurar hidden
- [x] 15. Configurar redshift
- [x] 16. Configurar brillo
- [x] 17. Configurar shell

## Herramientas
- [IT-TOOLS](https://github.com/CorentinTh/it-tools): [ASCII Art Text Generator](https://it-tools.tech/ascii-text-drawer), fuente ANSI Shadow, utilizado en texto de bienvenida y despedida.
- [Pollinations.AI](https://github.com/pollinations/pollinations): [generación de imagen con IA](https://pollinations.ai/), utilizado en fondos de pantalla.
- [Llama 3.3](https://github.com/meta-llama/llama3): utilizado a través del chat de [DuckDuckGo](https://Duck.ai), para resolver dudas.
- [Dub](https://github.com/dubinc/dub): [acortador de enlaces](https://dub.co/), utilizado en los enlaces de descarga.
- [Nano](https://www.nano-editor.org/git.php): [editor de texto](https://www.nano-editor.org/docs.php).
- [Boxes](https://gitlab.gnome.org/gnome/gnome-boxes): [gestor de máquinas virtuales](https://apps.gnome.org/es/Boxes/), utilizado para probar el script.
- [OBS Studio](https://github.com/obsproject/obs-studio): [grabador y transmisor de audio y vídeo](https://obsproject.com), utilizado para grabar la demostración en vídeo (mkv).
- [FFmpeg](https://git.ffmpeg.org/ffmpeg): [grabador, conversor y transmisor de audio y vídeo](https://ffmpeg.org/), utilizado para transformar la demostración de vídeo (mkv) a imagen (gif).

## Otras automatizaciones
- [Preseed](https://wiki.debian.org/DebianInstaller/Preseed).
- [Simple-CDD](https://wiki.debian.org/Simple-CDD).
