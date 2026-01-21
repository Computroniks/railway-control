// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package communication

import "go.bug.st/serial"

type Connection interface {
	Write() error
	Close() error
}

type connection struct {
	mode *serial.Mode
	port serial.Port
}

func NewConnection(device string, baud int) (Connection, error) {
	mode := &serial.Mode{
		BaudRate: baud,
	}
	port, err := serial.Open(device, mode)
	if err != nil {
		return nil, err
	}

	return &connection{mode: mode, port: port}, nil
}

func (conn *connection) Write() error {
	_, err := conn.port.Write([]byte("123"))
	return err
}

func (conn *connection) Close() error {
	return conn.port.Close()
}
