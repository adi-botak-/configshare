require 'sequel'

Sequel.migration do 
	change do
		create_join_table(contributor_id: :base_accounts, project_id: :projects)
	end
end