# AGENTS.md

## Project Overview

This project is a dotfiles management project using [chezmoi](https://www.chezmoi.io/). chezmoi manages dotfiles under source control and synchronizes configurations across multiple machines.

## Important Rules

Edit files within this project. Do not directly edit files in the target location (home directory).

chezmoi applies files from the source directory (this project) to the target directory (home directory).
Always make changes on the source side and apply them with `chezmoi apply`.

## Directory Structure

| Source (this project) | Target |
|-----------------------|--------|
| `dot_config/` | `~/.config/` |

## Testing Guidelines

No tests are required for this project.
