require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  fixtures :all

  # autodetects the :controller
  should_route :get,    '/posts',     :controller => :posts, :action => :index
  # explicitly specify :controller
  should_route :post,   '/posts',     :controller => :posts, :action => :create
  # non-string parameter
  should_route :get,    '/posts/1',   :controller => :posts, :action => :show, :id => 1
  # string-parameter
  should_route :put,    '/posts/1',   :controller => :posts, :action => :update, :id => "1"
  should_route :delete, '/posts/1',   :controller => :posts, :action => :destroy, :id => 1
  should_route :get,    '/posts/new', :controller => :posts, :action => :new

  # Test the nested routes
  should_route :get,    '/users/5/posts',     :controller => :posts, :action => :index, :user_id => 5
  should_route :post,   '/users/5/posts',     :controller => :posts, :action => :create, :user_id => 5
  should_route :get,    '/users/5/posts/1',   :controller => :posts, :action => :show, :id => 1, :user_id => 5
  should_route :delete, '/users/5/posts/1',   :controller => :posts, :action => :destroy, :id => 1, :user_id => 5
  should_route :get,    '/users/5/posts/new', :controller => :posts, :action => :new, :user_id => 5
  should_route :put,    '/users/5/posts/1',   :controller => :posts, :action => :update, :id => 1, :user_id => 5

  describe "Logged in" do
    before do
      request.session[:logged_in] = true
    end

    describe "viewing posts for a user" do
      before do
        get :index, :user_id => users(:first)
      end
      # should_respond_with :success
      should_assign_to :user, :class => User, :equals => 'users(:first)'
      it { lambda { should_assign_to(:user, :class => Post) }.should raise_error }
      it { lambda { should_assign_to :user, :equals => 'posts(:first)' }.should raise_error }
      should_assign_to :posts
      should_not_assign_to :foo, :bar
    end

    context "on POST to :create" do
      before do
        post :create, :post => { :title => "Title", :body => "Body" }, :user_id => users(:first)
        @post = Post.last
      end
      should_redirect_to "user_post_url(@post.user, @post)"
      should_set_the_flash_to /created/i
    end
    
    describe "viewing posts for a user with rss format" do
      before do
        get :index, :user_id => users(:first), :format => 'rss'
        @user = users(:first)
      end
      it { response.should be_success }
      should_respond_with_content_type 'application/rss+xml'
      should_respond_with_content_type :rss
      should_respond_with_content_type /rss/
      should_return_from_session :special, "'$2 off your next purchase'"
      should_return_from_session :special_user_id, '@user.id'
      should_assign_to :user, :posts
      should_not_assign_to :foo, :bar
    end

    describe "viewing a post on GET to #show" do
      before { get :show, :user_id => users(:first), :id => posts(:first) }
      should_render_with_layout 'wide'
      should_render_with_layout :wide
    end

    describe "on GET to #new" do
      before { get :new, :user_id => users(:first) }
      should_render_without_layout
      should_not_set_the_flash
    end
  end

end
