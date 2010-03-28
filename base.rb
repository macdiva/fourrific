require 'yaml'
require 'oauth'
require 'hpricot'

module Fourrific
	
	class Authorize
		
		#get keys from YAML
		f = File.open( 'credentials.yml' ) { |yf| YAML::load( yf ) }
		CONSUMER_KEY = f['foursquare_keys']['key'].to_s
		CONSUMER_SECRET = f['foursquare_keys']['secret'].to_s
		
		def initialize
			@consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET, {
						 :site               => "http://foursquare.com",
						 :scheme             => :header,
						 :http_method        => :post,
						 :request_token_path => "/oauth/request_token",
						 :access_token_path  => "/oauth/access_token",
						 :authorize_path     => "/oauth/authorize"
						})
			
			@request_token=@consumer.get_request_token					
		end
		
		def get_tokens
			#store @request_token.token and @request_token.secret for use when you get the callback
			#ask user to visit @request_token.authorize_url
			
			@tokens = {}
			@tokens[:request_token] = @request_token.token
			@tokens[:secret] = @request_token.secret
			@tokens[:url] = @request_token.authorize_url
			
			@tokens
		end
		
		
		def access_token(oauth_token,secret)
			#... in your callback page:
			# request_token_key will be 'oauth_token' in the query paramaters of the incoming get request
			
			@request_token = OAuth::RequestToken.new(@consumer, oauth_token, secret)
			@access_token=@request_token.get_access_token
			
			@access_tokens = {}
			@access_tokens[:token] = @access_token.token
			@access_tokens[:secret] = @access_token.secret
			
			@access_tokens
			#store @access_token.token and @access_token.secret
		end
	
	end

	class Checkins		
		def initialize(access,secret)
			
			@consumer = OAuth::Consumer.new(Fourrific::Authorize::CONSUMER_KEY,Fourrific::Authorize::CONSUMER_SECRET, {
						 :site               => "http://api.foursquare.com",
						 :scheme             => :header,
						 :http_method        => :post,
						})	
						
			@access_token = OAuth::AccessToken.new(@consumer, access, secret)			
		end
		
		def friends
			@friends = @access_token.get('/v1/checkins').body	
				
			@friends = Hpricot(@friends)
		end
		
	end

end