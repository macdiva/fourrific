begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'sinatra'
Bundler.require
require File.dirname(__FILE__) + '/base'

enable :sessions

get '/' do
	@ip = @env['REMOTE_ADDR']
	
	if params[:oauth_token]
		h = Fourrific::Authorize.new
		t = h.access_token(params[:oauth_token],session[:request_secret])
		session[:token] = t[:token]
		session[:secret] = t[:secret]
		
		#if you reload the page with the oauth param, you 500, better to redirect and kill the possibility
		redirect '/' 
		
	elsif session[:token].nil?
		redirect '/login'	
	end
	
	c = Fourrific::Checkins.new(session[:token],session[:secret])
	@c = c.friends(@ip)
	
	city = Fourrific::IPGeocode.new(@ip)
	@city = city.you_are_in 
	
	erb :index

end

get '/login' do
	
	h = Fourrific::Authorize.new
	t = h.get_tokens
	
	session[:request_token] = t[:request_token]
	session[:request_secret] = t[:secret]
	@url = t[:url]
	
	redirect "#{@url}"
	erb :login
end