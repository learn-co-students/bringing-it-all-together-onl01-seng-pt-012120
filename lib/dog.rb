class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PIMARY KEY,
      name TEXT,
      breed TEXT)
      SQL
      
      DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
      SQL
      
      DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  
  def self.new_from_db(row)
    hash_of_attributes = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    new_dog = self.new(hash_of_attributes)
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ? LIMIT 1 
    SQL
    
    DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
    end.first
  end 
  
  def self.find_or_create_by(name:name,breed:breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
    SQL
    dog = DB[:conn].execute(sql,name,breed)
      if !dog.empty?
        dog = dog[0]
        new_dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
      else
        new_dog = self.create(name:name,breed:breed)
    end
    new_dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1 
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
    end.first
  end 
  
  def self.create(hash_of_attributes)
    dog = Dog.new(hash_of_attributes)
    dog.save
    dog
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 

  
end 