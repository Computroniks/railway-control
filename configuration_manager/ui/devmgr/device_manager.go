// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package devmgr

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"github.com/Computroniks/railway-control/configuration_manager/communication"
)

type DeviceManager interface {
	GetCanvasObject() fyne.CanvasObject
}

type Callbacks struct {
	OnCommsError func(error)
}

type devmgr struct {
	parent    *fyne.Window
	root      *container.AppTabs
	conn      communication.Connection
	callbacks Callbacks
	tabs      []Tab
}

func New(parent *fyne.Window, conn communication.Connection, callbacks Callbacks) DeviceManager {
	dm := &devmgr{
		parent:    parent,
		conn:      conn,
		callbacks: callbacks,
	}

	dm.root = container.NewAppTabs()

	dm.tabs = append(dm.tabs, NewDeviceInfoTab(dm.parent, dm.conn, dm.callbacks.OnCommsError))

	for _, tab := range dm.tabs {
		dm.root.Append(tab.GetTab())
	}

	return dm
}

func (dm *devmgr) GetCanvasObject() fyne.CanvasObject {
	return dm.root
}
