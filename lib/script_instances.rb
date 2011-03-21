class ScriptInstances
  @@instances = {

  }

  def self.spawn(id)
    @@instances[id] = Runner.new(SCRIPT_PATH, SCRIPT)
  end


  def self.flush(id)
    @@instances[id].flush
  end


  def self.run(id)
    @@instances[id].run
  end


  def self.is_running?(id)
    @@instances[id].running
  end


  def self.buffer(id)
    @@instances[id].buffer
  end


  def self.has?(id)
    @@instances.has_key? id
  end


  def self.write(id, string)
    @@instances[id].write string
  end

end

