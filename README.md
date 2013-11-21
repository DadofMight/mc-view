mc-view
=======

Minecraft server tools for showing teams, player inventory and player stats on a website.

First, run the script "mc_data2json.pl" - this dumps the data from the NBT files into a more usable JSON format.

Next, run the "mc_create_teams.pl" file, which creates a file called "teams.json".  
This file is used by "teams.html" to display teams and players with summaries of XP.

The "player.html" file displays information from the JSON files for the player data and the player's "stats" file.

Relies on the JSON PERL library, available from CPAN and package management systems.

Also uses https://github.com/TheFrozenFire/PHP-NBT-Decoder-Encoder to convert NBT format
files into JSON.
