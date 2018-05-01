require_relative 'database'
require_relative 'users'


class Question

  attr_reader :title, :body, :author_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map {|data| Question.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?,?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    question.map {|question| Question.new(question)}
  end

  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(user.first)
  end

  def replies
    reply = Reply.find_by_question_id(@id)
  end

  def followers
    Question_Follow.followers_for_question_id(@id)
  end

  def most_followed(n)
    Question_Follow.most_followed_questions(n)
  end


  def likers
    Question_Like.likers_for_question_id(@id)
  end

  def num_likes
    Question_Like.num_likes_for_question_id(@id)
  end

  def most_liked(n)
    Question_Like.most_liked_questions(n)
  end
end
