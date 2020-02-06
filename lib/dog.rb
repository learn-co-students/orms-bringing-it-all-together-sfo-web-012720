class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
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
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, @name, @breed, @id)
    end

    def save
        if @id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL
            DB[:conn].execute(sql, @name, @breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
        new_dog = Dog.new(name: hash[:name],breed: hash[:breed])
        new_dog.save
    end

    def self.new_from_db(array)
        id = array[0]
        name = array[1]
        breed = array[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        search = DB[:conn].execute(sql, id)[0].flatten
        Dog.new(id: search[0],name: search[1],breed: search[2])
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        search = DB[:conn].execute(sql, name)[0].flatten
        Dog.new(id: search[0], name: search[1], breed: search[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
        SQL
         dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_atts = dog[0]
            dog = Dog.new(id: dog_atts[0], name: dog_atts[1], breed: dog_atts[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end
end