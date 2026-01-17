<!--
SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Architecture

![Diagram showing a control system with a Control Panel, Control Unit,
Track Relay, Point Controller, Motor Driver, and E-Stop Button connected
via CAN.](figures/architecture.svg)

## Control Bus

The control bus uses CAN for communication. Each board on the bus
must be configured using the USB interface to set a unique address.
