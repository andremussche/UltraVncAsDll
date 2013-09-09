/////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2002-2010 Ultr@VNC Team Members. All Rights Reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
//  USA.
//
// If the source code for the program is not available from the place from
// which you received this file, check 
// http://www.uvnc.com/
//
////////////////////////////////////////////////////////////////////////////

class vncProperties;

#if (!defined(_WINVNC_VNCPROPERTIES))
#define _WINVNC_VNCPROPERTIES

// Includes
// Marscha@2004 - authSSP: objbase.h needed for CoInitialize etc.
#include <objbase.h>

#include "stdhdrs.h"
#include "vncserver.h"
#include "vncsetauth.h"
#include "inifile.h"
#include <userenv.h>

struct vncPropertiesStruct
{
	int DebugMode;
	int Avilog;
	char * path;
	int DebugLevel;

	int AllowLoopback;
	int LoopbackOnly;
	int AllowShutdown;
	int AllowProperties;
	int AllowEditClients;
	int FileTransferTimeout;
	int KeepAliveInterval;
	int SocketKeepAliveTimeout;

	int DisableTrayIcon;
	int MSLogonRequired;
	int NewMSLogon;

	int UseDSMPlugin;
	int ConnectPriority;
	char * DSMPlugin;
	char * DSMPluginConfig;

	/*
	myIniFile.WriteInt("admin", "DebugMode", vnclog.GetMode());
	myIniFile.WriteInt("admin", "Avilog", vnclog.GetVideo());
	myIniFile.WriteString("admin", "path", vnclog.GetPath());
	myIniFile.WriteInt("admin", "DebugLevel", vnclog.GetLevel());
	myIniFile.WriteInt("admin", "AllowLoopback", m_server->LoopbackOk());
	myIniFile.WriteInt("admin", "LoopbackOnly", m_server->LoopbackOnly());
	myIniFile.WriteInt("admin", "AllowShutdown", m_allowshutdown);
	myIniFile.WriteInt("admin", "AllowProperties",  m_allowproperties);
	myIniFile.WriteInt("admin", "AllowEditClients", m_alloweditclients);
    myIniFile.WriteInt("admin", "FileTransferTimeout", m_ftTimeout);
    myIniFile.WriteInt("admin", "KeepAliveInterval", m_keepAliveInterval);
	// adzm 2010-08
    myIniFile.WriteInt("admin", "SocketKeepAliveTimeout", m_socketKeepAliveTimeout);

	myIniFile.WriteInt("admin", "DisableTrayIcon", m_server->GetDisableTrayIcon());
	myIniFile.WriteInt("admin", "MSLogonRequired", m_server->MSLogonRequired());
	// Marscha@2004 - authSSP: save "New MS-Logon" state
	myIniFile.WriteInt("admin", "NewMSLogon", m_server->GetNewMSLogon());
	// sf@2003 - DSM params here
	myIniFile.WriteInt("admin", "UseDSMPlugin", m_server->IsDSMPluginEnabled());
	myIniFile.WriteInt("admin", "ConnectPriority", m_server->ConnectPriority());
	myIniFile.WriteString("admin", "DSMPlugin",m_server->GetDSMPluginName());

	//adzm 2010-05-12 - dsmplugin config
	myIniFile.WriteString("admin", "DSMPluginConfig", m_server->GetDSMPluginConfig());
    */

	//user settings:

	int FileTransferEnabled;
	int FTUserImpersonation;
	int BlankMonitorEnabled;
	int BlankInputsOnly;
	int CaptureAlphaBlending;
	int BlackAlphaBlending;

	int DefaultScale;

	//int UseDSMPlugin;
	//char * DSMPlugin;
	//char * DSMPluginConfig;

	int primary;
	int secondary;

	// Connection prefs
	int SocketConnect;
	int HTTPConnect;
	int XDMCPConnect;
	int AutoPortSelect;
	int PortNumber;
	int HTTPPortNumber;
	int InputsEnabled;
	int LocalInputsDisabled;
	int IdleTimeout;
	int EnableJapInput;
	int clearconsole;
	int sendbuffer;

	// Connection querying settings
	int QuerySetting;
	int QueryTimeout;
	int QueryAccept;
	int QueryIfNoLogon;

	// Lock settings
	int LockSetting;

	// Wallpaper removal
	int RemoveWallpaper;
	// UI Effects
	// adzm - 2010-07 - Disable more effects or font smoothing
	int RemoveEffects;
	int RemoveFontSmoothing;
	// Composit desktop removal
	int RemoveAero;

	char password[MAXPWLEN];
	char password2[MAXPWLEN];

