module Spyke
  class Config
    def self.connection=(faraday)
      warn "[DEPRECATION] `Spyke::Config.connection=` is deprecated.  Please use `Spyke::Base.connection=` instead."
      Spyke::Base.connection = faraday
    end
  end
end
