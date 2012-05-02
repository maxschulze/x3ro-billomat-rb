module Billomat
  module ResourceWithoutWriteAccess
    def save
      raise MethodNotAvailable, "Cannot save #{self.class.name} over billomat api"
    end

    def create
      raise MethodNotAvailable, "Cannot save #{self.class.name} over billomat api"
    end

    def destroy
      raise MethodNotAvailable, "Cannot save #{self.class.name} over billomat api"
    end
  end

  module ResourceWithoutId
    def save
      connection.put(element_path(prefix_options), encode, self.class.headers).tap do |response|
        load_attributes_from_response(response)
      end
    end
  end



  # The "myself" record is a special record provided by the Billomat API, which represents
  # the data for the user with whose credentials the API is being accessed. This special
  # record type currently exists for:
  #
  # * [Clients](http://www.billomat.com/en/api/clients/)
  # * [Users](http://www.billomat.com/en/api/users/)
  #
  # It appears that these special records can not be saved through the API, which is
  # why this mixin exists.
  #
  module ResourceWithMyselfRecord

    # This field indicates whether or not the record is the "myself" record.
    # We need this because the "myself" record can not be edited (yet?).
    attr_accessor :myselfRecord

    def initialize(*args)
      @myselfRecord = false
      super *args
    end


    def isMyselfRecord?
      @myselfRecord
    end


    def save(*args)
      raise NoMethodError, "Cannot save #{self.class.name}.myself over Billomat API" if isMyselfRecord?
      super *args
    end


    def destroy(*args)
      raise NoMethodError, "Cannot destroy #{self.class.name}.myself over Billomat API" if isMyselfRecord?
      super *args
    end

  end

end
