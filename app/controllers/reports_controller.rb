class ReportsController < ApplicationController
  before_action :authenticate_user

  def create
    @report = Report.new(report_params.merge(reporter: current_user))

    if @report.save
      notify_admins(@report)
      render json: { message: 'Жалоба успешно отправлена' }, status: :ok
    else
      render json: { error: @report.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:report).permit(:reportable_type, :reportable_id, :reason, :comment)
  end

  def notify_admins(report)
    admins = User.where(role: [1, 2])
    admins.each do |admin|
      current_user.create_notification(admin, current_user, "Новая жалоба на #{report.reportable_type}", report)
    end
  end
end
