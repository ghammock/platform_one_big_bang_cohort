#!/bin/bash
#
# This script installs the software required by the Platform One
# Big Bang Cohort.  You're welcome everyone.
#
# SPDX-License-Identifier: MIT
#
# Copyright (c) 2021 Gary Hammock
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice (including the next
# paragraph) shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
#
# Limitations
# ===========
# Right now the script only works with APT-based distributions (e.g. Ubuntu
# and Debian).
#

VERSION="0.1.0"

set -e
LANG=en_US.UTF-8

RED="\e[1;31m"
GREEN="\e[1;32m"
CYAN="\e[36m"
RESET="\e[0m"
BOLD="\e[1;4;37m"

ID=$(id -u)

if [[ ${ID} -ne 0 ]]; then
  echo -e "${CYAN}Switching to root user to install packages${RESET}"
  sudo -E $0 $@
  exit 0
else
  echo -e "${BOLD}Big Bang Cohort Software Installation (Version ${VERSION})${RESET}"
  echo ""
fi

PREREQUISITES=( apt-transport-https \
                ca-certificates     \
                curl                \
                gnupg               \
                lsb-release         \
                openssl             \
                python3             \
                python3-pip         \
                unzip)
               
echo "Installing pre-requisite software.  Please wait..."
apt-get install -y ${PREREQUISITES[@]} &> /dev/null

REQUIRED_PACKAGES=( sshuttle  \
                    kubectl   \
                    kustomize \
                    git       \
                    terraform \
                    docker    \
                    aws       \
                    flux      \
                    sops      \
                    kubectx)
                    
PACKAGES_TO_INSTALL=()

for PKG_NAME in ${REQUIRED_PACKAGES[@]}; do
  echo -e -n "  \u25b8  Testing ${PKG_NAME}"

  if [[ $(command -v ${PKG_NAME} &> /dev/null; echo $?) -ne 0 ]]; then
    echo -e " ${RED}(not installed) \u2717${RESET}"
    PACKAGES_TO_INSTALL+=(${PKG_NAME})
  else
    echo -e " ${GREEN}(installed) \u2714${RESET}"
  fi
done

echo ""

if [[ ${#PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
  echo -e "${GREEN}Congratulations!  You have all the software you need.${RESET}"
  echo ""
  exit 0
fi

echo "Packages to install:"
for PKG_NAME in ${PACKAGES_TO_INSTALL[@]}; do
  echo -e "  \u25b8  ${CYAN}${PKG_NAME}${RESET}"
done

echo ""

for PKG_NAME in ${PACKAGES_TO_INSTALL[@]}; do
  case ${PKG_NAME} in
    sshuttle)
      echo "Installing sshuttle"
      pip3 install sshuttle --no-cache &> /dev/null \
        && echo -e "    ${GREEN}sshuttle installed successfully${RESET}" \
      || echo -e "    ${RED}sshuttle installation failed${RESET}"
    ;;
    
    kubectl)
      # see: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
      echo "Downloading kubectl"
      curl -fsLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
        && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
        && echo -e "    ${GREEN}kubectl installed successfully${RESET}" \
        && rm -f kubectl \
      || echo -e "    ${RED}kubectl installation failed${RESET}"
    ;;

    kustomize)
      # see: https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/
      echo "Downloading kustomize"
      curl -fsL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash &> /dev/null \
        && install -o root -g root -m 0755 kustomize /usr/local/bin/kustomize \
        && echo -e "    ${GREEN}kustomize installed successfully${RESET}" \
        && rm -f kustomize \
      || echo -e "    ${RED}kustomize installation failed${RESET}"
    ;;

    git)
      # see:
      echo "Installing git"
      apt-get install -y git &> /dev/null \
        && echo -e "    ${GREEN}git installed successfully${RESET}" \
      || echo -e "    ${RED}git installation failed${RESET}"
    ;;

    terraform)
      # see:
      echo "Downloading terraform"
      curl -fsL -o "terraform.zip" "https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip" \
        && unzip -o -qq terraform.zip \
        && install -o root -g root -m 0755 terraform /usr/local/bin/terraform \
        && rm -f terraform.zip \
        && echo -e "    ${GREEN}terraform installed successfully${RESET}" \
        && rm -f terraform \
      || echo -e "    ${RED}terraform installation failed${RESET}"
    ;;
    docker)
      echo "Installing docker"
      DOCKER_INSTALL_SUCCEEDED=0
      curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
            https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      echo -e "    ${CYAN}Updating apt sources (this may take some time)${RESET}"
      apt-get -qq update \
        && apt-get install -y docker-ce docker-ce-cli containerd.io &> /dev/null \
        && echo -e "    ${GREEN}docker installed successfully${RESET}" \
        && DOCKER_INSTALL_SUCCEEDED=1 \
      || echo -e "    ${RED}docker installation failed${RESET}"
      
      if [[ ${DOCKER_INSTALL_SUCCEEDED} -eq 1 ]]; then
        echo -e "    ${CYAN}Updating user group permissions${RESET}"
        usermod -G docker -a $(logname)
        echo -e "    ${CYAN}Permissions updated${RESET} ${BOLD}(You will need to log-out and log in again)${RESET}"
      fi
    ;;
    
    aws)
      echo "Downloading AWS CLI"
      # NOTE: The directory /usr/local/aws-cli/<major.minor.patch>/dist has incorrect
      # permissions (has 750, needs 755, basically only root can use it).
      curl -fsL -o "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        && unzip -o -qq awscliv2.zip \
        && ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli &> /dev/null \
        && chmod -R 755 /usr/local/aws-cli \
        && echo -e "    ${GREEN}AWS CLI installed successfully${RESET}" \
        && rm -rf aws awscliv2.zip \
      || echo -e "    ${RED}AWS CLI installation failed${RESET}"
    ;;
    
    flux)
      echo "Downloading Flux"
      curl -fsL "https://fluxcd.io/install.sh" | bash &> /dev/null \
        && . <(flux completion bash) \
        && echo -e "    ${GREEN}Flux installed successfully${RESET}" \
      || echo -e "    ${RED}Flux installation failed${RESET}"
    ;;
    
    sops)
      echo "Downloading sops"
      curl -fsL -o "sops" "https://github.com/mozilla/sops/releases/download/v3.6.1/sops-v3.6.1.linux" \
        && install -o root -g root -m 0755 sops /usr/local/bin/sops \
        && echo -e "    ${GREEN}sops installed successfully${RESET}" \
        && rm -f sops \
      || echo -e "    ${RED}sops installation failed${RESET}"
    ;;
    
    kubectx)
      echo "Installing kubectx"
      curl -fsLO "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx" \
        && install -o root -g root -m 755 kubectx /usr/local/bin/kubectx \
        && echo -e "    ${GREEN}kubectx installed successfully${RESET}" \
        && rm -f kubectx \
      || echo -e "    ${RED}kubectx installation failed${RESET}"
    ;;

    *)
      echo -e "${CYAN}Manual installation needed for ${BOLD}${PKG_NAME}${RESET}${RESET}"
    ;;
  esac
done

echo ""
echo "Check the output above to see if manual installation"
echo "of any packages is necessary."
echo ""

exit 0

