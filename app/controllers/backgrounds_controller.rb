class BackgroundsController < ApplicationController

  before_action :set_background, :only => [ :show, :edit, :update, :destroy]
  
  def index
    @backgrounds = Background.all
  end
  
  def create
    @background = Background.new(background_params)
    if @background.save 
      redirect_to backgrounds_path
    else
      redirect_to root_path
    end
  end

  def show
  end

  def destroy
    @background.destroy

    redirect_to backgrounds_path
  end
  
  def edit
  end
  
  def update
    @background.update(background_params)

    redirect_to backgrounds_path
  end


  private

    def set_background
      @background = Background.find(params[:id])
    end

    def background_params
      params.require(:background).permit(:image)  
    end
end
