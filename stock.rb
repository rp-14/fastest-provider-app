require 'concurrent-ruby'
require 'logger'

# Logger setup
logger = Logger.new($stdout)
logger.level = Logger::INFO

class Resource
  def initialize(name)
    @name = name
  end

  def get_resource
    response_time = rand(50..200)
    sleep(response_time / 1000.0)
    { provider_name: @name, response_time: response_time }
  end
end

def fastest_response(providers, logger)
  logger.info("Initiating resource fetching from providers: #{providers.map { |provider| provider.instance_variable_get('@name') }.join(', ')}")

  # Start fetching resources concurrently
  provider_futures = providers.map do |provider|
    Concurrent::Promises.future { provider.get_resource }
  end

  final_result = nil
  start_time = Time.now

  until final_result
    provider_futures.each do |future|
      if future.fulfilled?
        final_result = future.value
        logger.info("Fastest provider found: #{final_result[:provider_name]} with response time: #{final_result[:response_time]} ms")
        break
      end
    end
    sleep(0.01)
  end

  # Logging unfulfilled
  provider_futures.each do |future|
    if !future.fulfilled? && !future.rejected?
      logger.info("Unfulfilled task ignored for a provider.")
    end
  end

  logger.info("Total time taken to find the fastest provider: #{(Time.now - start_time) * 1000} ms")
  final_result
end

providers = [
  Resource.new("Groww"),
  Resource.new("Upstox"),
  Resource.new("Zerodha")
]

fastest_provider = fastest_response(providers, logger)

puts "Fastest provider: #{fastest_provider[:provider_name]}, Response time: #{fastest_provider[:response_time]} ms"
