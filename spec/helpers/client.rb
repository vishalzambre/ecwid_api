module Helpers
  module Client
    def client
      @client ||= EcwidApi::Client.new(12345, "access_token").tap do |client|
        allow(client).to receive(:connection).and_return(faraday)
      end
    end

    def fixtures
      %w(categories category customers orders products classes)
    end

    def faraday_stubs
      ::Faraday::Adapter::Test::Stubs.new do |stub|
        fixtures.each do |fixture|
          stub.get(fixture) { [ 200, {"Content-Type" => "application/json"}, File.read("spec/fixtures/#{fixture}.json") ] }
        end
        stub.get("/categories/5") { [200, {"Content-Type" => "application/json"}, File.read("spec/fixtures/category.json") ] }
        stub.get("/orders/35") { [200, {"Content-Type" => "application/json"}, File.read("spec/fixtures/order.json") ] }
        stub.get("/orders/404") { [404, {"Content-Type" => "application/json"}, nil ] }
        stub.get("/classes/1") { [200, {"Content-Type" => "application/json"}, File.read("spec/fixtures/classes.json") ] }
        stub.get("/classes/404") { [404, {"Content-Type" => "application/json"}, nil ] }
        stub.get("/products/41316136") { [200, {"Content-Type" => "application/json"}, File.read("spec/fixtures/product.json") ] }
      end
    end

    # Public: Returns a test Faraday::Connection
    def faraday
      ::Faraday.new do |builder|
        builder.response :json, content_type: /\bjson$/
        builder.adapter :test, faraday_stubs
      end
    end
  end
end
