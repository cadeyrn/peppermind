class ChallengesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource

  def index
    @challenges = Challenge.order_by([:created_at, :desc]).page params[:page]

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @challenges }
    end
  end

  def show
    @challenge = Challenge.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @challenge }
    end
  end

  def new
    @challenge = Challenge.new

    respond_to do |format|
      format.html
      format.json { render json: @challenge }
    end
  end

  def edit
    @challenge = Challenge.find(params[:id])
  end

  def create
    @challenge = current_user.challenges.build(params[:challenge])

    respond_to do |format|
      if @challenge.save
        track_activity @challenge
        session[:challenge_id] = @challenge.id
        format.html { redirect_to @challenge }
        format.json { render json: @challenge }
      else
        format.html { render action: 'new' }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @challenge = Challenge.find(params[:id])

    respond_to do |format|
      if @challenge.update_attributes(params[:challenge])
        track_activity @challenge
        format.html { redirect_to @challenge }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @challenge = Challenge.find(params[:id])
    @challenge.destroy

    respond_to do |format|
      format.html { redirect_to challenges_url }
      format.json { head :no_content }
    end
  end
end