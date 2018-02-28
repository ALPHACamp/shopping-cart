class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # 由於 Cookie/Session 和瀏覽器有關，方法必須放在 controller 裡
  # 另外，在 View 裡呼叫 Controller 方法時，必須使用 helper_method

  helper_method :current_cart

  private

  def authenticate_admin!
    unless current_user.admin?
      raise "Page doesn't exist"
      redirect_to root_path
    end
  end

  def current_cart
    @cart || set_cart # return @cart if @cart exist, or call set_cart
  end

  def set_cart

    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
    end

    @cart ||= Cart.create

    session[:cart_id] = @cart.id
    @cart
  end
end
