@echo off
REM equivalent of: alias gitgf='git log --first-parent --graph --oneline --all'
git log --first-parent --graph --oneline --all %*