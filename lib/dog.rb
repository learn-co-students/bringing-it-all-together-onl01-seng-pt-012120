
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
    if self.id
      self.update
    else
    sql = 'INSERT INTO dogs(name, breed) VALUES(?,?)'
     insert_dog = DB[:conn].execute(sql, self.name, self.breed)#
    sql_2 = "SELECT last_insert_rowid() FROM dogs"
     self.id = DB[:conn].execute(sql_2)[0][0]
   end
    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.new_from_db(array)
    dog = self.new
     dog.id = array[0]
     dog.name = array[1]
     dog.breed = array[2]
    dog
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
     dog = DB[:conn].execute(sql, id)[0]
     create_dog = Dog.new_from_db(dog)
    create_dog
  end

    def self.find_or_create_by(hash)
       sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
       dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
       if dog.empty?
         created_dog = Dog.create(hash)
       else
         find_dog = Dog.find_by_id(dog[0][0])
      end

    end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ?'
    dog = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(dog)
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