	/*
	// Modif sf@2002
	myIniFile.WriteInt("admin", "FileTransferEnabled", m_server->FileTransferEnabled());
	myIniFile.WriteInt("admin", "FTUserImpersonation", m_server->FTUserImpersonation()); // sf@2005
	myIniFile.WriteInt("admin", "BlankMonitorEnabled", m_server->BlankMonitorEnabled());
	myIniFile.WriteInt("admin", "BlankInputsOnly", m_server->BlankInputsOnly()); //PGM
	myIniFile.WriteInt("admin", "CaptureAlphaBlending", m_server->CaptureAlphaBlending()); // sf@2005
	myIniFile.WriteInt("admin", "BlackAlphaBlending", m_server->BlackAlphaBlending()); // sf@2005

	myIniFile.WriteInt("admin", "DefaultScale", m_server->GetDefaultScale());

	myIniFile.WriteInt("admin", "UseDSMPlugin", m_server->IsDSMPluginEnabled());
	myIniFile.WriteString("admin", "DSMPlugin",m_server->GetDSMPluginName());

	//adzm 2010-05-12 - dsmplugin config
	myIniFile.WriteString("admin", "DSMPluginConfig", m_server->GetDSMPluginConfig());

	myIniFile.WriteInt("admin", "primary", m_server->Primary());
	myIniFile.WriteInt("admin", "secondary", m_server->Secondary());

	// Connection prefs
	myIniFile.WriteInt("admin", "SocketConnect", m_server->SockConnected());
	myIniFile.WriteInt("admin", "HTTPConnect", m_server->HTTPConnectEnabled());
	myIniFile.WriteInt("admin", "XDMCPConnect", m_server->XDMCPConnectEnabled());
	myIniFile.WriteInt("admin", "AutoPortSelect", m_server->AutoPortSelect());
	if (!m_server->AutoPortSelect()) {
		myIniFile.WriteInt("admin", "PortNumber", m_server->GetPort());
		myIniFile.WriteInt("admin", "HTTPPortNumber", m_server->GetHttpPort());
	}
	myIniFile.WriteInt("admin", "InputsEnabled", m_server->RemoteInputsEnabled());
	myIniFile.WriteInt("admin", "LocalInputsDisabled", m_server->LocalInputsDisabled());
	myIniFile.WriteInt("admin", "IdleTimeout", m_server->AutoIdleDisconnectTimeout());
	myIniFile.WriteInt("admin", "EnableJapInput", m_server->JapInputEnabled());

	// Connection querying settings
	myIniFile.WriteInt("admin", "QuerySetting", m_server->QuerySetting());
	myIniFile.WriteInt("admin", "QueryTimeout", m_server->QueryTimeout());
	myIniFile.WriteInt("admin", "QueryAccept", m_server->QueryAccept());

	// Lock settings
	myIniFile.WriteInt("admin", "LockSetting", m_server->LockSettings());

	// Wallpaper removal
	myIniFile.WriteInt("admin", "RemoveWallpaper", m_server->RemoveWallpaperEnabled());
	// UI Effects
	// adzm - 2010-07 - Disable more effects or font smoothing
	myIniFile.WriteInt("admin", "RemoveEffects", m_server->RemoveEffectsEnabled());
	myIniFile.WriteInt("admin", "RemoveFontSmoothing", m_server->RemoveFontSmoothingEnabled());
	// Composit desktop removal
	myIniFile.WriteInt("admin", "RemoveAero", m_server->RemoveAeroEnabled());

	// Save the password
	char passwd[MAXPWLEN];
	m_server->GetPassword(passwd);
	myIniFile.WritePassword(passwd);
	memset(passwd, '\0', MAXPWLEN); //PGM
	m_server->GetPassword2(passwd); //PGM
	myIniFile.WritePassword2(passwd); //PGM
	*/
};

// The vncProperties class itself
class vncProperties
{
public:
	// Constructor/destructor
	vncProperties();
	~vncProperties();

	// Initialisation
	BOOL Init(vncServer *server);

	// The dialog box window proc
	static BOOL CALLBACK DialogProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

	// Display the properties dialog
	// If usersettings is TRUE then the per-user settings come up
	// If usersettings is FALSE then the default system settings come up
	void ShowAdmin(BOOL show, BOOL usersettings);

	// Loading & saving of preferences
	void Load(BOOL usersettings);
	void ResetRegistry();

	void Save();

	void FillPropertiesStruct(vncPropertiesStruct * aStruct);
	void ReadFromPropertiesStruct(vncPropertiesStruct * aStruct);

	// TRAY ICON MENU SETTINGS
	BOOL AllowProperties() {return m_allowproperties;};
	BOOL AllowShutdown() {return m_allowshutdown;};
	BOOL AllowEditClients() {return m_alloweditclients;};
	bool Lock_service_helper;

