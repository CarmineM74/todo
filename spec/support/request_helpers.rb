module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  def decoded_body
    response.decoded_body
  end

  def parsed_body
    response.parsed_body
  end

end

