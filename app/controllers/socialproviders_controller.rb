class SocialprovidersController < ApplicationController
  before_filter :authenticate_user!, only: [:destroy]

  def create
    provider = params[:socialprovider]
    omniauth = request.env['omniauth.auth']

    if omniauth
      case provider
        # MOZILLA PERSONA
        when 'persona'
          display_name = email = uid = omniauth['uid']
        # FACEBOOK
        when 'facebook'
          display_name = omniauth['extra']['raw_info']['name']
          email = omniauth['extra']['raw_info']['email']
          uid = omniauth['extra']['raw_info']['id']
        # GOOGLE OPENID
        when 'google'
          display_name = omniauth['info']['name']
          email = omniauth['info']['email']
          uid = omniauth['uid']
        else
          display_name = email = uid = ''
      end

      #  provider and uid ARE valid
      if provider != '' and uid != ''
        # user is NOT signed in
        if !cookies[:user_id]
          auth = Socialprovider.where(provider: provider, uid: uid).first
          # user HAS already signed in with this social provider -> sign in
          if auth
            flash[:notice] = t('authentication.social.success', provider: provider.capitalize)
            sign_in_and_redirect :user, auth.user
          # user has NOT already signed in with this social provider
          else
            existinguser = User.where(email: email).first
            # user HAS already a peppermind account -> add social provider to account and sign in
            if existinguser
              existinguser.socialproviders.create provider: provider, uid: uid, display_name: display_name, email: email
              flash[:notice] = t('authentication.social.added_and_signed_in', provider: provider.capitalize, email: existinguser.email)
              sign_in_and_redirect :user, existinguser
            # user has NOT already a peppermind account -> create a peppermind account, add the social provider and sign in
            else
              session[:user_display_name] = display_name
              session[:user_email] = email
              session[:user_provider] = provider
              session[:user_uid] = uid
              redirect_to after_signup_index_path
            end
          end
        # user IS signed in
        else
          # social prodider IS already linked with this account
          if Socialprovider.where(provider: provider, user_id: cookies[:user_id]).first
            flash[:notice] = t('authentication.social.already_linked', provider: provider.capitalize)
            redirect_to account_edit_path
          # social provider is NOT already linked with this account
          else
            existinguser = User.where(_id: cookies[:user_id]).first
            # requested account linked with other user?
            if Socialprovider.where(provider: provider, uid: uid).first
              flash[:error] = t('authentication.social.already_linked_with_other', provider: provider.capitalize)
              sign_in_and_redirect :user, existinguser
            # add social provider to account
            else
              existinguser.socialproviders.create provider: provider, uid: uid, display_name: display_name, email: email
              flash[:notice] = t('authentication.social.added', provider: provider.capitalize)
              sign_in_and_redirect :user, existinguser
            end
          end
        end
      # provider or uid is NOT valid
      else
        flash[:error] =  t('authentication.social.invalid_data', provider: provider.capitalize)
        redirect_to new_user_session_path
      end
    # no valid data in request.env['omniauth.auth']
    else
      flash[:error] = t('authentication.social.error', provider: provider.capitalize)
      redirect_to new_user_session_path
    end
  end

  def destroy
    @socialprovider = current_user.socialproviders.find(params[:id])
    @socialprovider.destroy

    redirect_to account_edit_path, notice: t('authentication.social.removed', provider: @socialprovider.provider.capitalize)
  end

  def oauth_failure
    redirect_to root_path
  end
end
