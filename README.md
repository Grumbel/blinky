blinky
======

A simple LED blinky app for the STM32F401CCU6 (Blackpill) that serves
as an example/experiment on how to package STM32CubeMX apps for NixOS.


Building
--------

    nix build .


Installing on the STM32F401CCU6 via ST-Link
-------------------------------------------

    nix run .#install

