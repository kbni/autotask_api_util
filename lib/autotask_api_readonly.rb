# Block AutoTaskAPI module from updating or creating entities
module AutotaskAPI
  class Client
    def update(*)
      puts 'blocked AutotaskAPI.update'
    end

    def create(*)
      puts 'blocked AutotaskAPI.create'
    end
  end
end