	BOOL m_fUseRegistry;
	// Ini file
	IniFile myIniFile;
	void LoadFromIniFile();
	void LoadUserPrefsFromIniFile();
	void SaveToIniFile();
	void SaveUserPrefsToIniFile();
    void ReloadDynamicSettings();

	// Making the loaded user prefs active (also starts server listening!)
	void ApplyUserPrefs();

	// Implementation
protected:
	// The server object to which this properties object is attached.
	vncServer *			m_server;

	// Flag to indicate whether the currently loaded settings are for
	// the current user, or are default system settings
	BOOL				m_usersettings;

	// Tray icon menu settings
	BOOL				m_allowproperties;
	BOOL				m_allowshutdown;
	BOOL				m_alloweditclients;
    int                 m_ftTimeout;
    int                 m_keepAliveInterval;
	int                 m_socketKeepAliveTimeout; // adzm 2010-08


	// Password handling
	void LoadPassword(HKEY k, char *buffer);
	void SavePassword(HKEY k, char *buffer);
	void LoadPassword2(HKEY k, char *buffer); //PGM
	void SavePassword2(HKEY k, char *buffer); //PGM

	// String handling
	char * LoadString(HKEY k, LPCSTR valname);
	void SaveString(HKEY k, LPCSTR valname, const char *buffer);

	// Manipulate the registry settings
	LONG LoadInt(HKEY key, LPCSTR valname, LONG defval);
	void SaveInt(HKEY key, LPCSTR valname, LONG val);

	// Loading/saving all the user prefs
	void LoadUserPrefs(HKEY appkey);
	void SaveUserPrefs(HKEY appkey);

	// Making the loaded user prefs active
	//void ApplyUserPrefs();
	
	BOOL m_returncode_valid;
	BOOL m_dlgvisible;

	// STORAGE FOR THE PROPERTIES PRIOR TO APPLICATION
	BOOL m_pref_SockConnect;
	BOOL m_pref_HTTPConnect;
	BOOL m_pref_XDMCPConnect;
	BOOL m_pref_AutoPortSelect;
	LONG m_pref_PortNumber;
	LONG m_pref_HttpPortNumber;  // TightVNC 1.1.7
	char m_pref_passwd[MAXPWLEN];
	char m_pref_passwd2[MAXPWLEN]; //PGM
	UINT m_pref_QuerySetting;
	// Marscha@2006 - Is AcceptDialog required even if no user is logged on
	UINT m_pref_QueryIfNoLogon;
	UINT m_pref_QueryAccept;
	UINT m_pref_QueryTimeout;
	UINT m_pref_IdleTimeout;
	BOOL m_pref_RemoveWallpaper;
	// adzm - 2010-07 - Disable more effects or font smoothing
	BOOL m_pref_RemoveEffects;
	BOOL m_pref_RemoveFontSmoothing;
	BOOL m_pref_RemoveAero;
	BOOL m_pref_EnableRemoteInputs;
	int m_pref_LockSettings;
	BOOL m_pref_DisableLocalInputs;
	BOOL m_pref_EnableJapInput;
	BOOL m_pref_clearconsole;

	// Modif sf@2002
	// [v1.0.2-jp2 fix]
	BOOL m_pref_SingleWindow;
	BOOL m_pref_EnableFileTransfer;
	BOOL m_pref_FTUserImpersonation;
	BOOL m_pref_EnableBlankMonitor;
	BOOL m_pref_BlankInputsOnly; //PGM
	int  m_pref_DefaultScale;
	BOOL m_pref_RequireMSLogon;
	BOOL m_pref_CaptureAlphaBlending;
	BOOL m_pref_BlackAlphaBlending;
//	BOOL m_pref_GammaGray;	// [v1.0.2-jp1 fix1]

	
	// Marscha@2004 - authSSP: added state of "New MS-Logon"
	BOOL m_pref_NewMSLogon;

	BOOL m_pref_UseDSMPlugin;
	char m_pref_szDSMPlugin[128];
	//adzm 2010-05-12 - dsmplugin config
	char m_pref_DSMPluginConfig[512];

    void LoadDSMPluginName(HKEY key, char *buffer);
	void SaveDSMPluginName(HKEY key, char *buffer); 
	vncSetAuth		m_vncauth;

	char m_pref_path111[500];
	char m_Tempfile[MAX_PATH];
	BOOL m_pref_Primary;
	BOOL m_pref_Secondary;

private:
	void InitPortSettings(HWND hwnd); // TightVNC 1.1.7


};

#endif // _WINVNC_VNCPROPERTIES
