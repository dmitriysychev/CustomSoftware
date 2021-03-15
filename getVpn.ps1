function Vpn-running {
	return (!($Null -eq (get-process "vpnui" -ea SilentlyContinue)))
}
#Instructions for vpn
function Attention-Window {
	Add-Type -AssemblyName PresentationCore,PresentationFramework
	$MessageIcon = [System.Windows.MessageBoxImage]::Warning
	$ButtonType = [System.Windows.MessageBoxButton]::Ok
	$MessageboxTitle = "INSTRUCTIONS ON HOW TO CONNECT TO THE VPN"
	$Messageboxbody = "<you can put custom instructions for the user to connect to vpn>"
	[System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$Messageicon)
}

function Vpn-Process {
		Start-Process "vpn client" -Wait

		$id = Get-Process -Name "vpnui" | Select-Object -ExpandProperty Id -First 1

		# access the COM component
		$shell = New-Object -ComObject WScript.Shell

		# call "AppActivate"
		$shell.AppActivate($id) | Out-Null

		$vpnui = get-process "vpnui"
}

function Activate-Windows {
	Start-Process cmd  "/c `"vbs script for activation & pause `"" -NoNewWindow
}

function Test-vpnConnection {
	$test = Test-NetConnection <kms server address> -Port <port> -InformationLevel "Detailed"
	$status = $test.TcpTestSucceeded
	return ($status)
}

$attention_window_scriptblock = {
	Attention-Window
}

function Proceed-VPN {
	Start-Job -ScriptBlock $attention_window_scriptblock
	Attention-Window
	Vpn-Process
	
	$flag = 0
	while (!($flag)) {
		$flag = Test-vpnConnection
	}
	Write-Host "Connection to kms has been established, activating windows now!"
	Activate-Windows

	
}

# Displays user instruction on how to connect to VPN
#put the function in the script block so it can be executed asynchronously

Proceed-VPN








