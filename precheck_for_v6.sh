#!/bin/bash

# Based Debian 13, Astrovim v6.0.4, Neovim v0.11.7
#
# 1. NerdFont
# 2. neovim version need v0.11.x
# 3. treesitter cli
# 4. c compiler
# 5. clipboard tool: xclip/xsel(linux)
# 6. ripgrep
# 7. laztgit
# 8. gdu
# 9. bottom
# 10. nodejs

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
RESET='\e[0m'

err ()
{
  echo -e "${RED}$1${RESET}"
}

warn()
{
  echo -e "${YELLOW}$1${RESET}"
}

info ()
{
  echo -e "${GREEN}$1${RESET}"
}

check_nerdfont ()
{
  nf=$(fc-list | grep Nerd)
  if [[ $nf = "" ]]; then
    err "CHECK 1 FAIED: no NerdFont in system "
    warn "FIX: install by https://www.nerdfonts.com/font-downloadsn "
  else
    info "CHECK 1 PASSED: NerdFont "
  fi
}

check_neovim ()
{
  nv=$(nvim -v | grep NVIM)
  if [[ $nv == *v0.11.* ]]; then
    info "CHECK 2 PASSED: Neovim "
  else
    err "CHECK 2 FAIED: Neovim version is not v0.11.x "
    warn "FIX: install or update Neovim to v0.11.x by https://neovim.io/doc/install/ "
  fi
}

check_tsc ()
{
  tsc=$(tree-sitter -V)
  if [[ $tsc == tree-sitter* ]]; then
    info "CHECK 3 PASSED: tree-sitter cli "
  else
    err "CHECK 3 FAIED: no tree-sitter-cli in system "
    warn "FIX: run 'sudo apt install tree-sitter-cli' to install tree-sitter-cli "
  fi
}

check_cc ()
{
  cc=$(gcc --help | grep Usage)
  if [[ $cc = "" ]]; then
    err "CHECK 4 FAIED: gcc not found "
    warn "FIX: run 'sudo apt install gcc' to install gcc "
  else
    info "CHECK 4 PASSED: gcc "
  fi
}

check_clipboard ()
{
  xsel=$(ls /usr/bin | grep xsel)
  xclip=$(ls /usr/bin | grep xclip)
  if [[ $xsel != "" && $xclip != "" ]]; then
    info "CHECK 5 PASSED: xclip/xsel "
  else
    err "CHECK 5 FAIED: xclip/xsel not found "
    warn "FIX: run 'sudo apt install xclip xsel' to install xclip/xsel "
  fi
}

chech_ripgrep ()
{
  rg=$(rg -V)
  if [[ $rg = "" ]]; then
    err "CHECK 6 FAIED: rg(ripgrep) not found "
    warn "FIX: run 'sudo apt install ripgrep' to install rg(ripgrep) "
  else
    info "CHECK 6 PASSED: ripgrep "
  fi
}

check_lazygit ()
{
  lg=$(ls /usr/bin | grep lazygit)
  if [[ $lg = "" ]]; then
    err "CHECK 7 FAIED: lazygit not found "
    warn "FIX: run 'sudo apt install lazygit' to install lazygit "
  else
    info "CHECK 7 PASSED: lazygit "
  fi
}

check_gdu ()
{
  gdu=$(ls /usr/bin | grep gdu)
  if [[ $gdu = "" ]]; then
    err "CHECK 8 FAIED: gdu not found "
    warn "FIX: run 'sudo apt install gdu' to install gdu "
  else
    info "CHECK 8 PASSED: gdu "
  fi
}

check_bottom ()
{
  btm=$(btm -V)
  if [[ $btm = "" ]]; then
    err "CHECK 9 FAIED: btm not found "
    warn "FIX: run 'sudo apt install btm' to install btm "
  else
    info "CHECK 9 PASSED: btm "
  fi
}

check_node ()
{
  js=$(node -v)
  npm=$(npm -v)
  if [[ $js != "" && $npm != "" ]]; then
    info "CHECK 10 PASSED: nodejs/npm "
  else
    err "CHECK 10 FAIED: nodejs/npm "
    warn "FIX: run 'sudo apt install nodejs npm' to install nodejs/npm "
  fi
}

warn "This script check for env: Debian 13, Neovim v0.11.x, Astrovim v6 "
warn "================================================================= "
check_nerdfont
check_neovim
check_tsc
check_cc
check_clipboard
chech_ripgrep
check_lazygit
check_gdu
check_bottom
check_node
