class QuestionsController < ApplicationController
  before_action :redirect_if_student, :only => ['new', 'create', 'destroy']

  def index
    @course = Course.find(params[:course_id])    
    @questions = @course.questions.order(:type).where.not(:type => "AttendanceQuestion")
    if !current_user.admin?
        render 'student_index'
    end
  end
  
  def show
    @course = Course.find(params[:course_id])
    if params[:action] === :by_date
      render 'questions_by_date', locals: {questionsArr: :id} and return
    else
      @question = Question.find(params[:id])
      render 'show_question' and return
    end
  end

  def new
    @course = Course.find(params[:course_id])    
    @q = Question.new
  end

  def create
    @course = Course.find(params[:course_id])    
    @q = @course.questions.new(create_params)
    @q.qcontent = params[:options]
    @q.image.attach(create_params[:image])
    @q.save
    if @q.persisted?
      flash[:notice] = "#{@q.qname} created"
      redirect_to course_questions_path(@course) and return
    else
      msg = @q.errors.full_messages.join('; ')
      flash[:warning] = "No question created: #{msg}"
      redirect_to new_course_question_path(@course) and return
    end
  end

  def destroy
    c = Course.find(params[:course_id])    
    q = c.questions.find(params[:id])
    q.destroy
    flash[:notice] = "#{q.qname} destroyed"
    redirect_to course_questions_path(c)
  end
  
  def all
    render 'all_questions' and return
  end

private
  def create_params
    p = params.require(:question).permit(:qname, :type, :qcontent, :content_type, :answer, :breakout, :image, :options, :correctanswer)
    # reform qcontent into an array
    if p[:qcontent]
      p[:qcontent] = p[:qcontent].split.collect { |s| s.strip }
    end
    # p[:answer] = p[:correctanswer]
    p
  end
end
