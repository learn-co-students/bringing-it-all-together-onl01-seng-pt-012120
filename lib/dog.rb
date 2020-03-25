class Dog
  attr_reader(:id)
  attr_accessor(:name, :breed)
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save()
    return new_dog
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;"
    search_result = DB[:conn].execute(sql, name, breed).first
    if search_result
      return Dog.new_from_db(search_result)
    else
      new_dog = Dog.new(name: name, breed: breed)
      new_dog.save
      return new_dog
    end
  end
  
  def self.create_table()
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql);
  end
  
  def self.drop_table()
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql);
  end
  
  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    return new_dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
    found_dog = Dog.new_from_db(DB[:conn].execute(sql, id).first)
    return found_dog
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
    found_dog = Dog.new_from_db(DB[:conn].execute(sql, name).first)
    return found_dog
  end
  
  def save()
    if @id == nil
      sql = "INSERT INTO dogs (name, breed) VALUES (?,?);"
      DB[:conn].execute(sql, @name, @breed);
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      return self
    else
      self.update()
    end
  end
  
  def update()
    if @id != nil
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
      DB[:conn].execute(sql, @name, @breed, @id);
    else
      self.save()
    end
  end
end