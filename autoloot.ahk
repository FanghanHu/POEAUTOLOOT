#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;make it so only 1 instance of the script can be run at a time.
#SingleInstance Force

/*
	This script is designed around 2560 x 1440 resolution, it will not work on other resolution.
	by changing certain item's text color with item filters, you can pickup item without clicking on them.
	This script collect items from the cloest location first.
	
	auto potting section is highly customized, it will probably not work for your character without modification.
*/

;Item pickup
;auto pickup item by searching a specific color on screen and automatically clicking it,
;mouse will return to the original posion after clicking.
{
	;the color to be searched
	global itemColor := 0x00EA00

	;Look for a specific color on screen
	search(ByRef x, ByRef y, xs, ys, xe, ye)
	{
		x := -1
		y := -1
		PixelSearch, Px, Py, %xs%, %ys%, %xe%, %ye%, %itemColor%, 0, Fast
		if !ErrorLevel
		{
			x := Px
			y := Py
		}
	}
	
	;Check if x,y is valid, if so, click and move mouse back to original location
	checkForItem(x, y, ox, oy)
	{
		if (x >= 0 || y >= 0)
		{
			Send {f down}
			Sleep, 20
			MouseMove, %x%, %y%
			Sleep, 20
			click %x%, %y%
			Sleep, 20
			Send {f up}
			MouseMove, %ox%, %oy%
			return true
		}
		return false
	}

	;Auto pickup item
	~^[::
	{
		SetMouseDelay, 0
		cmx := 1280
		cmy := 720
		MouseGetPos, cmx, cmy

		sw := 2560
		sh := 1440
		
		;the total step needed to complete the search
		step := 5
		xm := sw / 2
		ym := sh / 2
		wd := xm / step
		hd := ym / step
		
		x := -1
		y := -1
		search(x, y, xm - wd, ym - hd, xm + wd, ym + hd)
		if(checkForItem(x, y, cmx, cmy))
		{
			Goto end_itemPickup
		}
		
		;the current step
		cs := 2
		
		while cs <= step
		{
			oxd := (cs - 1) * wd
			oyd := (cs - 1) * hd
			xd := cs * wd
			yd := cs * hd
			
			p1x := xm - xd
			p1y := ym - yd
			p2x := xm + xd
			p2y := ym - oyd
			
			
			search(x, y, p1x, p1y, p2x, p2y)
			if(checkForItem(x, y, cmx, cmy))
			{
				Goto end_itemPickup
			}
			
			p3x := xm - xd
			p3y := ym - oyd
			p4x := xm - oxd
			p4y := ym + oyd
			
			search(x, y, p3x, p3y, p4x, p4y)
			if(checkForItem(x, y, cmx, cmy))
			{
				Goto end_itemPickup
			}
			
			p5x := xm + oxd
			p5y := ym - oyd
			p6x := xm + xd
			p6y := ym + oyd
			
			search(x, y, p5x, p5y, p6x, p6y)
			if(checkForItem(x, y, cmx, cmy))
			{
				Goto end_itemPickup
			}
			
			p7x := xm - xd
			p7y := ym + oyd
			p8x := xm + xd
			p8y := ym + yd
			
			search(x, y, p7x, p7y, p8x, p8y)
			if(checkForItem(x, y, cmx, cmy))
			{
				Goto end_itemPickup
			}
			
			cs++
		}
		
		end_itemPickup:
		return
	}
}

;Quick Inventory Management
;Allow quickly move inventory item into stash and quickly identify inventory items
{
	;Left click the whole inventory excepts the last two column	
	clickInventory()
	{
		x := 1730
		y := 810
		while x <= 2360
		{
			while y <= 1090
			{
				if GetKeyState("SPACE", "D")
				{
					Send {Ctrl up}
					Sleep, 100
					Exit
				}
				MouseMove, %x%, %y%, 0
				Sleep, 15
				click %x%, %y%
				Sleep, 15
				y += 70
			}
			y := 810
			x += 70
		}
	}
	
	;auto move item to chest
	~end::
	{
		SetMouseDelay, 0
		Send {Ctrl down}
		clickInventory()
		Send {Ctrl up}
		return
	}
	
	;auto identify all items
	~F4::
	{
		SetMouseDelay, 0
		Send {Shift down}
		MouseMove, 153, 337, 0
		Sleep, 15
		Click, Right, 153, 337
		Sleep, 15
		clickInventory()
		Send {Shift up}
		return
	}
}