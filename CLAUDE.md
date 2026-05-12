# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart sourdough starter monitoring lid for a Weck 580ml (742) glass jar. An M5Stack Core Ink (ESP32 + e-ink display) sits in a 3D-printed replacement lid and tracks temperature, humidity, pressure, and dough rise via I2C sensors, reporting to Home Assistant over WiFi.

## Hardware

- **Controller**: M5Stack Core Ink (ESP32, 1.54" e-ink, 390mAh battery)
- **Sensors**: ENV III (SHT30 temp/hum + QMP6988 pressure), VL53L0X ToF (rise distance)
- **Wiring**: All I2C via Grove through a 1-to-3 HUB; SDA=GPIO21, SCL=GPIO22

## Architecture

- `sourdough-lid.yaml` — ESPHome device configuration (sensors, display, WiFi, OTA)
- `lid/sourdough-lid.scad` — Parametric OpenSCAD model for the 3D-printed enclosure (4 parts: base plate, top housing, ToF bracket, ENV III bracket)

## Commands

```bash
# Validate ESPHome config
esphome config sourdough-lid.yaml

# Compile firmware
esphome compile sourdough-lid.yaml

# Flash over USB
esphome upload sourdough-lid.yaml

# Flash over WiFi (after initial USB flash)
esphome upload --device sourdough-lid.local sourdough-lid.yaml

# Render OpenSCAD model to STL
/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD -o lid/sourdough-lid.stl lid/sourdough-lid.scad
```

## OpenSCAD Model

The lid model in `lid/sourdough-lid.scad` is fully parametric — jar dimensions, component sizes, wall thickness, and clearances are configurable at the top of the file. Toggle between `print_layout()` (print-ready, parts separated) and `assembled()` (visualization with ghost components) by editing the render selector near the top.
