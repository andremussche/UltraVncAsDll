Error: NASM not found
Fix  : copy all exe etc "c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\"

Error: 1>c:\projecten_it\3rd party tools\ultravnc_src\winvnc\winvnc\hidedesktop.cpp(42): fatal error C1083: Cannot open include file: 'atlbase.h': No such file or directory
Fix  : add some dirs to project -> Properties -> Configuration -> VC++ Directories -> Include Directories:
c:\Projecten_IT\3rd Party Tools\Microsoft Platform SDK for Windows Server 2003 R2\Include\atl
c:\Projecten_IT\3rd Party Tools\Microsoft Platform SDK for Windows Server 2003 R2\Include\mfc

Error: 1>ldapauthnt4.rc(10): fatal error RC1015: cannot open include file 'afxres.h'.
Fix  : add some dirs to project -> Properties -> Configuration -> VC++ Directories -> Include Directories:
c:\Projecten_IT\3rd Party Tools\Microsoft Platform SDK for Windows Server 2003 R2\Include\mfc\
