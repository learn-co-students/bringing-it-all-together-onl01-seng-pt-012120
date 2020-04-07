class Dog

    attr_accessor :id, :name, :breed

    def initialize( id: nil , name: , breed:)
        @id = id
        @name = name
        @breed = breed
    end


    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end


    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end


    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?,?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id =DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end


    def self.create(hash)
        dog = self.new(name: nil, breed: nil)
        hash.each{|key,value| dog.send("#{key}=", value)}
        dog.save
        dog
    end


    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end


    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end


    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE
        name = ? and breed = ?
        SQL
        data = DB[:conn].execute(sql, name, breed).flatten
        if !data.empty?
            dog = self.find_by_id(data[0])
        else
            dog = self.create({name: data[1], breed: data [2]})
        end
        dog
    end


    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ?
        SQL
        data = DB[:conn].execute(sql, name).flatten
        self.new_from_db(data)
    end


    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id =?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)

    end
    
    
end