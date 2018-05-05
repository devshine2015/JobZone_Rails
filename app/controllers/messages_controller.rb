class MessagesController < InheritedResources::Base
  before_action :authenticate_user!, if: Proc.new { |c| c.request.format != 'application/json' }
  before_action :authenticate_api_user!, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :get_job
  before_action :get_conversation

  private

  def get_job
    if current_user.has_role? User::ROLES[:employee]
      @job = Job.joins(:employee_jobs).where("jobs.id = ? AND employee_jobs.employee_id = ?", params[:job_id], current_user.id).first
    elsif current_user.has_role? User::ROLES[:employer]
      @job = current_user.jobs.joins(:employee_jobs).where(id: params[:job_id]).first
    end
    unless @job
      respond_to do |format|
        format.html { redirect_to request.referer || root_path }
        format.json { render json: {success: false, messsage: "Job not found!"}, status: 401 }
      end
    end
  end

  def get_conversation
    if current_user.has_role? User::ROLES[:employee]
      @conversation = current_user.candidate_conversations.where(id: params[:conversation_id], job: @job.id).first
    elsif current_user.has_role? User::ROLES[:employer]
      @conversation = current_user.employer_conversations.where(id: params[:conversation_id], job: @job.id).first
    end
  end

    def message_params
      params.require(:message).permit(:message_body, :message_type, :conversation_id, :user_id)
    end
end

