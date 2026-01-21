// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package connmgr

import (
	"slices"
	"strconv"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/data/binding"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"
	"github.com/Computroniks/railway-control/configuration_manager/communication"
)

type ConnectionManager interface {
	GetCanvasObject() fyne.CanvasObject
	Disconnect()
	GetConnection() communication.Connection
}

type Callbacks struct {
	OnConnect    func()
	OnDisconnect func()
}

type connection struct {
	conn      communication.Connection
	connected bool
}

type connectionManager struct {
	parent        *fyne.Window
	root          *fyne.Container
	currentDevice binding.String
	currentBaud   binding.String
	callbacks     Callbacks
	conn          connection
	inputs        struct {
		deviceSelect     *widget.Select
		baudSelect       *widget.Select
		connectBtn       *widget.Button
		deviceRefreshBtn *widget.Button
	}
}

func New(parent *fyne.Window, callbacks Callbacks) ConnectionManager {
	cm := &connectionManager{
		parent:    parent,
		callbacks: callbacks,
		conn:      connection{conn: nil, connected: false},
	}

	cm.root = container.NewVBox(
		widget.NewLabel("Connection Manager"),
		widget.NewSeparator(),
	)

	cm.initConnectionSettings()

	return cm
}

func (cm *connectionManager) GetCanvasObject() fyne.CanvasObject {
	return cm.root
}

func (cm *connectionManager) Disconnect() {
	if cm.conn.connected {
		cm.conn.conn.Close()
		cm.conn.conn = nil
		cm.conn.connected = false
		cm.enableInputs()
		cm.inputs.connectBtn.SetText("Connect")
		cm.callbacks.OnDisconnect()
	}
}

func (cm *connectionManager) GetConnection() communication.Connection {
	return cm.conn.conn
}

func (cm *connectionManager) initConnectionSettings() {
	btnSize := fyne.NewSquareSize(36)
	form := container.New(layout.NewFormLayout())
	// Device select
	cm.currentDevice = binding.NewString()
	cm.inputs.deviceSelect = widget.NewSelectWithData([]string{}, cm.currentDevice)
	cm.refreshDevices()

	cm.inputs.deviceRefreshBtn = widget.NewButtonWithIcon("", theme.ViewRefreshIcon(), func() { cm.refreshDevices() })
	form.Add(widget.NewLabel("Device"))
	form.Add(container.NewBorder(nil, nil, nil, cm.inputs.deviceRefreshBtn, cm.inputs.deviceSelect))

	// Baud select
	cm.currentBaud = binding.NewString()
	cm.currentBaud.Set("115200")
	cm.inputs.baudSelect = widget.NewSelectWithData([]string{"9600", "19200", "38400", "115200"}, cm.currentBaud)
	form.Add(widget.NewLabel("Baud"))
	form.Add(container.NewBorder(nil, nil, nil, container.NewGridWrap(btnSize, layout.NewSpacer()), cm.inputs.baudSelect))

	cm.root.Add(form)

	// Connect
	cm.inputs.connectBtn = widget.NewButton("Connect", func() {
		if cm.conn.connected {
			cm.Disconnect()
		} else {
			cm.connect()

		}
	})
	cm.inputs.connectBtn.Disable()
	cm.root.Add(cm.inputs.connectBtn)

	cm.currentBaud.AddListener(binding.NewDataListener(cm.conditionallyEnableConnectBtn))
	cm.currentDevice.AddListener(binding.NewDataListener(cm.conditionallyEnableConnectBtn))

}

func (cm *connectionManager) refreshDevices() {
	devices, err := communication.GetSerialDevices()

	if err != nil {
		dialog.ShowError(err, *cm.parent)
	}
	cm.inputs.deviceSelect.SetOptions(devices)

	currentDevice, err := cm.currentDevice.Get()
	if err != nil || !slices.Contains(devices, currentDevice) {
		cm.inputs.deviceSelect.ClearSelected()
	}
}

func (cm *connectionManager) conditionallyEnableConnectBtn() {
	device, _ := cm.currentDevice.Get()
	baud, _ := cm.currentBaud.Get()

	if device != "" && baud != "" {
		cm.inputs.connectBtn.Enable()
	} else {
		cm.inputs.connectBtn.Disable()
	}
}

func (cm *connectionManager) disableInputs() {
	cm.inputs.baudSelect.Disable()
	cm.inputs.deviceSelect.Disable()
	cm.inputs.deviceRefreshBtn.Disable()
	cm.inputs.connectBtn.Disable()
}

func (cm *connectionManager) enableInputs() {
	cm.inputs.baudSelect.Enable()
	cm.inputs.deviceSelect.Enable()
	cm.inputs.deviceRefreshBtn.Enable()
	cm.conditionallyEnableConnectBtn()
}

func (cm *connectionManager) connect() {
	cm.disableInputs()

	strbaud, _ := cm.currentBaud.Get()
	baud, _ := strconv.Atoi(strbaud)
	device, _ := cm.currentDevice.Get()
	var err error
	cm.conn.conn, err = communication.NewConnection(device, baud)
	if err != nil {
		cm.enableInputs()
		dialog.ShowError(err, *cm.parent)
	}

	cm.conn.connected = true
	cm.inputs.connectBtn.SetText("Disconnect")
	cm.inputs.connectBtn.Enable()
	cm.callbacks.OnConnect()
}
