// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package communication

import "go.bug.st/serial"

func GetSerialDevices() ([]string, error) {
	return serial.GetPortsList()
}
