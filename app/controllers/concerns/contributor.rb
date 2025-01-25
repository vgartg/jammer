module Contributor
  extend ActiveSupport::Concern

  included do
    before_action :set_jam, only: [:setting_judges]
  end

  def add_contributor_logic(jam_id, username_or_email)
    user = User.find_by("email_confirmed = true AND name = ? OR email = ?", username_or_email, username_or_email)

    return { success: false, message: t('jams.setting_judges.no_user') } if user.nil?

    existing_contributor = JamContributor.find_by(jam_id: jam_id, user_id: user.id)

    if existing_contributor.present?
      { success: false, message: t('jams.setting_judges.user_exist') }
    else
      jcb = JamContributor.new(
        jam_id: jam_id,
        user_id: user.id,
        status: true,
        is_host: false,
        is_admin: false,
        is_judge: false
      )
      if jcb.save
        { success: true, message: t('jams.setting_judges.success_added') }
      else
        { success: false, message: t('jams.setting_judges.error') }
      end
    end
  end

  def delete_contributor_logic(jam_id, user_id)
    contributor = JamContributor.find_by(jam_id: jam_id, user_id: user_id)
    if contributor&.destroy
      { success: true, message: t('jams.setting_judges.success_delete') }
    else
      { success: false, message: t('jams.setting_judges.error') }
    end
  end

  private

  def set_jam
    @jam = current_user.jams.find_by_id(params[:id])
  end
end