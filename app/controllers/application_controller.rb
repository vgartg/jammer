class ApplicationController < ActionController::Base

  protected
  def authenticate_user
    redirect_to login_path unless current_user
  end
  def current_user
    @current_user ||= User.find_by_id(session[:current_user])
  end

  def validate(user)
    errors = {}
    email = params[:user][:email]
    name = params[:user][:name]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    if email.blank?
      errors[:email] ||= []
      errors[:email] << 'Введите email'
    end
    if name.blank?
      errors[:name] ||= []
      errors[:name] << 'Введите имя'
    end
    if password.blank?
      errors[:password] ||= []
      errors[:password] << 'Введите пароль'
    end
    if password_confirmation.blank?
      errors[:password_confirmation] ||= []
      errors[:password_confirmation] << 'Повторите пароль'
    end

    unless email.blank? || email =~ /\A[^@\s]+@[^@\s]+\z/
      errors[:email] ||= []
      errors[:email] << 'Некорректный формат email'
    end
    if !(password.blank?) && password.length < 5
      errors[:password] ||= []
      errors[:password] << 'Пароль должен содержать не менее 5 символов'
    end

    if password != password_confirmation
      errors[:password_confirmation] ||= []
      errors[:password_confirmation] << 'Пароли не совпадают'
    end
    if User.exists?(email: email)
      errors[:email] ||= []
      errors[:email] << 'Почта уже зарегистрирована'
    end
    if User.exists?(name: name)
      errors[:name] ||= []
      errors[:name] << 'Имя уже занято'
    end

    return errors
  end

end
