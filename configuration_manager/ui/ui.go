// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package ui

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
	"github.com/Computroniks/railway-control/configuration_manager/ui/connmgr"
	"github.com/Computroniks/railway-control/configuration_manager/ui/devmgr"
)

type Ui interface {
	Run()
}

type ui struct {
	app                 fyne.App
	window              fyne.Window
	deviceMgrRoot       *fyne.Container
	connectionMgr       connmgr.ConnectionManager
	notConnectedMessage *fyne.Container
	deviceMgr           devmgr.DeviceManager
}

func NewUi() ui {
	var u ui
	u.app = app.New()
	u.window = u.app.NewWindow("Railway Controller Configuration Manager")
	u.window.Resize(fyne.NewSize(800, 600))

	u.notConnectedMessage = container.NewCenter(widget.NewLabel("Not Connected"))

	u.deviceMgrRoot = container.NewBorder(nil, nil, nil, nil, u.notConnectedMessage)

	u.connectionMgr = connmgr.New(&u.window,
		connmgr.Callbacks{
			OnConnect:    u.OnConnect,
			OnDisconnect: u.OnDisconnect,
		},
	)
	content := container.NewHSplit(u.connectionMgr.GetCanvasObject(), u.deviceMgrRoot)
	content.SetOffset(0)

	u.window.SetContent(content)
	return u
}

func (u *ui) Run() {
	u.window.ShowAndRun()
}

func (u *ui) OnConnect() {
	u.deviceMgrRoot.Remove(u.notConnectedMessage)
	u.deviceMgr = devmgr.New(&u.window, u.connectionMgr.GetConnection(),
		devmgr.Callbacks{
			OnCommsError: func(err error) {
				dialog.ShowError(err, u.window)
				u.connectionMgr.Disconnect()
			},
		})
	u.deviceMgrRoot.Add(u.deviceMgr.GetCanvasObject())
}

func (u *ui) OnDisconnect() {
	u.deviceMgrRoot.Remove(u.deviceMgr.GetCanvasObject())
	u.deviceMgrRoot.Add(u.notConnectedMessage)
	u.connectionMgr.Disconnect()
}
