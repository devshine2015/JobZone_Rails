class JobsController < InheritedResources::Base
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :get_job, only: :apply
  after_action :create_employee_searches, only: :index

  def show
    @job = Job.find(params[:id])
    render json: {success: false, messages: "Job not found!"}, status: 401 unless @job
    current_user.job_views.create(job_id: @job.id)
    respond_to do |format|
      format.html { @job || root_path }
      format.json { render json: @job.as_json }
    end
  end

  def index
    @search = {key: params[:key], city: params[:city]}
    @jobs = Job.search(@search, params[:page])
    respond_to do |format|
      format.html { @jobs || root_path }
      format.json { render json: @jobs.as_json }
    end
  end

  def recommended_jobs
    skills = current_user.skills.pluck(:name)
    jobs = Job.recommended(skills, params[:page]).order('created_at DESC')
    render json: jobs.as_json
  end

  def applied_jobs
    employee_jobs = current_user.employee_jobs.page(params[:page]).order('created_at DESC')
    render json: employee_jobs.as_json
  end

  def searches
    render json: current_user.searches.as_json(only:[:id, :key, :city]).last(10)
  end

  def apply
    employee_job = current_user.employee_jobs.new(job_id: @job.id)
    if employee_job.save
      render json: {success: true, message: "Successfully applied"}, status: 200
    else
      render json: {success: false, errors: employee_job.errors}, status: 400
    end
  end

  private

    def job_params
      params.require(:job).permit(:title, :location, :status_id, :description, :user_id, :company_id)
    end

    def get_job
      @job = Job.find(params[:job_id])
      render json: {success: false, messages: "Job not found!"}, status: 401 unless @job
    end

    def create_employee_searches
      current_user.searches.create(@search) if @search[:key].present?
    end
end

