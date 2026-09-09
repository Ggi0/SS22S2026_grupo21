@echo off
echo Esperando a SQL Server...
timeout /t 30

sqlcmd -S localhost -U sa -P "Pass@WordSEMI2g21!" -C -N -d master -i "C:\Users\gios\Desktop\semi2lab\SS22S2026_grupo21\Practica2\BaseDatos\init.sql"

echo Script ejecutado correctamente.
pause
