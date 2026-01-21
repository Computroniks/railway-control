// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

package devmgr

import "fyne.io/fyne/v2/container"

type Tab interface {
	GetTab() *container.TabItem
}
