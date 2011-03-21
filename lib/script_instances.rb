class ScriptInstances
  @@instances = {

  }

  #
  # The @@instances var is an index of BAM's runner instances.
  #
  # Individual instances are managed by the Runner class.
  #
  # Instances are identified by their instance_key, which is also how the ajax calls in
  # the BAM UI keep track them.
  #

  # Create a new instance
  def self.spawn(id)
    @@instances[id] = Runner.new(SCRIPT_PATH, SCRIPT)
  end

  # Get rid of a specific instance, using the Runner#flush method.
  def self.flush(id)
    @@instances[id].flush
  end

  # Start a specific instance, using the Runner#run method.
  def self.run(id)
    @@instances[id].run
  end

  # Check on the state of an instance, by checking the boolean @running,
  # in the Runner instance. Gets set to false on script completion
  def self.is_running?(id)
    @@instances[id].running
  end

  # Accessor for a Runner's @buffer StringIO object.
  # This allows the Mongerel handler to do things like call #rewind...
  def self.buffer(id)
    @@instances[id].buffer
  end

  # Check for the presence of an instance, used for checking that input isn't
  # delivered to a dead instance...
  def self.has?(id)
    @@instances.has_key? id
  end

  # Used for writing to an instance - ie user input.
  def self.write(id, string)
    @@instances[id].write string
  end

end

