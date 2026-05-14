# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Smart sourdough starter monitoring lid for a Weck 580ml (742) glass jar. An M5Stack Core Ink (ESP32 + e-ink display) sits in a 3D-printed replacement lid and tracks temperature, humidity, pressure, and dough rise via I2C sensors, reporting to Home Assistant over WiFi.

## Hardware

- **Controller**: M5Stack Core Ink (ESP32, 1.54" e-ink, 390mAh battery)
- **Sensors**: ENV III (SHT30 temp/hum + QMP6988 pressure), VL53L0X ToF (rise distance)
- **Wiring**: All I2C via Grove through a 1-to-3 HUB; SDA=GPIO32, SCL=GPIO33

## Architecture

- `sourdough-lid.yaml` — ESPHome device configuration (sensors, display, WiFi, OTA)
- `lid/lid.blend` — Blender model for the 3D-printed enclosure (exported as `lid/lid.stl`)

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

# Render lid images
blender --background --python lid/render.py
```
