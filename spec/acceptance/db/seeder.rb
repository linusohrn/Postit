require "sqlite3"

class Seeder
  def initialize
    @db = SQLite3::Database.new("db.db")
    dropped()
    create()
    populate()
  end

  def dropped
    @db.execute("DROP TABLE IF EXISTS messages;")
    @db.execute("DROP TABLE IF EXISTS taggings;")
    @db.execute("DROP TABLE IF EXISTS tags;")
    @db.execute("DROP TABLE IF EXISTS users;")
  end

  def create
    @db.execute('CREATE TABLE "messages" (
            "id"	INTEGER,
            "content"	TEXT NOT NULL,
            "refrence_id"	INTEGER,
            "user_id"	INTEGER NOT NULL,
            PRIMARY KEY("id")
            )')

    @db.execute('CREATE TABLE "taggings" (
                "message_id"	INTEGER NOT NULL,
                "tag_id"	INTEGER NOT NULL
                )')

    @db.execute('CREATE TABLE "tags" (
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
  end

  def populate
    @db.execute("INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)", "admin", "$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", 1)
    @db.execute("INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)", "test1", "$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", 0)
    @db.execute("INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)", "test2", "$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", 0)
    @db.execute("INSERT INTO users (usn, pwd, privileges) VALUES (?,?,?)", "test3", "$2a$12$n28UR0Ml3BtcM5C7mgInG.GUUwrGCMyfrp336qXSFnmY.OSVXVL5O", 0)

    @db.execute("INSERT INTO messages (content, user_id) VALUES (?,?)", "Testing", 1)
    @db.execute("INSERT INTO messages (content, refrence_id, user_id) VALUES (?,?,?)", "Testing2", 1, 2)
    @db.execute("INSERT INTO messages (content, refrence_id, user_id) VALUES (?,?,?)", "Testing3", 1, 3)
    @db.execute("INSERT INTO messages (content, refrence_id, user_id) VALUES (?,?,?)", "Testing4", 2, 4)

    @db.execute("INSERT INTO tags (name) VALUES (?)", "Admin post")
    @db.execute("INSERT INTO tags (name) VALUES (?)", "Announcement")

    @db.execute("INSERT INTO tags (name) VALUES (?)", "Release notes")
    @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", 1, 1)
    @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", 2, 2)
    @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", 2, 3)
    @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", 3, 3)
    @db.execute("INSERT INTO taggings (message_id, tag_id) VALUES (?,?)", 4, 2)
  end
end

Seeder.new
