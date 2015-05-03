# RPG Maker 2003 RTP Converter

It's great that Enterbrain recently released an official version of RPG Maker 2003.  But over the course of 12 years, a lot of games have been made with the unofficial English translation, and Enterbrain's version changed the names of a lot of files in the RTP.  This means that anyone who wants to use the new version, whose project uses RTP resources, has to go through and update everything, or their project will break.  Obviously, for a large project, this can be a prohibitively difficult task.  File references can be hidden in all sorts of places, including inside event scripts!

This tool was created to help with that transition.  It reads the project file formats, examines file references throughout the project, and when it finds matches to the unofficial translation's RTP filenames, it automatically updates them and saves your file.

# WARNING:

This program rewrites your project files, according to a reverse-engineered specification of RPG Maker 2003's file format.  **Its file formats may contain mistakes!**  When running, it will copy all of your data files to a new `Backup` folder.  If anything goes wrong, you can recover your originals from this folder.  Even so, use this tool at your own risk.  The author is not responsible if you use this and it somehow trashes your project!

I've tested this with hex editors to make sure, as far as I can tell, that it will not trash your project, but nothing's certain.

If anything does go wrong, the tool also drops a list of resources it found and changed in your project folder, so after you restore from backups, you can use the list to replace things manually and not have to hunt for everything yourself.

# How to use:

 - Run the program
 - Click the `...` button
 - Navigate to your project's database (RPG_RT.ldb) and select it
 - Click the `Convert` button
 - Wait a few moments while it processes your project.
 - When the report dialog comes up, congratulations!  Your project is ready to run on the official version!  (Hopefully. *Read the warning section, above!*)
