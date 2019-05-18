class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    current_user.change_keep_team(@team)
  end

  def new
    @team = Team.new
  end

  def edit
    redirect_to :back, notice: 'リーダー以外はチーム情報を編集出来ません。' if current_user != @team.owner
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'チーム更新に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'チーム削除に成功しました！'
  end

  def transfer_owner
    @team = Team.friendly.find(params[:team_id])
    @team.owner_id = Assign.find(params[:id]).user.id
    email = User.find(@team.owner_id).email
    TeamMailer.team_mail(email, @team).deliver
    if @team.save
      redirect_to @team, notice: 'チームリーダーを変更しました！'
    else
    end
  end

  def dashboard
    @team = current_user.keep_team
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id team_id]
  end

  def assign_params
    params[:email]
  end

  def email_reliable?(address)
    address.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end
end
