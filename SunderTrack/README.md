# SunderTrack

SunderTrack Addon
SunderTrack is a lightweight World of Warcraft addon designed to track Sunder Armor casts by warriors in your party or raid. It displays a sortable list of cast counts and includes a minimap button for quick access.

Features
Tracks and displays the number of Sunder Armor casts per warrior.

Dynamically updates as group members change.

Includes a movable and resizable UI frame.

Clickable minimap icon with tooltip and quick actions.

Slash commands to reset data or toggle movement.

UI Elements
Main Frame: Lists warrior names and their respective sunder counts.

Minimap Button: Toggles visibility and movement of the main frame.

Tooltip: Shows usage tips when hovering over the minimap icon.

Slash Commands
bash
Copy
Edit
/sunder         -- Toggle movable frame
/sunder reset   -- Reset all stored sunder counts
File Notes
sunder.tga: Custom icon used for the minimap button.

Font: Uses Fonts\\ARIALN.ttf at size 8 by default (can be changed in fontConfig).

Requirements
Only tracks warriors in your current group or raid.

Only counts successful casts of Sunder Armor (filtered via the combat log).