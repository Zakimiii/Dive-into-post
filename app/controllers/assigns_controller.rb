class AssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_assign, only: [:destroy]

  def create
    team = Team.friendly.find(params[:team_id])
    user = email_reliable?(assign_params) ? User.find_or_create_by_email(assign_params) : nil
    if user
      team.invite_member(user)
      redirect_to team_url(team), notice: 'アサインしました！'
    else
      redirect_to team_url(team), notice: 'アサインに失敗しました！'
    end
  end

  def destroy
    if @assign.destroy
      redirect_to team_url(params[:team_id])#, notice: destroy_message
    else
    end
    # destroy_message = assign_destroy(assign, assign.user)
  end

  private

  def set_assign
    @assign = Assign.find(params[:id])
  end

  def assign_params
    params[:email]
  end

  def assign_destroy(assign, assigned_user)

    # if assigned_user == assign.team.owner
    #   'リーダーは削除できません。'
    # elsif assigned_user != current_user && current_user != assign.team.owner
    #   'リーダー以外は、他のメンバーを削除出来ません。'
    # elsif Assign.where(user_id: assigned_user.id).count == 1
    #   'このユーザーはこのチームにしか所属していないため、削除できません。'
    # elsif assign.destroy
    #   'メンバーを削除しました。'
    # else
    #   'なんらかの原因で、削除できませんでした。'
    # end
  end

  def email_reliable?(address)
    address.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end

  # def set_next_team(assign, assigned_user)
  #   another_team = Assign.find_by(user_id: assigned_user.id).team
  #   change_keep_team(assigned_user, another_team) if assigned_user.keep_team_id == assign.team_id
  # end
end
