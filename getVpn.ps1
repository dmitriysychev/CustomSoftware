function Vpn-running {
	return (!($Null -eq (get-process "vpnui" -ea SilentlyContinue)))
}
#Instructions for vpn
function Attention-Window {
	Add-Type -AssemblyName PresentationCore,PresentationFramework
	$MessageIcon = [System.Windows.MessageBoxImage]::Warning
	$ButtonType = [System.Windows.MessageBoxButton]::Ok
	$MessageboxTitle = "INSTRUCTIONS ON HOW TO CONNECT TO THE VPN"
	$Messageboxbody = "Please follow the instructions below on how to connect to vpn: `n
	1. If the address field is empty when Cisco VPN app opens up, enter vpn.utexas.edu`n
	2. Your username is your UT EID `n
	3. Your password is the same as your EID password `n
	4. Second password option is used with DUO app.`n
	IF YOU READ AND UNDERSTOOD INSTRUCTIONS, CLICK OK BELOW"
	[System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$Messageicon)
}

function Vpn-Process {
		Start-Process "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe" -Wait

		$id = Get-Process -Name "vpnui" | Select-Object -ExpandProperty Id -First 1

		# access the COM component
		$shell = New-Object -ComObject WScript.Shell

		# call "AppActivate"
		$shell.AppActivate($id) | Out-Null

		$vpnui = get-process "vpnui"
}

function Activate-Windows {
	Start-Process cmd  "/c `"cscript C:\windows\system32\slmgr.vbs -ato & pause `"" -NoNewWindow
}

function Test-vpnConnection {
	$test = Test-NetConnection kms.austin.utexas.edu -Port 1688 -InformationLevel "Detailed"
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
	
	$flag = Test-vpnConnection
	do {
		Write-Host "TRYING TO CONNECT TO KMS SERVER..."
		$flag = Test-vpnConnection
	}while(!($flag))
	Write-Host "Connection to kms has been established, activating windows now!"
	Activate-Windows

	
}

# Displays user instruction on how to connect to VPN
#put the function in the script block so it can be executed asynchronously

# async execution of attention window
#Start-Job -ScriptBlock $attention_window_scriptblock

Proceed-VPN








