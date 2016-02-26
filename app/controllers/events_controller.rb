class EventsController < ApplicationController
	
	before_filter :checkLogin, :only=>[:attend, :new, :create, :edit, :update, :destroy]
	
	def index
		#@event_data=Event.all.map{|event|event.to_json_obj}.to_json  
		@event_banner= Event.where(:banner=>true)
    
		@events=Event.ransack(:title_or_organization_or_location_cont=>params[:custom_search])
            .result.order("end_time DESC")
		
		@past_events= Event.ransack(:title_or_organization_or_location_cont=>params[:custom_search]).result
					.where('end_time < ?', Time.now)
					.order('end_time DESC')
		
		@future_events= Event.ransack(:title_or_organization_or_location_cont=>params[:custom_search]).result
					.where('begin_time >= ?', (Date.today.to_date + 1.day))
					.order("begin_time DESC")
		
		@current_events= Event.ransack(:title_or_organization_or_location_cont=>params[:custom_search]).result
					.where('end_time >= ?', Time.now)
					.where('begin_time < ?', (Date.today.to_date + 1.day))
					.order("begin_time")
					#.where(:id => @past_events.select(:id))
					#.where.not(:id => @future_events.select(:id))
					
 
	  #@event_banner= Event.where(:banner=>true).map{|event|{ url:event.cover.url }}
	end
	
	def new
		@event=Event.new
		
		#@img = EventImage.new
	end
	def update
		@event=current_user.events.find(params[:id])
		@event.update_attributes(event_params)
		redirect_to event_url(@event)
	end
	def show_image
		
	end
	def create
		@event=Event.new(event_params)
		@event.user_id=current_user.id
		@event.banner=true
		@event.save!
		redirect_to event_url(@event)#:, :id=>@event.id
	end
	def destroy
		@event=current_user.events.find(params[:id])
		@event.destroy!
		redirect_to events_url
	end
	def show
		@event=Event.find(params[:id])
	end
	
	def edit
		@event=current_user.events.find(params[:id])

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
