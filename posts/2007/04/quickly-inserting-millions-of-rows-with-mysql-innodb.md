---
Title: Quickly inserting millions of rows with MySQL/InnoDB
Author: Sami Samhuri
Date: 26th April, 2007
Timestamp: 2007-04-26T07:06:00-07:00
Tags: linux, mysql
---

The absolute first thing you should do is check your MySQL configuration to make sure it’s sane for the system you’re using. I kept getting a ‘The table is too large’ error on my Gentoo box after inserting several million rows because the default config limits the InnoDB tablespace size to 128M. It was also tuned for a box with as little as 64M of RAM. That’s cool for a small VPS or your old Pentium in the corner collecting dust. For a modern server, workstation, or even notebook with gigs of RAM you’ll likely want to make some changes.

### Tweaking my.cnf ###

Here are the relevant settings you can tweak in order to work with large datasets efficiently. These are set in your <strong>my.cnf</strong> file, which varies in location.

On Gentoo it resides at <strong>/etc/mysql/my.cnf</strong>.

When MySQL 5.x is installed via DarwinPorts on Mac OS X you need to copy one of the defaults from <strong>/opt/local/share/mysql5/mysql/</strong> to <strong>/opt/local/etc/mysql5/my.cnf</strong> and then modify it accordingly.

If you use another system you’re on your own. If you can’t figure it out, please put down the text editor and leave the poor config file alone! Jokes aside this really is not difficult if you’re used to configuring *nix programs.

### innodb_buffer_pool_size ###

This determines how much memory MySQL uses for table indexes and data. You can set it as low as 8-10M, or high as 50-80% of your memory on a dedicated MySQL server. I have RAM to burn[1] in my workstation so I set this to 200M, 20% of my 1GB.

[1] I run Fluxbox on Gentoo, I use 200-300M of my 1GB on average and with 200M for MySQL 409M are in use at this moment. Gotta love those lightweight window managers!

### innodb_additional_mem_pool_size ###

According to [a post on a MySQL mailing list](http://lists.mysql.com/mysql/129247), modern OSs have fast enough mallocs and this variable has little effect on performance. I set mine to 16M before reading that post, so I’ll just leave it at that.

### innodb_data_file_path ###

On Gentoo this one bit me right in the ass, and I mentioned it above. It specifies how large the files used to store your data can be, and how many of them there are. The default setting is almost sane: <code>ibdata1:10M:autoextend:<b>max:128M</b></code>. Limiting the total size to 128M caused my test to fail after inserting several million rows.

Simply removing <code>max:128M</code> solves the problem. The resulting setting tells the InnoDB engine to use one file, named <b>ibdata1</b> which is initially 10M in size and grows as required.

### innodb_log_file_size ###

The default Gentoo config says they (whoever they are) keep this at 25% of <b>innodb_buffer_pool_size</b> so I did just that. 50M in my case.

### innodb_log_buffer_size ###

Again I only went as far as the Gentoo config to learn about this setting. They had it at 8M and recommend increasing it if you have large transactions. I can’t think of any particularly large transactions I currently use but I doubled it to 16M anyway.

### Save my.cnf and restart mysqld ###

That’s it for the MySQL config. Restart mysqld however you do that on your platform. <code>sudo /etc/init.d/mysql restart</code> should look familiar to many *nix users.

Now you should be able to insert dozens and indeed hundreds of millions of rows into your InnoDB tables. Sadly this brought little performance gains to the table. MySQL wraps single queries in implicit transactions. Wrapping everything in a transaction may work, but inevitably something will go wrong and you may want the ability to resume inserting the rows instead of starting all over.

The solution now is to execute <code>SET AUTOCOMMIT=0</code> before inserting the data, and then issuing a <code>COMMIT</code> when you’re done. With all that in place I’m inserting 14,000,000 rows into both MyISAM and InnoDB tables in 30 minutes. MyISAM is still ~ 2 min faster, but as I said earlier this is adequate for now. Prior to all this it took several <b>hours</b> to insert 14,000,000 rows so I am happy.

Now you can enjoy the speed MyISAM is known for with your InnoDB tables. Consider the data integrity a bonus! ;-)

