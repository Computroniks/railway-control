// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package devmgr

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/container"
	"github.com/Computroniks/railway-control/configuration_manager/communication"
)

type devInfoTab struct {
	window  *fyne.Window
	root    *container.TabItem
	content *fyne.Container
	onError func(error)
	conn    communication.Connection
}

func NewDeviceInfoTab(window *fyne.Window, conn communication.Connection, onError func(error)) Tab {
	tab := &devInfoTab{window: window, onError: onError, conn: conn}

	tab.content = container.NewVBox()

	tab.root = container.NewTabItem("Device Info", tab.content)
	tab.conn.Write()
	return tab
}

func (tab *devInfoTab) GetTab() *container.TabItem {
	return tab.root
}
