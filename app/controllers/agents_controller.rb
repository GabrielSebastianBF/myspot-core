class AgentsController < ApplicationController
  def index
    @agents = Agent.all
  end
end

class MemoriesController < ApplicationController
  def index
    @memories = Memory.order(created_at: :desc).limit(100)
  end
end

class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end
end

class ExecutionsController < ApplicationController
  def index
    @executions = ToolExecution.order(created_at: :desc).limit(50)
  end
end

class SettingsController < ApplicationController
  def index
    # Settings placeholder
  end
end
