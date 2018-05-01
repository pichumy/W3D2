require_relative 'database'
require_relative 'questions'
require_relative 'reply'


class User

  attr_reader :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map {|data| User.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_name(fname, lname)
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    name.map {|name| User.new(name)}
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end


  def followed_questions
    Question_Follow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Question_Like.liked_questions_for_user_id(@id)
  end
  # have a user id
  def average_karma
    counts = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      (CAST(COUNT(DISTINCT(questions.id)) AS FLOAT)/ CAST(COUNT(question_likes.question_id) AS FLOAT)) AS average_karma
    FROM
      questions
    LEFT JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      author_id = ?
    SQL
    counts.first['average_karma']
  end

end
