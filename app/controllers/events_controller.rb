class EventsController < ApplicationController
	
	before_filter :checkLogin, :only=>[:attend, :new, :create, :edit, :update, :destroy]
	before_filter :checkOwner, :only=>[:update, :edit, :destroy]
	def index
		#@event_data=Event.all.map{|event|event.to_json_obj}.to_json
	  @events=Event.all
	  @event_banner= Event.where(:banner=>true)
	  #@event_banner= Event.where(:banner=>true).map{|event|{ url:event.cover.url }}
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
		@event.save!
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
	
	def attend
		attends=current_user.attendances.where(:event_id=>params[:event_id])
		if attends.empty?
			current_user.attendances.create(:event_id=>params[:event_id])
		else
			attends.destroy_all
		end
		
		respond_to do |format|
			#format.html{render :layout=>false,:nothing =>true }
			if attends.empty?
				format.json{render json: {:add=>params[:add], :state => "delete"} }
			else
				format.json{render json: {:add=>params[:add], :state => "new"} }
			end
		end
		
	end
	
	private

  def event_params
    params.require(:event).permit(:event_type, :title, :organization, :location, :lat_long, :url, :content, :begin_time, :end_time, :cover)
  end

end
