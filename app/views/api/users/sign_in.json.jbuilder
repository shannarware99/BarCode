json.user do
	json.partial! 'api/users/user', user: @current_user
	json.token @current_user.generate_jwt
end