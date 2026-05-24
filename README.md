Rewrite of SCXPM on AngelScript with some improvements
To install the SCXPM plugin on your server, first download a clone of this repository

Copy the file scxpm_as.as to svencoop/scripts/plugins

Now, add the following entry to your default_plugins.txt located in svencoop:

	"plugin"
	{
		"name" "SCXPM"
		"script" "scxpm_as"
	}

The next step is to create the folders that will be used by SCXPM to store and save players data
Go to svencoop/scripts/plugins/store and make a new folder named scxpm_as

Get inside this new directory and create these additional folders:

data ~ Save data is stored here
logs ~ All events that occur within SCXPM will be logged here

Some code snippets taken from <a href="https://github.com/JulianR0/CLevels">CLevels</a></p>

Original Author : <a href="https://forums.alliedmods.net/member.php?u=18135">Silencer</a>

<a href="https://forums.alliedmods.net/showthread.php?t=44168">Original Mod</a>
