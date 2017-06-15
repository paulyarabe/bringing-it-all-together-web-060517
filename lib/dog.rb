require "pry"

class Dog

  attr_accessor :name, :breed, :id

  def initialize(dog_hash, id=nil)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = id
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    updated_row = DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(dog_hash)
    new_dog = self.new(dog_hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).flatten
    dog = self.new_from_db(row)
  end

  def self.new_from_db(row)
    dog = self.new({name:row[1], breed:row[2]})
    dog.id = row[0]
    dog
  end

  def self.find_or_create_by(dog_hash)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", dog_hash[:name], dog_hash[:breed])
    if !row.empty?
      dog_data = row[0]
      dog = self.new_from_db(dog_data)
    else
      dog = self.create(dog_hash)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def update
    updating_sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    updated_row = DB[:conn].execute(updating_sql, self.name, self.breed, self.id)
  end

end
