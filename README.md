SweetieBot
==========

Cutie Mark Acquisition Program v1.01, or SweetieBot, for convienience.

A chatbot based off WaveHack's PinkieBot (https://bitbucket.org/WaveHack/pinkiebot). DBAD still applies (http://philsturgeon.co.uk/code/dbad-license).<br>
Doesn't have slap or cupcakes or oatmeal or rfc or rss or synchtube or urbandict modules. Instead, it haves shutdown module, which prints a shutdown message like the OpenVMS one. May add real shutdown function there some day.<br>

There are that cute authorisation levels.<br>
-1 - Not authenticated<br>
0-5 - User levels<br>
6 - Readonly administration (module status, user listing)<br>
7 - Module administration (loading, unloading)<br>
8 - User management and bot updating<br>
9 - Arbitairy Perl/Shell commands<br>

Modules and commands:<br>

**Admin**<br>
Default administration module for PinkieBot. Do not unload it unless you want to restart the whole PinkieBot process. Without the Admin module loaded, nobody can control the bot.<br>
If you have the Auth module loaded, almost all of these Admin commands require you to be logged in in the Auth module. The 'eval' and 'cmd' functions are disabled if the Auth module isn't loaded to prevent abuse.<br>

Commands(levels):<br>
*list available (6)* - Lists all available modules. More specifically: modules/*.pm files.<br>
*list loaded (6)* - Lists all loaded modules. Loaded modules are not neccessarily active.<br>
*list active (6)* - Lists all modules who are both loaded and active.<br>
*load (module) (arguments) (7)* - Loads a module with optional arguments.<br>
*load (module[,module2[,module3]]) (7)* - Loads multiple modules, but arguments are not supported.<br>
*unload (module[,module2[,module3]]) (7)* - Unloads one or multiple modules.<br>
*reload (module) (arguments) (7)* - Reloads a module with optional arguments.<br>
*reload (module[,module2[,module3]]) (7)* - Reoads multiple modules, but arguments are not supported.<br>
*enable (module) (7)* - Enables a loaded and inactive module.<br>
*disable (module) (7)* - Disables a loaded and active module.<br>
*(module) loaded (6)* - Checks whether a module is loaded.<br>
*(module) active (6)* - Checks whether a module is active.<br>
*update (8)* - Updates the bot's code from the repository. (DON'T use it, since it hasn't been modified yet, so it points at original repository)<br>
*eval (cmd) (9)* - Eval's some Perl code.<br>
*cmd (cmd) (9)* - Runs arbitrairy shell code.<br>
*!sweetiebot* or *sweetiebot?* - Prints some info about the bot.<br>
*chanjoin (channel) (7)* - Joins a channel.<br>
*chanpart (channel) (7)* - Parts (leaves) a channel.<br>

**Auth**<br>
Without the Auth module, anyone has access to the Admin functions (except for 'eval' and 'cmd'). Highly recommended to keep active at all times, unless you're testing/developing in a secluded channel.<br>
Logins are based on raw nick, which is nickname!username@vhost. Be cautious with shared (v)hosts, as login sessions can be stolen this way. Logins persist after chanpart/quit.<br>

Commands(levels):<br>
*login (username) (password)* - Logs you in.<br>
*logout (0)* - Logs you out.<br>
*whoami (0)* - Prints your raw nick and authorization level.<br>
*list users (8)* - Prints a list of current logged in usernames.<br>
*list usernames (8)* - Prints a list of available usernames+levels from the database.<br>
*adduser (username) (password) [level]] (8)* - Adds a user to the database. Level is 0 if omitted.<br>
*deluser (username) (8)* - Removes a user from the database.<br>
*changelevel (username) (level) (8)* - Changes authorization level of selected user. Can only be your own authorization level or lower (not higher).<br>

**Google**<br>
Googles for a term and returns the topmost result.<br>
Commands:<br>
*!g (query)* - Googles web pages with said query and returns the first result.<br>
*!gi (query)* - Googles images with said query and returns the first result.<br>

**Log**<br>
Records all raw activity in the MySQL database in the 'activity' table.<br>

**MLFW**<br>
My Little Face When module.<br>
Commands:<br>
*!mlfw (tag1)[,tag2[,tag3[...]]]* - Searches MLFW for the tags and returns one random result.<br>

**Quoter**<br>
Module to search and replace quotes people said in the same IRC channel.<br>
Commands:<br>
*!s (search) (replace)* - Searches for the latest line where $search is in, and replaces the first occurrence with $replace.<br>
*!ss (search) (replace)* - Searches for the latest line where $search is in, and replaces all occurrences with $replace.<br>
*!sd (word1) (word2)* - Searches for the latest line where both $word1 and $word2 are in and switches them around.<br>

**Seen**<br>
Reports when and where a person has been last seen by the bot.<br>
Usage:<br>
*!seen (name)* - Reports when the person was last seen by the bot.<br>

**Shutdown**<br>
Prints the OpenVMS shutdown procedure, as seen on Ola's AlphaStation 255/233.<br>
Usage:<br>
*!shutdown* - prints the shutdown procedure (contained in shutdown.txt)<br>

**Social**<br>
Some basic responses when interacting with the bot. Namely greeting the bot and some friendly emotes (e.g. hugs, pats). See the module code for full list.<br>

**Title**<br>
Posts the title when an URL is pasted in the chat. Does not work on certain URLs and on https links, however.<br>

**Watch**<br>
Keeps an eye on when somebody is back. When a person is back (when they say or emote in a channel), the bot addresses the watcher that the watched person has returned.<br>
Usage:<br>
*!watch (name)* - Watches a person.<br>

**Wikipedia**<br>
Searches for an article on Wikipedia.org and prints the first ~300 characters of the summary, with a link to the full article.<br>
Usage:<br>
*!w (page)* or *!wiki (page)* - Searches for page on Wikipedia.org.