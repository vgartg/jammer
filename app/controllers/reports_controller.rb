class ReportsController < ApplicationController
  before_action :authenticate_user

  def create
    @report = Report.new(report_params.merge(reporter: current_user))

    if @report.save
      notify_admins(@report)
      render json: { message: t('controllers.reports.sent') }, status: :ok
    else
      render json: { error: @report.errors[:reportable_id].first || @report.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(:reportable_type, :reportable_id, :reason, :comment)
  end

  def notify_admins(report)
    User.notify_staff(current_user, 'new_report', report)
  end
end
