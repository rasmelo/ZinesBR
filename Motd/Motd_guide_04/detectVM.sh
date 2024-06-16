#!/bin/bash
#
# Motd Laboratories
# www.motdlabs.org
#
# Script que procura verificar se esta rodando dentro do VMWare (Testado no VMWare 5.0)
# Nada muito util, nem muito inutil :)
#
# dude#./detectVM.sh
# Iniciando...
# Nenhuma assinatura encontrada.
#
# hallz <hallz motdlabs org>


# Coisas pra enfeitar o script
FOUND='\e[1m<\e[31m!\e[0m\e[1m>\e[0m\e[31m'
NR='\e[0m'


#
# Comeca
#
VM=0                    #alguma assinatura encontrada?

echo "Iniciando..."


#
# Procura pelo VMWare tools
#
if [ -d /etc/vmware-tools -o -d /usr/lib/vmware-tools ]; then

   echo -e "$FOUND Diretorio do VMWare Tools existe! $NR"
   (( VM++ ))

else

   find /usr/X* -iname vmmouse_*.o 2> /dev/null > findtools
   if [  `wc -c findtools | cut -f1 -d " "` -ne 0 ]; then
      echo -e "$FOUND Driver vmmouse do VMWare tools encontrado! $NR"
      (( VM++ ))
   fi

   rm findtools
fi



#
# Procura por assinaturas do VMWare no hardware
#
if [ -f /sbin/lspci ]; then
   /sbin/lspci -v | egrep -i "vmware" > vmwaredet

   if [ `wc -c vmwaredet | cut -f1 -d " "` -ne 0 ]; then
      echo -e "$FOUND Assinaturas do hardware do VMWare foram encontradas! (lspci)$NR"
      (( VM++ ))
   fi

   rm vmwaredet


elif [ -f /bin/dmesg ]; then
   /bin/dmesg | egrep -i "vendor: vmware|vmware virtual" > vmwaredet

   if [ `wc -c vmwaredet | cut -f1 -d " "` -ne 0 ]; then
      echo -e "$FOUND Assinaturas do hardware do VMWare foram encontradas! (dmesg)$NR"
      (( VM++ ))
   fi

   rm vmwaredet


else
   echo "dmesg e lspci nao foram encontrados"
fi



if [ -f /sbin/ifconfig ]; then
   /sbin/ifconfig | egrep -i "00:50:56:|00:0C:29:" > vmwaredet

   if [ `wc -c vmwaredet | cut -f1 -d " "` -ne 0 ]; then
      echo -e "$FOUND Encontrado MAC Address usado pelo VMWare! $NR"
      (( VM++ ))
   fi

   rm vmwaredet

else
   echo "ifconfig nao encontrado"
fi



#
# Procura por assinaturas do VMWare na memoria
#
VMASSI1='cafd4b705f7ad491c8bba533f01cf204'

if [ `id -u` -eq 0 ]; then

   if [ -f /bin/dd -a -f /usr/bin/hexdump -a -f /usr/bin/cut ]; then
      dd if=/dev/mem bs=64 skip=12651 count=1 2> /dev/null | md5sum | cut -f1 -d " " > memmd51

      if [ `cat memmd51 2> /dev/null` = "$VMASSI1" ]; then
         echo -e "$FOUND Assinatura 1 do VMWare encontrada na memoria! $NR"
         (( VM++ ))
      fi

      rm memmd51

   else
      echo "Nao foi possivel realizar a verificacao na memoria (faltam ferramentas)"
   fi

else
   echo "Nao foi possivel procurar por assinaturas na memoria. Rode o script como root"
fi



#
# se nao achou nada...
#
if [ $VM -eq 0 ]; then
   echo "Nenhuma assinatura encontrada."
fi
