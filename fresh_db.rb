require 'sqlite3'

class Creator

    def initialize

        @db = SQLite3::Database.new('db/db.db')

        @db.execute('DROP TABLE IF EXISTS message;')
        @db.execute('DROP TABLE IF EXISTS message_tag;')
        @db.execute('DROP TABLE IF EXISTS tag;')
        @db.execute('DROP TABLE IF EXISTS users;')

        @db.execute('CREATE TABLE "message" (
            "id"	INTEGER,
            "contect"	TEXT NOT NULL,
            "refrence_id"	INTEGER,
            "user_id"	INTEGER NOT NULL,
            PRIMARY KEY("id")
        )')

        @db.execute('CREATE TABLE "message_tag" (
            "message_id"	INTEGER NOT NULL UNIQUE,
            "tag_id"	INTEGER NOT NULL
        )')

        @db.execute('CREATE TABLE "tag" (
            "id"	INTEGER,
            "name"	TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id")
        )')

        @db.execute('CREATE TABLE "users" (
            "id"	INTEGER,
            "usn"	TEXT NOT NULL UNIQUE,
            "pwd"	TEXT NOT NULL,
            "privileges"	INTEGER NOT NULL,
            PRIMARY KEY("id")
        )')

        @db.execute('INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)', "admin", "$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", 1)

    end

end

Creator.new