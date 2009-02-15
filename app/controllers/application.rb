# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery #:secret => 'ca28f90a5eaced308485927772990ba8'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  before_filter :log_info_begin
  after_filter :log_info_end
  before_filter :check_for_fb_connect, :except => ["logout"]
  before_filter :set_session_objects

  def get_fb_connect_uid
    api_key = FB_CONNECT_KEY + '_'
    fb_uid = cookies[api_key + "user"]
    return fb_uid
  end

  def create_user_from_facebook_uid(fb_uid)
    user = User.new
    user.username = fb_uid
    user.password = ""
    user.email = ""
    user.fb_uid = fb_uid
    user.name = ""
    user.save!
  end

  def check_for_fb_connect
    user = get_logged_in_user
    if user.blank?
      session[:user_id] = nil
    else
      session[:user_id] = user.id
    end

    # Find out fb_uid
    fb_uid = get_fb_connect_uid()
    if session[:user_id] and !fb_uid.blank?
      session[:fb_connected] = true
    elsif !session[:user_id].blank?
      session[:fb_connected] = false
    end
  end

  def get_logged_in_user
    # Find out native user from session
    native_user = get_logged_in_native
    logger.debug("first native user is #{native_user.inspect}")

    # Find out fb_uid
    fb_uid = get_fb_connect_uid()
    
    logger.debug("fb_uid is #{fb_uid}")

    # if fb_uid is present.. find out user using fb_uid
    if !fb_uid.blank?
      logger.debug("case 1")
      user = User.find_by_fb_uid(fb_uid)

      # If native user is not blank
      if !native_user.blank?
        logger.debug("case 2")
        logger.debug("logging out")
        common_logout
        
        # connecting native user with fb_uid
        native_user.connect_with_facebook_uid(fb_uid)
        user = native_user
      elsif (user.blank?)
        logger.debug("case 3 ... entering")
        user = create_user_from_facebook_uid(fb_uid)
      end
    end

    if (native_user and user.blank?)
      logger.debug("case 4")
      user = native_user
    end
    return user
  end

  # We can add cookie
  def get_logged_in_native
    user = nil
    if !session[:user_id].blank?
      user = User.find(session[:user_id])
    end
    return user
  end

  def get_by_facebook_uid
    fb_uid = get_fb_connect_uid
    user = User.find_by_fb_uid(fb_uid)
    return user
  end

  def set_session_objects
    if !session[:user_id].blank?
      @user = User.find_by_id(session[:user_id], :include => [:runs])
    else
      @user = nil
    end
  end

  def log_info_begin
    logger.info("__ #{controller_name} :: #{action_name} begin __")
  end

  def log_info_end
    logger.info("__ #{controller_name} :: #{action_name} end __")
  end

end
