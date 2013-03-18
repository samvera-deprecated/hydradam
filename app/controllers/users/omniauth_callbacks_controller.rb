class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def ldap
    @user = User.find_for_ldap_oauth(request.env["omniauth.auth"])

    # eduPersonAffiliation (e.g. "staff, student, faculty")
    #@user.affiliations = request.env["omniauth.auth"][:extra][:raw_info][:edupersonaffiliation]

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Ldap"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.ldap_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
