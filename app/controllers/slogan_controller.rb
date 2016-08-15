class SloganController < ApplicationController
    before_filter :checkTopManager
    before_action :set_slogan, :only => [ :show, :edit, :update, :destroy]

    def index
        @slogan = Slogan.all
    end

    def new
        @slogan = Slogan.new
    end

    def create
        @slogan = Slogan.new(slogan_params)
        @slogan.save

        redirect_to slogan_index_path
    end

    def show
    end

    def destroy
        @slogan.destroy

        redirect_to slogan_index_path
    end

    def edit
    end

    def update
        @slogan.update(slogan_params)

        redirect_to slogan_index_path
    end

    private
    def slogan_params
        params.require(:slogan).permit(:description)
    end

    def set_slogan
        @slogan = Slogan.find(params[:id])
    end
end
