class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(attributes)
    attributes.each do |key, value| 
      self.send(("#{key}="), value)
    end
    self.id ||= nil
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
  
  DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update
    else
    sql = "INSERT INTO dogs(name, breed) VALUES (?, ?);"
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
  end
  
  def self.create(attributes_hash)
    new_entry = Dog.new(attributes_hash)
    new_entry.save
  end
  
  def self.new_from_db(values)
    attributes = {
      :id => values[0],
      :name => values[1],
      :breed => values[2]
    }
    self.new(attributes)
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    result = DB[:conn].execute(sql,id)[0]
    attributes = {
      :id => result[0],
      :name => result[1],
      :breed => result[2]
    }
    Dog.new(attributes)
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_attributes = dog[0]
      dog = new_from_db(dog_attributes)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    result = DB[:conn].execute(sql, name)
    self.new_from_db(result[0])
  end
    
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
end
