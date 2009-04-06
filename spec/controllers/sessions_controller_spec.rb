require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SessionsController do
  fixtures        :users
  before do 
    @user  = mock_user
    @login_params = { :login => 'quentin', :password => 'test' }
    User.stubs(:authenticate).with(@login_params[:login], @login_params[:password]).returns(@user)
  end
  def do_create
    post :create, @login_params
  end
  describe "on successful login," do
    [ [:nil,       nil,            nil],
      [:expired,   'valid_token',  15.minutes.ago],
      [:different, 'i_haxxor_joo', 15.minutes.from_now], 
      [:valid,     'valid_token',  15.minutes.from_now]
        ].each do |has_request_token, token_value, token_expiry|
      [ true, false ].each do |want_remember_me|
        describe "my request cookie token is #{has_request_token.to_s}," do
          describe "and ask #{want_remember_me ? 'to' : 'not to'} be remembered" do 
            before do
              @ccookies = mock('cookies')
              controller.stubs(:cookies).returns(@ccookies)
              @ccookies.stubs(:[]).with(:auth_token).returns(token_value)
              @ccookies.stubs(:delete).with(:auth_token)
              @ccookies.stubs(:[]=)
              @user.stubs(:remember_me) 
              @user.stubs(:refresh_token) 
              @user.stubs(:forget_me)
              @user.stubs(:remember_token).returns(token_value) 
              @user.stubs(:remember_token_expires_at).returns(token_expiry)
              @user.stubs(:remember_token?).returns(has_request_token == :valid)
              if want_remember_me
                @login_params[:remember_me] = '1'
              else 
                @login_params[:remember_me] = '0'
              end
            end
            it "kills existing login"        do controller.expects(:logout_keeping_session!); do_create; end    
            it "authorizes me"               do do_create; controller.send(:authorized?).should be_true;   end    
            it "logs me in"                  do do_create; controller.send(:logged_in?).should  be_true  end    
            it "greets me nicely"            do do_create; response.flash[:notice].should =~ /success/i   end
            it "sets/resets/expires cookie"  do controller.expects(:handle_remember_cookie!).with(want_remember_me); do_create end
            it "sends a cookie"              do controller.expects(:send_remember_cookie!);  do_create end
            it 'redirects to the home page'  do do_create; response.should redirect_to('/')   end
            it "does not reset my session"   do controller.expects(:reset_session).times(0); do_create end # change if you uncomment the reset_session path
            if (has_request_token == :valid)
              it 'does not make new token'   do @user.expects(:remember_me).times(0);   do_create end
              it 'does refresh token'        do @user.expects(:refresh_token);     do_create end 
              it "sets an auth cookie"       do do_create;  end
            else
              if want_remember_me
                it 'makes a new token'       do @user.expects(:remember_me);       do_create end 
                it "does not refresh token"  do @user.expects(:refresh_token).times(0); do_create end
                it "sets an auth cookie"       do do_create;  end
              else 
                it 'does not make new token' do @user.expects(:remember_me).times(0);   do_create end
                it 'does not refresh token'  do @user.expects(:refresh_token).times(0); do_create end 
                it 'kills user token'        do @user.expects(:forget_me);         do_create end 
              end
            end
          end # inner describe
        end
      end
    end
  end
  
  describe "on failed login" do
    before do
      User.expects(:authenticate).with(anything(), anything()).returns(nil)
      login_as :quentin
    end
    it 'logs out keeping session'   do controller.expects(:logout_keeping_session!); do_create end
    it 'flashes an error'           do do_create; flash[:error].should =~ /Couldn't log you in as 'quentin'/ end
    it 'renders the log in page'    do do_create; response.should render_template('new')  end
    it "doesn't log me in"          do do_create; controller.send(:logged_in?).should == false end
    it "doesn't send password back" do 
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_text(/FROBNOZZ/i)
    end
  end

  describe "on signout" do
    def do_destroy
      get :destroy
    end
    before do 
      login_as :quentin
    end
    it 'logs me out'                   do controller.expects(:logout_killing_session!); do_destroy end
    it 'redirects me to the home page' do do_destroy; response.should be_redirect     end
  end
  
end

describe SessionsController do
  describe "route generation" do
    it "should route the new sessions action correctly" do
      route_for(:controller => 'sessions', :action => 'new').should == "/login"
    end
    it "should route the create sessions correctly" do
      route_for(:controller => 'sessions', :action => 'create').should == "/session"
    end
    it "should route the destroy sessions action correctly" do
      route_for(:controller => 'sessions', :action => 'destroy').should == "/logout"
    end
  end
  
  describe "route recognition" do
    it "should generate params from GET /login correctly" do
      params_from(:get, '/login').should == {:controller => 'sessions', :action => 'new'}
    end
    it "should generate params from POST /session correctly" do
      params_from(:post, '/session').should == {:controller => 'sessions', :action => 'create'}
    end
    it "should generate params from DELETE /session correctly" do
      params_from(:delete, '/logout').should == {:controller => 'sessions', :action => 'destroy'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    it "should route session_path() correctly" do
      session_path().should == "/session"
    end
    it "should route new_session_path() correctly" do
      new_session_path().should == "/session/new"
    end
  end
  
end
