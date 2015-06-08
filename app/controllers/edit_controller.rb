class EditController < ApplicationController
  def info
    #@user = User.find(params[:id])
    
    #user.update(name: params[:name], email: params[:email])
    
    #@user.update_attributes(name: params[:name], email: params[:email])
    #redirect_to :action => :about


    #@event=Event.find(params[:id])
    #@event.update_attributes(event_params)
    current_user.update_attributes
  end

  def about
    params[:email]
  end
end
