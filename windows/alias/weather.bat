@echo off
REM equivalent of: alias weather='curl -sS v2.wttr.in | head -n-2'
curl -sS v2.wttr.in | head -n-2