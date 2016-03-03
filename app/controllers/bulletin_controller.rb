class BulletinController < ApplicationController
    before_filter :checkTopManager
    
	def index
  		@q = Bulletin.search(params[:q])
		@bulletins = @q.result.order('created_at DESC')
	end

	def new
		@bulletin = Bulletin.new
	end

	def create
	  #@bulletin = Bulletin.new(bulletin_params)
	  @bulletin = current_user.bulletins.build(bulletin_params)
	  @bulletin.update_user = current_user.name
	  @bulletin.save

	  redirect_to bulletin_index_path
	end

	def show
	  @bulletin = Bulletin.find(params[:id])
	end

	def destroy
	  @bulletin = Bulletin.find(params[:id])
	  @bulletin.destroy

	  redirect_to bulletin_index_path
	end

	def edit
	  @bulletin = Bulletin.find(params[:id])
	end

	def update
	  @bulletin = Bulletin.find(params[:id])
	  @bulletin.update_user = current_user.name
	  @bulletin.update(bulletin_params)

	  redirect_to bulletin_index_path
	end

	private
	def bulletin_params
	  params.require(:bulletin).permit(:title, :article, :article_type, :user_id)
	end

end
