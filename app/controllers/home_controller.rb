class HomeController < ApplicationController

  def index
    if !session[:user_id].blank?
      render :template => "home/home"
    else
      render :template => "home/index" and return false
    end
  end

  def common_logout
    session[:user_id] = nil
  end

  def process_register
    username = params[:username]
    password = params[:password]
    email = params[:email]
    name = params[:name]

    user = User.new
    user.username = username
    user.password = password
    user.email = email
    user.name = name
    user.save!

    session[:user_id] = user.id
    redirect_to :action => "index"
  end

  def register
  end

  def connect
    session[:user_id] = nil
    redirect_to :action => "index"
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => "index"
  end


  def login
    if !params[:username].blank? or !params[:password].blank? and request.post?
      user = User.find(:first, :conditions => ["username = ?", params[:username]])
      if user and user.password = params[:password]
        session[:user_id] = user.id
        redirect_to :action => "index"
      else
        flash[:error] = "No username or password found."
        redirect_to :action => "index"
      end
    else
      render :template => "home/login"
    end
  end

  def account
    if session[:user_id].blank?
      redirect_to :action => "index"
    end
  end

  def save_account
    User.update(session[:user_id], { :name => params[:name], :email => params[:email], :password => params[:password]})
    session[:user_id] = User.find(session[:user_id]).id
    redirect_to :action => "account"
  end

  def save_run
    route = params[:route]
    miles = params[:miles]
    date_month = params[:date_month]
    date_day = params[:date_day]
    date_year = params[:date_year]
    begin
      date = Time.parse("#{date_month}/#{date_day}/#{date_year}").to_date
    rescue Exception => e
      if e.message == "time out of range"
        flash[:error] = "Sorry! Entered date is invalid."
        redirect_to :action => "index" and return false
      end
    end
    if date == nil or Date.today < date 
      flash[:error] = "Invalid date"
      redirect_to :action => "index" and return false
    end
    run = Run.new
    run.route = route
    run.miles = miles.to_f
    run.user_id = @user.id
    run.date = date
    run.save!
    if !params[:publish_to_fb].blank?
      register_feed_form_js(run)
    end
    @user = User.find(session[:user_id], :include => [:runs])
    redirect_to :action => "index"
  end
  
  def register_feed_form_js(run) 
    template_data = get_feed_template_data(run)
    bundle_id = get_feed_bundle_id() 
    js = "facebook_publish_feed_story('#{bundle_id}', #{template_data});"
    onload_register_js(js)         
  end
  
  def get_feed_template_data(run)
    template_data = {:runningpic => '', :location => run.route,
                      :distance => run.miles };
    return template_data.to_json
  end
  
  def onload_register_js(js)
    session[:onload_js] = js
  end
  
  def get_feed_bundle_id()
    # Currently hardcoded to my app's bundle id, you need to replace it
    '49664222849'
  end

end
