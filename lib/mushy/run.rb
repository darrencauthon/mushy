class Mushy::Run
  attr_accessor(:id, :flow_id)
end

class Mushy::FireUpAWebServer < Mushy::Run
  attr_accessor(:flow, :flux)
end
