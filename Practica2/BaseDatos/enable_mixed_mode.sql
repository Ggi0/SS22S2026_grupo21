-- Cambiar a modo mixto (SQL + Windows)
EXEC xp_instance_regwrite
    N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer',
    N'LoginMode',
    REG_DWORD,
    2;
GO

-- Habilitar login sa y asignar contraseña
ALTER LOGIN sa ENABLE;
ALTER LOGIN sa WITH PASSWORD = 'Pass@WordSEMI2g21!';
GO
