class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(dog)
        @name = dog[:name]
        @breed = dog[:breed]
        @id = dog[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL
            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(dog)
        dog = Dog.new(dog)
        dog.save
        dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?;
        SQL
        dog = DB[:conn].execute(sql, id)
        self.new_from_db(dog.first)
    end

    def self.find_or_create_by(dog_hash)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        dog = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])

        if !dog.empty?
            dog_data = dog[0]
            pp dog_data
            dog_return = Dog.new(name: dog_hash[0], breed: hash[1], id: dog_data[0])
        else
            dog_return = self.create(dog_hash)
        end
        dog_return
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?;
        SQL
        dog = DB[:conn].execute(sql, name)
        self.new_from_db(dog.first)
    end

    def update
        pp self
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, @name, @breed, @id)
    end
end