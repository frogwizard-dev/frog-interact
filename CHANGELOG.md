# FrogInteract

## 0.1.1

- No longer follows every soft target change all session; /fi status reads it when asked.
- Shared code (FrogLib 1.12.0): see its notes for the rest of what's fixed.

## 0.1.0

- First version: interact key enhancements. The game already picks out what's in front of you for its Interact key (an NPC, a chest, ore, a herb, a mailbox, a corpse to loot, a fishing bobber); FrogInteract makes that work with a mouse and keyboard and marks it: an icon over NPCs and objects (and, if you like, the less important ones), its name above it, its tooltip, and a soft sound when something comes into reach.
- How far and where it looks: up to 40 yards, and in a narrow cone, a wide one or all round you.
- Works alongside FrogFish: its fishing settings take over while a pole's on, and these come back when it comes off. Turned off (`/fi off`) or removed, the game's own settings are back as they were, even after a crash.
- `/fi status` says what's picked out now.
