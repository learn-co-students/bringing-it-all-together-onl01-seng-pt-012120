class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:nil, breed:nil, id:nil)
     @name = name
     @breed = breed
     @id = id
  end

  def self.create_table
    sql = <<-SQL
       CREATE TABLE IF NOT EXISTS dogs(
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
       )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
     sql = <<-SQL
       DROP TABLE IF EXISTS dogs
     SQL
     DB[:conn].execute(sql)
  end

  def save
    sql = 'INSERT INTO dogs(name, breed) VALUES(?,?)'
     DB[:conn].execute(sql, self.name, self.breed)
    sql_2 = 'SELECT id FROM dogs WHERE name = ?'
     self.id = DB[:conn].execute(sql_2, self.name)[0][0]
    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.new_from_db(row)
    dog = self.new
     dog.id = row[0]
     dog.name = row[1]
     dog.breed = row[2]
    dog
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
     dog = DB[:conn].execute(sql, id)[0]
     create_dog = Dog.new_from_db(dog)
    create_dog
  end

  def self.find_or_create_by(hash)
    if !hash.include?(:id)
      Dog.create(hash)

  end


end
