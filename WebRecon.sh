#!/bin/bash

################################################################################
# Titulo    : WebRecon                                                         #
# Versao    : 1.0                                                              #
# Data      : 25/01/2023                                                       #
# Homepage  : https://blogdopitta.top/                                         #
# Tested on : Linux                                                            #
# -----------------------------------------------------------------------------#
# Descrição:                                                                   #
#   Esse programa tem a função de procurar diretorios e arquivos               #
#   através de brutforce, com o auxílio de wordlists                           #
#                                                                              #
################################################################################

# ==============================================================================
# Constantes
# ==============================================================================

# Constantes para facilitar a utilização das cores.
RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[1;34m'
YELLOW='\033[33;1m'
RED_BLINK='\033[31;5;1m'
END='\033[m'

# Constantes criadas utilizando os valores dos argumentos
# passados, para evitando a perda dos valores.
ARG01="${1}"
ARG02="${2}"

# Identificando tecnologias
echo""
echo -e "${BLUE} ->WebServer identificado: $(curl -s  -H 'User-Agent: AlianTool' --head businesscorp.com.br | grep 'Server:') ${END}"
TECNOLOGIAS=`printf "GET /index.php HTTP/1.0\r\n\r\n" | nc rh.businesscorp.com.br 80 | grep "X-Powered-By:" | cut -d ":" -f2`
echo -e "${BLUE} ->Tecnologias: $TECNOLOGIAS ${END}"


# Constante utilizada para guadar a versão do programa.
VERSION='1.0'

# Variáveis com os locais das listas
DIRETORIOS='/root/Desktop/webrecon'
ARQUIVOS='/root/Desktop/webrecon'

# Função chamada quando cancelar o programa com [Ctrl]+[c]
trap __Ctrl_c__ INT

# ==============================================================================
# Função chamada ao pressionar as teclas Ctrl+c
# ==============================================================================

__Ctrl_c__() {
    __Clear__
    echo -e "\n${RED_BLINK}!!! Ação abortada !!!${END}\n\n"
    exit 1
}

# ==============================================================================
#                           Banner do programa
# ------------------------------------------------------------------------------
# Função responsável por apenas mostrar o banner do programa junto com algumas
# opções básicas.
# ==============================================================================

__Banner__() {
    echo -e "
        ${YELLOW}
        ################################################################################
        #                                                                              #
        #                             WebRecon                                         #
        #                          Alian Vargas Pitta                                  #
        #                          Version ${VERSION}                                  #
        #                                                                              #
        ################################################################################
        ${END}
        Usage   : ${GREEN}${0}${END} [URL] [EXTENCAO]
        Example : ${GREEN}${0}${END} site.com php
        Try ${GREEN}${0} -h${END} for more options."
}


# ==============================================================================
#                                Menu de ajuda
# ------------------------------------------------------------------------------
# Função responsável por explicar para o usuário o propósito do programa e como
# ele funciona, mostrando todas as suas opções.
# ==============================================================================

__Help__() {
    echo -e "
    NAME
        ${0} - Software para procura diretórios e arquivos.
    SYNOPSIS
        ${0} [URL] [EXTENCAO]
    DESCRIPTION
        O ${0} é usado para procurar descobrir diretorios e arquivos
        por meio de bruteforce.
    OPTIONS
        -h, --help
            Mostra o menu de ajuda.
        -v, --version
            Mostra a versão do programa.
        -f, --file
            Procura diretorios no arquivo informado.
                Ex: ${0} -f file.txt"
}


# ==============================================================================
#                           Verificação básica
# ------------------------------------------------------------------------------
# Função responsável por verificar todos os requisitos básicos, para o
# funcionamento do programa, como verificando se os programas e scripts de
# terceiros estão instalados e se os argumentos foram passados corretamente.
# ==============================================================================

__Verification__() {
    # Verificando as dependências.
    if ! [[ -e /usr/bin/wget ]]; then
        echo -e "\nFaltando programa ${RED}wget${END} para funcionar.\n"
        exit 1
    elif ! [[ -e /usr/bin/curl ]]; then
        echo -e "\nFaltando programa ${RED}curl${END} para funcionar.\n"
        exit 1
    fi

    # Verificando se não foi passado argumentos.
    if [[ "${ARG01}" == "" ]]; then
        __Banner__
        exit 1
    fi
}


# ==============================================================================
#                       Limpando arquivos temporários
# ------------------------------------------------------------------------------
# Função para apagar todos os arquivos temporários criados durante a execução
# do programa.
# ==============================================================================

__Clear__() {
    rm -rf /tmp/$ARG01 &>/dev/null
    #rm -rf /tmp/tempfile &>/dev/null
}


# ==============================================================================
#                           Procurando diretórios
# ------------------------------------------------------------------------------
# Função responsável por criar o diretório para amazenar os nomes de diretórios
# encontrados e exibir os nomes.
# ==============================================================================

__Diretorios__() {
    # É criado e utilizado um diretório em /tmp, para não sujar o sistema do
    # usuário.
    __Clear__

    mkdir /tmp/$ARG01 && cd /tmp/$ARG01
    #echo "caminho = /tmp/$ARG01"

echo -e "${YELLOW}
################################################################################
#                            Procurando por diretórios                         #
################################################################################
${END}"

	for palavra in $(cat $DIRETORIOS/diretorios.txt)
	do
		resposta=$(curl -s -H "User-Agent: AlianTool" -o /dev/null -w "%{http_code}" $ARG01/$palavra/)
		if [ $resposta == '200' ]
		then
			echo -e "${GREEN}Diretorio encontrado:${END} ${YELLOW} $ARG01/$palavra/ ${END}"
			echo "$ARG01/$palavra/" >> /tmp/$ARG01/DiretoriosEncontrados.txt
		fi
	done
	echo ""
}


# ==============================================================================
#                           Procurando arquivos
# ------------------------------------------------------------------------------
# Função responsável por exibir os nomes de de arquivos
# encontrados.
# ==============================================================================

__Arquivos__() {
	cd /tmp/$ARG01
echo -e "${YELLOW}
################################################################################
#                         Procurando por arquivos                              #
################################################################################
${END}"

	for arquivos in $(cat $ARQUIVOS/arquivos.txt)
	do
		if [[ $arquivos == *.* ]]
		then
			resp_arquivo=$(curl -s -H "User-Agent: DesecTool" -o /dev/null -w "%{http_code}" $ARG01/$arquivos)
			#echo "Procurando por: $ARG01/$arquivos"
		else
			resp_arquivo=$(curl -s -H "User-Agent: DesecTool" -o /dev/null -w "%{http_code}" $ARG01/$arquivos.$ARG02)
			#echo "Procurando por: $ARG01/$arquivos.$ARG02"
		fi

		if [ $resp_arquivo == '200' ]
		then
			if [[ $arquivos == *.* ]]
			then
				echo -e "${GREEN}Arquivo encontrado:${END} ${YELLOW} $ARG01/$arquivos ${END}"
			else
				echo -e "${GREEN}Arquivo encontrado:${END} ${YELLOW} $ARG01/$arquivos.$ARG02 ${END}"
			fi
		fi
	done
}



# ==============================================================================
# Função principal do programa
# ==============================================================================

__Main__() {
    __Verification__

    case "${ARG01}" in
        "-v"|"--version")
              echo -e "\nVersion: ${VERSION}\n"
              exit 0
        ;;
        "-h"|"--help")
              __Help__
              exit 0
        ;;
        *) __Diretorios__
           __Arquivos__
           __Clear__
        ;;
    esac
}

# ==============================================================================
# Inicio do programa
# ==============================================================================

__Main__
