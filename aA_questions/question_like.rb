require_relative 'questions'

class Question_Like

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map {|data| Question_Like.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id
    last_id = QuestionsDatabase.instance.last_insert_row_id
    if last_id.nil?
      last_id = 0
    end
    QuestionsDatabase.instance.execute(<<-SQL, last_id + 1, @question_id, @user_id)
      INSERT INTO
         question_likes (id, question_id, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_likes
    JOIN
      users ON question_likes.user_id = users.id
    WHERE
      question_id = ?
    SQL
    users.map {|user| User.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    number = QuestionsDatabase.instance.execute(<<-SQL,question_id)
    SELECT
      COUNT(*) AS 'number'
    FROM
      question_likes
    WHERE
      question_id = ?
    SQL
    number.first['number']
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_likes
    JOIN
      questions ON questions.id = question_likes.id
    WHERE
      user_id = ?
    SQL
    questions.map {|question| Question.new(question)}
  end

  def self.most_liked_questions(n)
    most_liked =  QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      question_likes
    JOIN
      questions ON question_id = questions.id
    GROUP BY
      question_id
    ORDER BY COUNT(*) DESC
    LIMIT ?
    SQL
    most_liked.map {|question| Question.new(question)}
  end
end
