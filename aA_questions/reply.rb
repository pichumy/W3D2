require_relative 'database'
require_relative 'users'


class Reply

  attr_reader :question_id, :parent_id, :user_id, :body

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map {|data| Reply.new(data)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @body)
      INSERT INTO
        replies (question_id, parent_id, user_id, body)
      VALUES
        (?,?,?,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_user_id(user_id)
    user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    user.map {|user| User.new(user)}
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    reply.map {|reply| Reply.new(reply)}
  end

  def author
    user = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(user.first)
  end

  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        title, body, author_id
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(question.first)
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, @parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    reply.map {|reply| Reply.new(reply)}
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    reply.map {|reply| Reply.new(reply)}

  end
end
