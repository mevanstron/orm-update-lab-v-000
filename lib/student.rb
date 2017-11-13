require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
      SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
        SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  #def update
    #sql = <<-SQL
      #UPDATE students SET name = ?, grade = ? WHERE id = ?
      #SQL

    #DB[:conn].execute(sql, self.name, self.grade, self.id)
  #end

  def self.create(name, grade)
    Student.new(name, grade).tap{|student| student.save}
  end

  def self.new_from_db(row)
    Student.create(row[0], row[1], row[2])
  end
end
