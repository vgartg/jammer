class JamCriterionPicksController < ApplicationController
  before_action :authenticate_user
  before_action :set_jam

  def create
    authorize_vote_like!

    criterion = @jam.jam_criteria.find(params[:jam_criterion_id])
    game      = Game.find(params[:game_id])

    channel = params[:channel].to_s
    channel = "jury" unless %w[jury audience].include?(channel)

    pick = JamCriterionPick.find_or_initialize_by(
      jam_id: @jam.id,
      jam_criterion_id: criterion.id,
      voter_id: current_user.id,
      channel: channel
    )

    pick.game_id = game.id
    pick.save!

    flash.now[:success] = "Выбор сохранён"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "jam_criterion_#{criterion.id}_pick_block",
            partial: "jam_criterion_picks/pick_block",
            locals: { jam: @jam, game: game, criterion: criterion, current_pick: pick, vote_type: channel }
          ),
          turbo_stream.replace("flash_notices", partial: "helpers/flash_notices")
        ]
      end

      format.html { redirect_to game_profile_path(game, jam_id: @jam.id), status: :see_other }
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:failure] = e.record.errors.full_messages
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_notices", partial: "helpers/flash_notices") }
      format.html { redirect_back fallback_location: jam_profile_path(@jam), status: :see_other }
    end
  end

  def destroy
    authorize_vote_like!
    pick = JamCriterionPick.find(params[:id])
    criterion = @jam.jam_criteria.find(pick.jam_criterion_id)

    pick.destroy!
    flash.now[:success] = "Выбор сброшен"

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "jam_criterion_#{criterion.id}_pick_block",
            partial: "jam_criterion_picks/pick_block",
            locals: { jam: @jam, game: Game.find(params[:game_id]), criterion: criterion, current_pick: nil, vote_type: pick.channel }
          ),
          turbo_stream.replace("flash_notices", partial: "helpers/flash_notices")
        ]
      end

      format.html { redirect_back fallback_location: jam_profile_path(@jam), status: :see_other }
    end
  end

  private

  def set_jam
    @jam = Jam.find(params[:jam_id])
  end

  # Можно использовать твою же authorize_vote! логику (voting_open? + rights)
  def authorize_vote_like!
    unless @jam.voting_open?
      flash[:failure] = "Голосование сейчас закрыто"
      redirect_to jam_profile_path(@jam) and return
    end

    setting = @jam.rating_setting
    unless setting.jury_enabled || setting.audience_enabled
      flash[:failure] = "Голосование отключено"
      redirect_to jam_profile_path(@jam) and return
    end

    unless @jam.can_vote_as_jury?(current_user) || @jam.can_vote_as_audience?(current_user)
      flash[:failure] = "Недостаточно прав для голосования"
      redirect_to jam_profile_path(@jam) and return
    end
  end
end