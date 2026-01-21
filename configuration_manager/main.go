// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package main

import (
	"github.com/Computroniks/railway-control/configuration_manager/ui"
)

func main() {
	ui := ui.NewUi()
	ui.Run()
}
