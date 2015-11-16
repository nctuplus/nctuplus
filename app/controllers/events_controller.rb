class EventsController < ApplicationController
	
	before_filter :checkLogin, :only=>[:new, :create, :edit, :update, :destroy]
	before_filter :checkOwner, :only=>[:update, :edit, :destroy]
	def index
		#@events=Event.all
	end
	
	def new
		@event=Event.new
		#@img = EventImage.new
	end
	def update
		@event=Event.find(params[:id])
		@event.update_attributes(event_params)
		redirect_to event_url(@event)
	end
	def show_image
		
	end
	def create
		
		@event=Event.new(event_params)
		@event.user_id=current_user.id
		#@event.content=
		@event.save!
		#@img = EventImage.new
		#@img.event_id=@event.id
		#@img.img=params[:img]
		#@img.save
		redirect_to event_url(@event)#:, :id=>@event.id
	end
	def destroy
		@event=Event.find(params[:id])
		@event.destroy!
		redirect_to events_url
	end
	def show
		@event=Event.find(params[:id])
	end
	
	def edit
		@event=Event.find(params[:id])
	end
	private

  def event_params
    params.require(:event).permit(:event_type, :title, :content, :begin_time, :end_time, :organization)
  end
	def img_params
    params.require(:event_image).permit(:img)
  end
end
