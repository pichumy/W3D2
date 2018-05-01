require_relative 'database'
require_relative 'questions'


class Question_Follow

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map {|data| Question_Follow.new(data)}
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
         question_follows (id, question_id, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL,question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
      JOIN users ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL
    users.map {|user| User.new(user)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
      JOIN questions ON question_follows.question_id = questions.id
      WHERE
        user_id = ?
    SQL
    questions.map {|question| Question.new(question)}
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDatabase.instance.execute(<<-SQL,n)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY
        question_follows.question_id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    most_followed.map { |question| Question.new(question) }
  end

end
