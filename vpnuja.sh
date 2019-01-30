#!/bin/bash
#
# Connect to UJA VPN
# amontejo@ujaen.es - 2018
#
# Para conectarse, basta con invocar el script "vpnuja"
# Si el complemento no está instalado, realiza una instalación previa
# Para cerrar la sesión, invocar de nuevo el script
# Es robusto a ubicación, por lo que puede crearse un launcher en el escritorio
#
# LICENSE
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

F5BIN=/usr/local/bin/f5fpc

if [ ! -f $F5BIN ]; then \
  echo "No se encuentra el programa f5fpc. Vamos a instalarlo, por lo que se le requerirá su clave de root..."
  mkdir /tmp/vpnssl$$
  ( cd /tmp/vpnssl$$
  curl https://vpnssl.ujaen.es/public/download/linux_sslvpn.tgz -o linux_sslvpn.tgz
  tar zxvf linux_sslvpn.tgz
  sudo ./Install.sh
  )
  rm -rf /tmp/vpnssl$$
  echo "Instalado"
fi

if [[ $# -gt 0 ]]; then \
  if [[ $1 == "stop" ]]; then \
    $F5BIN --stop
    exit 0
  fi
fi

if !(which zenity &> /dev/null); then \
  echo "Cuenta TIC (sin @ujaen.es):"
  read USERNAME
  $F5BIN -s -u $USERNAME -t vpnssl.ujaen.es -x
  if ($F5BIN --info|grep established) &> /dev/null; then \
    echo "Ahora está conectado a la UJA por VPN.\nUse 'vpnujaen stop' para cerrar la conexión."
  else
    echo "No se pudo realizar la conexión"
  fi
else
  if ($F5BIN --info|grep established) &> /dev/null; then \
    if zenity --question --text="Hay una conexión abierta ¿desea cerrarla?"; then \
      $F5BIN --stop
      zenity --info --text="Conexión cerrada."
    fi
    exit 0
  fi
  USERNAME=`zenity --entry --text="Cuenta TIC"`
  PASSWORD=`zenity --password`
  $F5BIN -s -u $USERNAME -p $PASSWORD -t vpnssl.ujaen.es -x
  sleep 2
  if ($F5BIN --info|grep established) &> /dev/null; then \
    zenity --info --text="Ahora está conectado a la UJA por VPN.\nVuelva a ejecutar este programa cuando desee cerrar la conexión."
  else
    zenity --error --text="No se pudo realizar la conexión"
  fi
fi
