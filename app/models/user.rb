class User < ActiveRecord::Base
  has_many :runs
  #validates_presence_of :username, :password, :name
  #validates_uniqueness_of :username

  attr_accessor_with_default :fb_connected, false

  def connect_with_facebook_uid(fb_uid)
    logger.debug("In user model connect with facebook uid.. input fb_uid is #{fb_uid}")
    
    logger.debug("Finding user with fb_uid")
    fb_user = User.find_by_fb_uid(fb_uid)

    logger.debug("found fb_user with fb_uid is ${fb_user}")
    if fb_user and (fb_user.username !=  self.username)
    logger.debug("deleting the previous fb_uid only user as new user is authenticated with new fb_uid")
      User.delete(fb_user.id)
    end
    
    
    if fb_uid.blank?
      logger.debug("returning false as passed fb_uid is blank")
      return false
    end
    
    logger.debug("updating fb_uid is current object .. and saving it")
    self.fb_uid = fb_uid
    logger.debug "came here"
    self.save!
  end

end
