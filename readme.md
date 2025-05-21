# Configuration Zsh macOS - iTerm2

![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)

Fait avec amour ❤️

Ce dépôt contient un script d’installation complet et automatisé pour configurer un environnement Zsh moderne et puissant sur macOS, avec :
* Gestionnaire de paquets Homebrew
* Terminal iTerm2 (avec thème Dracula conseillé)
* Framework Oh My Zsh
* Prompt visuel Powerlevel10k
* Plugins Zsh essentiels : zsh-autocomplete, zsh-autosuggestions, zsh-syntax-highlighting
* Outils en ligne de commande modernes : exa, fzf, direnv, atuin
* Sécurité SSH/GPG avec prise en charge de YubiKey
* Alias pratiques et configurations optimisées

⸻

## Installation

```bash
git clone https://github.com/ClaraVnk/terminal.git && bash terminal/ZSHRC_By_Loutre.sh && source ~/.zshrc
```

⸻

## Personnalisation

### Powerlevel10k : 
Après installation, tu peux lancer ou relancer la configuration avec :

```bash
p10k configure
```

### Thème iTerm2 Dracula :
Le script ne peut pas importer automatiquement le thème. Tu dois :
	1.	Télécharger le fichier .itermcolors ici : https://draculatheme.com/iterm
	2.	Dans iTerm2, aller dans Preferences > Profiles > Colors > Color Presets > Import... et choisir le fichier téléchargé.
	3.	Appliquer le preset Dracula dans ce menu.

⸻

## Contributions

Les contributions sont les bienvenues !
N’hésite pas à ouvrir une issue ou faire une pull request.
N'oublie pas de laisser une étoile si tu trouves ce dépôt utile !

⸻

## Licence

MIT License © Loutre
