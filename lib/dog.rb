class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end 
  
  def self.create_table
    sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
   sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end 
  
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
 
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      
      self
    end
  end
  
  def self.create(hash_of_attributes)
      dog = self.new(hash_of_attributes) #taking in a hash of attributes
      dog.save
      dog
  end
  
  def self.new_from_db(row)
    dogs_hash = {
    :id => row[0],
    :name => row[1],
    :breed => row[2]
    }
    self.new(dogs_hash)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL

      dog = DB[:conn].execute(sql, name, breed).first

      if dog
        new_dog = self.new_from_db(dog)
      else
        new_dog = self.create({:name => name, :breed => breed})
      end
      new_dog
  end
  
   def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
   def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  
end 